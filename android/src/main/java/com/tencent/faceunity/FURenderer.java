package com.tencent.faceunity;

import android.content.Context;
import android.util.Log;

import com.faceunity.core.callback.OperateCallback;
import com.faceunity.core.entity.FUBundleData;
import com.faceunity.core.entity.FURenderInputData;
import com.faceunity.core.entity.FURenderOutputData;
import com.faceunity.core.enumeration.CameraFacingEnum;
import com.faceunity.core.enumeration.FUAIProcessorEnum;
import com.faceunity.core.enumeration.FUAITypeEnum;
import com.faceunity.core.enumeration.FUTransformMatrixEnum;
import com.faceunity.core.faceunity.FURenderConfig;
import com.faceunity.core.faceunity.FURenderKit;
import com.faceunity.core.faceunity.FURenderManager;
import com.faceunity.core.model.bodyBeauty.BodyBeauty;
import com.faceunity.core.model.facebeauty.FaceBeauty;
import com.faceunity.core.model.makeup.SimpleMakeup;
import com.faceunity.core.utils.FULogger;
import com.tencent.faceunity.listener.FURendererListener;


import org.jetbrains.annotations.NotNull;

import java.io.ByteArrayOutputStream;
import java.io.DataOutputStream;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;


/**
 * DESC：
 * Created on 2021/4/26
 */
public class FURenderer extends IFURenderer {


    public volatile static FURenderer INSTANCE;

    public static FURenderer getInstance() {
        if (INSTANCE == null) {
            synchronized (FURenderer.class) {
                if (INSTANCE == null) {
                    INSTANCE = new FURenderer();
                    INSTANCE.mFURenderKit = FURenderKit.getInstance();
                }
            }
        }
        return INSTANCE;
    }

    /**
     * 状态回调监听
     */
    private FURendererListener mFURendererListener;

    private BodyBeauty bodyBeauty;
    private FaceBeauty faceBeauty;
    private SimpleMakeup simpleMakeup;


    /* 特效FURenderKit*/
    private FURenderKit mFURenderKit;

    /* AI道具*/
    private String BUNDLE_AI_FACE = "model" + File.separator + "ai_face_processor.bundle";
    private String BUNDLE_AI_HUMAN = "model" + File.separator + "ai_human_processor.bundle";


    /* GL 线程 ID */
    private Long mGlThreadId = 0L;
    /* 渲染开关标识 */
    private volatile boolean mRendererSwitch = false;
    /*检测类型*/
    private FUAIProcessorEnum aIProcess = FUAIProcessorEnum.FACE_PROCESSOR;
    /*检测标识*/
    private int aIProcessTrackStatus = -1;

    /**
     * 初始化鉴权
     *
     * @param context
     */
    @Override
    public void setup(Context context) {
        FURenderManager.setKitDebug(FULogger.LogLevel.TRACE);
        FURenderManager.setCoreDebug(FULogger.LogLevel.ERROR);

        byte[] value = authpack.A();
        FURenderManager.registerFURender(context, value, new OperateCallback() {
            @Override
            public void onSuccess(int i, @NotNull String s) {
                if (i == FURenderConfig.OPERATE_SUCCESS_AUTH) {
                    mFURenderKit.getFUAIController().loadAIProcessor(BUNDLE_AI_FACE, FUAITypeEnum.FUAITYPE_FACEPROCESSOR);
                    mFURenderKit.getFUAIController().loadAIProcessor(BUNDLE_AI_HUMAN, FUAITypeEnum.FUAITYPE_HUMAN_PROCESSOR);
                }
                mFURenderKit.getFUAIController().faceProcessorSetFov(10);
            }

            @Override
            public void onFail(int i, @NotNull String s) {
            }
        });
    }

    public void setup(Context context, ArrayList<Integer> authpack) throws IOException {

        FURenderManager.setKitDebug(FULogger.LogLevel.TRACE);
        FURenderManager.setCoreDebug(FULogger.LogLevel.ERROR);

        ByteArrayOutputStream byteOutStream = new ByteArrayOutputStream();
        DataOutputStream dataOutPut = new DataOutputStream(byteOutStream);
        for (Integer element: authpack) {
            dataOutPut.write(element);
        }
        byte[] auth = byteOutStream.toByteArray();

        FURenderManager.registerFURender(context, auth, new OperateCallback() {
            @Override
            public void onSuccess(int i, @NotNull String s) {
                if (i == FURenderConfig.OPERATE_SUCCESS_AUTH) {
                    FURenderKit.getInstance().getFUAIController().loadAIProcessor(BUNDLE_AI_FACE, FUAITypeEnum.FUAITYPE_FACEPROCESSOR);
                    FURenderKit.getInstance().getFUAIController().loadAIProcessor(BUNDLE_AI_HUMAN, FUAITypeEnum.FUAITYPE_HUMAN_PROCESSOR);
                    loadBundle();
                }
                FURenderKit.getInstance().getFUAIController().faceProcessorSetFov(10);
            }

            @Override
            public void onFail(int i, @NotNull String s) {
                if (i == 0) {

                }
            }
        });
    }

    public void loadBundle(){
        /// 文件设置
        String BUNDLE_FACE_BEAUTIFICATION = "graphics" + File.separator + "face_beautification.bundle";
        String BUNDLE_BODY_BEAUTY = "graphics" + File.separator + "body_slim.bundle";
        String BUNDLE_FACE_MAKEUP = "graphics" + File.separator + "face_makeup.bundle";
        if (bodyBeauty == null)
            bodyBeauty = new BodyBeauty(new FUBundleData(BUNDLE_BODY_BEAUTY));
        FURenderKit.getInstance().setBodyBeauty(bodyBeauty);
        if (faceBeauty == null)
            faceBeauty = new FaceBeauty(new FUBundleData(BUNDLE_FACE_BEAUTIFICATION));
        FURenderKit.getInstance().setFaceBeauty(faceBeauty);
        if (simpleMakeup == null)
            simpleMakeup = new SimpleMakeup(new FUBundleData(BUNDLE_FACE_MAKEUP));
        FURenderKit.getInstance().setMakeup(simpleMakeup);
    }

    /**
     * 获取 Nama SDK 版本号，例如 7_0_0_phy_8b882f6_91a980f
     *
     * @return version
     */
    public String getVersion() {
        return mFURenderKit.getVersion();
    }

    /**
     * 开启合成状态
     */
    @Override
    public void prepareRenderer(FURendererListener mFURendererListener) {
        this.mFURendererListener = mFURendererListener;
        mRendererSwitch = true;
        queueEvent(() -> mGlThreadId = Thread.currentThread().getId());
        if (mFURendererListener != null)
            mFURendererListener.onPrepare();
    }


    /**
     * 单输入接口，输入texture，必须在具有 GL 环境的线程调用
     *
     * @param texId  纹理 ID
     * @param width  宽
     * @param height 高
     * @return
     */
    public int onDrawFrameSingleInput(int texId, int width, int height) {
        prepareDrawFrame();
        if (!mRendererSwitch) {
            return texId;
        }
        FURenderInputData inputData = new FURenderInputData(width, height);
        inputData.setTexture(new FURenderInputData.FUTexture(inputTextureType, texId));
        FURenderInputData.FURenderConfig config = inputData.getRenderConfig();
        config.setExternalInputType(externalInputType);
        config.setInputOrientation(inputOrientation);
        config.setDeviceOrientation(deviceOrientation);
        config.setInputBufferMatrix(inputBufferMatrix);
        config.setInputTextureMatrix(inputTextureMatrix);
        config.setCameraFacing(cameraFacing);
        config.setOutputMatrix(outputMatrix);
        mCallStartTime = System.nanoTime();
        FaceBeauty f = FURenderKit.getInstance().getFaceBeauty();

        FURenderOutputData outputData = mFURenderKit.renderWithInput(inputData);
        mSumCallTime += System.nanoTime() - mCallStartTime;
        if (outputData != null && outputData.getTexture() != null && outputData.getTexture().getTexId() > 0) {
            return outputData.getTexture().getTexId();
        }
        return 0;
    }

    @Override
    public void setCameraFacing(CameraFacingEnum cameraFacing) {
        super.setCameraFacing(cameraFacing);
        if (cameraFacing == CameraFacingEnum.CAMERA_FRONT) {
            setInputOrientation(180);
            setInputBufferMatrix(FUTransformMatrixEnum.CCROT0_FLIPVERTICAL);
            setInputTextureMatrix(FUTransformMatrixEnum.CCROT0_FLIPVERTICAL);
            setOutputMatrix(FUTransformMatrixEnum.CCROT0);
        } else {
            setInputOrientation(180);
            setInputBufferMatrix(FUTransformMatrixEnum.CCROT180);
            setInputTextureMatrix(FUTransformMatrixEnum.CCROT180);
            setOutputMatrix(FUTransformMatrixEnum.CCROT0_FLIPHORIZONTAL);
        }

    }

    /**
     * 双输入接口，输入 buffer 和 texture，必须在具有 GL 环境的线程调用
     * 由于省去数据拷贝，性能相对最优，优先推荐使用。
     * 缺点是无法保证 buffer 和纹理对齐，可能出现点位和效果对不上的情况。
     *
     * @param img    NV21 buffer
     * @param texId  纹理 ID
     * @param width  宽
     * @param height 高
     * @return
     */
    @Override
    public int onDrawFrameDualInput(byte[] img, int texId, int width, int height) {
        prepareDrawFrame();
        if (!mRendererSwitch) {
            return texId;
        }
        FURenderInputData inputData = new FURenderInputData(width, height);
        //buffer为空，单纹理输入
        //inputData.setImageBuffer(new FURenderInputData.FUImageBuffer(inputBufferType, img)); buffer
        inputData.setTexture(new FURenderInputData.FUTexture(inputTextureType, texId));
        FURenderInputData.FURenderConfig config = inputData.getRenderConfig();
        config.setExternalInputType(externalInputType);
        config.setInputOrientation(inputOrientation);
        config.setDeviceOrientation(deviceOrientation);
        config.setInputBufferMatrix(inputBufferMatrix);
        config.setInputTextureMatrix(inputTextureMatrix);
        config.setOutputMatrix(outputMatrix);
        config.setCameraFacing(cameraFacing);
        FURenderOutputData outputData = mFURenderKit.renderWithInput(inputData);
        if (outputData.getTexture() != null && outputData.getTexture().getTexId() > 0) {
            return outputData.getTexture().getTexId();
        }
        return texId;
    }

    /**
     * 类似 GLSurfaceView 的 queueEvent 机制，把任务抛到 GL 线程执行。
     *
     * @param runnable
     */
    @Override
    public void queueEvent(Runnable runnable) {
        if (runnable == null) {
            return;
        }

        if (mGlThreadId == Thread.currentThread().getId()) {
            runnable.run();
        }
    }


    /**
     * 释放资源
     */
    @Override
    public void release() {
        mRendererSwitch = false;
        mGlThreadId = 0L;
        mFURenderKit.release();
        aIProcessTrackStatus = -1;
        if (mFURendererListener != null) {
            mFURendererListener.onRelease();
            mFURendererListener = null;
        }
    }


    /**
     * 渲染前置执行
     *
     * @return
     */
    private void prepareDrawFrame() {
        benchmarkFPS();
        // AI检测
        trackStatus();
    }

    //region AI识别

    /**
     * 设置检测类型
     *
     * @param type
     */
    @Override
    public void setAIProcessTrackType(FUAIProcessorEnum type) {
        aIProcess = type;
        aIProcessTrackStatus = -1;
    }

    /**
     * 设置FPS检测
     *
     * @param enable
     */
    @Override
    public void setMarkFPSEnable(boolean enable) {
        mIsRunBenchmark = enable;
    }


    /**
     * AI识别数目检测
     */
    private void trackStatus() {
        int trackCount;
        if (aIProcess == FUAIProcessorEnum.HAND_GESTURE_PROCESSOR) {
            trackCount = mFURenderKit.getFUAIController().handProcessorGetNumResults();
        } else if (aIProcess == FUAIProcessorEnum.HUMAN_PROCESSOR) {
            trackCount = mFURenderKit.getFUAIController().humanProcessorGetNumResults();
        } else {
            trackCount = mFURenderKit.getFUAIController().isTracking();
        }
        if (trackCount != aIProcessTrackStatus) {
            aIProcessTrackStatus = trackCount;
        } else {
            return;
        }
        if (mFURendererListener != null) {
            mFURendererListener.onTrackStatusChanged(aIProcess, trackCount);
        }
    }
    //endregion AI识别

    //------------------------------FPS 渲染时长回调相关定义------------------------------------

    private static final int NANO_IN_ONE_MILLI_SECOND = 1_000_000;
    private static final int NANO_IN_ONE_SECOND = 1_000_000_000;
    private static final int FRAME_COUNT = 20;
    private boolean mIsRunBenchmark = false;
    private int mCurrentFrameCount;
    private long mLastFrameTimestamp;
    private long mSumCallTime;
    private long mCallStartTime;

    private void benchmarkFPS() {
        if (!mIsRunBenchmark) {
            return;
        }
        if (++mCurrentFrameCount == FRAME_COUNT) {
            long tmp = System.nanoTime();
            double fps = (double) NANO_IN_ONE_SECOND / ((double) (tmp - mLastFrameTimestamp) / FRAME_COUNT);
            double renderTime = (double) mSumCallTime / FRAME_COUNT / NANO_IN_ONE_MILLI_SECOND;
            mLastFrameTimestamp = tmp;
            mSumCallTime = 0;
            mCurrentFrameCount = 0;

            Log.d("test","fps: " + fps + ",rendertime: " + renderTime);
            if (mFURendererListener != null) {
                mFURendererListener.onFpsChanged(fps, renderTime);
            }
        }
    }


}
