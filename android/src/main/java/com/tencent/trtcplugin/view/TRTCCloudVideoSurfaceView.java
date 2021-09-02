package com.tencent.trtcplugin.view;

import android.content.Context;
import android.opengl.EGL14;
import android.util.Log;
import android.view.SurfaceView;
import android.view.View;

import java.io.File;
import java.util.Map;

import com.faceunity.core.entity.FUBundleData;
import com.faceunity.core.enumeration.CameraFacingEnum;
import com.faceunity.core.faceunity.FURenderKit;
import com.faceunity.core.model.bodyBeauty.BodyBeauty;
import com.faceunity.core.model.facebeauty.FaceBeauty;
import com.faceunity.core.model.makeup.SimpleMakeup;
import com.faceunity.core.utils.ThreadHelper;
import com.tencent.faceunity.FURenderer;
import com.tencent.rtmp.TXLog;
import com.tencent.rtmp.ui.TXCloudVideoView;
import com.tencent.trtc.TRTCCloud;
import com.tencent.trtc.TRTCCloudDef;
import com.tencent.trtc.TRTCCloudListener;
import com.tencent.trtcplugin.util.CommonUtil;
import com.tencent.faceunity.checkbox.CheckGroupPlatformView;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;



/**
 * 视频视图
 */
public class TRTCCloudVideoSurfaceView extends PlatformViewFactory
        implements PlatformView, MethodChannel.MethodCallHandler {
    public static final String SIGN = "trtcCloudChannelSurfaceView";
    public static final String bottomBar = "FuRenderKitBottomBar";
    private static final String TAG = "TRTCCloudFlutter";

    private BinaryMessenger messenger;
    private TRTCCloud trtcCloud;
    private TXCloudVideoView remoteView;
    private SurfaceView mSurfaceView;
    private MethodChannel mChannel;
    private final FURenderer mFURenderer;

    /**
     * 初始化工厂信息，此处的域是 PlatformViewFactory
     */
    public TRTCCloudVideoSurfaceView(Context context, BinaryMessenger messenger) {
        super(StandardMessageCodec.INSTANCE);

        this.messenger = messenger;
        trtcCloud = TRTCCloud.sharedInstance(context);
        mSurfaceView = new SurfaceView(context);
        remoteView = new TXCloudVideoView(mSurfaceView);
        mFURenderer = FURenderer.getInstance();
//        mFURenderer.loadBundle();
    }

    @Override
    public View getView() {
        return mSurfaceView;
    }

    @Override
    public void dispose() {}

    @Override
    public PlatformView create(Context context, int viewId, Object args) {

        if(args instanceof Map) {
            final String type = ((Map<String, String>) args).get("type");
            if (type.equals(bottomBar)) {
                // 等待解决问题
                return new CheckGroupPlatformView(context, args);
            }
        }
        // 每次实例化对象，保证界面上每一个组件的独立性
        TRTCCloudVideoSurfaceView view = new TRTCCloudVideoSurfaceView(context, messenger);
        mChannel = new MethodChannel(messenger, SIGN + "_" + viewId);
        mChannel.setMethodCallHandler(view);
        return view;
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        TXLog.i(TAG, "|method=" + call.method + "|arguments=" + call.arguments);
        switch (call.method) {
            case "startRemoteView":
                this.startRemoteView(call, result);
                break;
            case "startLocalPreview":
                this.startLocalPreview(call, result);
                break;
            default:
                result.notImplemented();
        }

    }

    /**
     * 开始显示远端视频画面
     */
    private void startRemoteView(MethodCall call, Result result) {
        String userId = CommonUtil.getParam(call, result, "userId");
        int streamType = CommonUtil.getParam(call, result, "streamType");
        trtcCloud.startRemoteView(userId, streamType, this.remoteView);
        result.success(null);
    }

    /**
     * 开启本地视频的预览画面
     */
    private void startLocalPreview(MethodCall call, Result result) {
        boolean frontCamera = CommonUtil.getParam(call, result, "frontCamera");
        mFURenderer.loadBundle();
        trtcCloud.setLocalVideoProcessListener(TRTCCloudDef.TRTC_VIDEO_PIXEL_FORMAT_Texture_2D,
                TRTCCloudDef.TRTC_VIDEO_BUFFER_TYPE_TEXTURE, new TRTCCloudListener.TRTCVideoFrameListener() {
                    @Override
                    public void onGLContextCreated() {
                        Log.i(TAG, "tex onGLContextCreated: " + EGL14.eglGetCurrentContext());
                        mFURenderer.prepareRenderer(null);
                    }

                    @Override
                    public int onProcessVideoFrame(TRTCCloudDef.TRTCVideoFrame src, TRTCCloudDef.TRTCVideoFrame dest) {
                        Log.d(TAG, String.format("process video frame, w %d, h %d, tex %d, rotation %d, pixel format %d",
                                src.width, src.height, src.texture.textureId, src.rotation, src.pixelFormat));
                        mFURenderer.setCameraFacing(frontCamera? CameraFacingEnum.CAMERA_FRONT:CameraFacingEnum.CAMERA_BACK);
                        long start =  System.nanoTime();
                        dest.texture.textureId = mFURenderer.onDrawFrameSingleInput(src.texture.textureId, src.width, src.height);
//                        if (mCSVUtils != null) {
//                            long renderTime = System.nanoTime() - start;
//                            mCSVUtils.writeCsv(null, renderTime);
//                        }
                        return 0;
                    }

                    @Override
                    public void onGLContextDestory() {
                        Log.i(TAG, "tex onGLContextDestory: " + EGL14.eglGetCurrentContext());
                        mFURenderer.release();
                    }
                });
        trtcCloud.startLocalPreview(frontCamera, this.remoteView);
        result.success(null);
    }
}