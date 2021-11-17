package com.tencent.trtcplugin;

import android.content.Context;
import android.content.res.AssetManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.SurfaceTexture;

import androidx.annotation.NonNull;

import com.faceunity.core.entity.FUBundleData;
import com.faceunity.core.faceunity.FUAIKit;
import com.faceunity.core.faceunity.FURenderKit;
import com.faceunity.core.model.facebeauty.FaceBeauty;
import com.faceunity.core.model.makeup.SimpleMakeup;
import com.google.gson.Gson;
import com.tencent.faceunity.FURenderer;

import com.tencent.liteav.audio.TXAudioEffectManager;
import com.tencent.liteav.beauty.TXBeautyManager;
import com.tencent.liteav.device.TXDeviceManager;
//import com.tencent.rtmp.TXLiveBase;
import com.tencent.rtmp.TXLiveBase;
import com.tencent.rtmp.TXLog;
import com.tencent.trtc.TRTCCloud;
import com.faceunity.core.model.bodyBeauty.BodyBeauty;
import com.tencent.trtc.TRTCCloudDef;
import com.tencent.trtc.TRTCCloudListener;
import com.tencent.trtcplugin.listener.CustomTRTCCloudListener;
import com.tencent.trtcplugin.util.CommonUtil;
import com.tencent.trtcplugin.view.TRTCCloudVideoPlatformView;
import com.tencent.trtcplugin.view.TRTCCloudVideoSurfaceView;
import com.tencent.trtcplugin.view.CustomRenderVideoFrame;

import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.lang.reflect.Method;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.HashMap;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.plugin.platform.PlatformViewRegistry;

import io.flutter.view.TextureRegistry;

enum _FuRenderChannel {
    skin,
    shape,
    filter,
    makeUp,
    bodyBeauty
}

/**
 * 安卓中间层-腾讯云视频通话功能的主要接口类
 */
public class TRTCCloudPlugin implements FlutterPlugin, MethodCallHandler {
    /**
     * methodChannel标识
     */
    private static final String CHANNEL_SIGN = "trtcCloudChannel";
    private static final String TAG = "TRTCCloudFlutter";
    private FlutterPlugin.FlutterAssets flutterAssets;
    private TRTCCloud trtcCloud;
    private Context trtcContext;
    private TXDeviceManager txDeviceManager;
    private TXBeautyManager txBeautyManager;
    private TXAudioEffectManager txAudioEffectManager;
    private CustomTRTCCloudListener trtcListener;

    private TextureRegistry.SurfaceTextureEntry surfaceEntry;
    private TextureRegistry textureRegistry;
    private  _FuRenderChannel type;

    /**
     * 相芯-美体*/
    private BodyBeauty bodyBeauty() {
        return FURenderKit.getInstance().getBodyBeauty();
    }
    /**
     * 相芯-补妆*/
    private SimpleMakeup makeUp(){
        return FURenderKit.getInstance().getMakeup();
    }
    /**
     * 相芯-美颜*/
    private FaceBeauty beauty(){
        return FURenderKit.getInstance().getFaceBeauty();
    }

    public TRTCCloudPlugin() {
    }

    private TRTCCloudPlugin(
            BinaryMessenger messenger,
            Context context,
            MethodChannel channel,
            PlatformViewRegistry registry,
            FlutterPlugin.FlutterAssets flutterAssets, TextureRegistry textureRegistrya) {
        this.trtcContext = context;
        this.flutterAssets = flutterAssets;
        trtcListener = new CustomTRTCCloudListener(channel);
        registry.registerViewFactory(
                TRTCCloudVideoPlatformView.SIGN,
                new TRTCCloudVideoPlatformView(context, messenger));
        registry.registerViewFactory(
                TRTCCloudVideoSurfaceView.SIGN,
                new TRTCCloudVideoSurfaceView(context, messenger));
        registry.registerViewFactory(TRTCCloudVideoSurfaceView.bottomBar,
                new TRTCCloudVideoSurfaceView(context, messenger));

        this.textureRegistry = textureRegistrya;
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        final MethodChannel channel = new MethodChannel(
                flutterPluginBinding.getBinaryMessenger(),
                CHANNEL_SIGN);
        channel.setMethodCallHandler(new TRTCCloudPlugin(
                flutterPluginBinding.getBinaryMessenger(),
                flutterPluginBinding.getApplicationContext(),
                channel,
                flutterPluginBinding.getPlatformViewRegistry(),
                flutterPluginBinding.getFlutterAssets(), flutterPluginBinding.getTextureRegistry()));

    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    }

    public static void registerWith(Registrar registrar) {
        if (registrar.activity() == null) {
            return;
        }
        final MethodChannel channel = new MethodChannel(registrar.messenger(), CHANNEL_SIGN);
        channel.setMethodCallHandler(new TRTCCloudPlugin());

    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        TXLog.i(TAG, "|method=" + call.method + "|arguments=" + call.arguments);
        try {
            Method method = TRTCCloudPlugin.class.getDeclaredMethod(call.method,MethodCall.class,Result.class);
            method.invoke(this,call,result);
        } catch (NoSuchMethodException e) {
            TXLog.e(TAG, "|method=" + call.method + "|arguments=" + call.arguments + "|error=" + e);
        } catch (IllegalAccessException e) {
            TXLog.e(TAG, "|method=" + call.method + "|arguments=" + call.arguments + "|error=" + e);
        } catch (Exception e) {
            TXLog.e(TAG, "|method=" + call.method + "|arguments=" + call.arguments + "|error=" + e);
        }
    }

    private void FUSetUp(MethodCall call, Result result) {
        HashMap map = (HashMap)call.arguments();
        ArrayList<Integer> auth = (ArrayList<Integer>) map.get("authPack");
        try {
            FURenderer.getInstance().setup(trtcContext, auth);
            if (map.containsKey("maxFace")) {
                Integer maxFace = (Integer) map.get("maxFace");
                if (maxFace != null) {
                    FUAIKit.getInstance().setMaxFaces(maxFace);
                }
            }
            String key = "skin";
            if (map.containsKey(key) && map.get(key) instanceof HashMap) {
                HashMap skinMap = (HashMap) map.get(key);
                skin(skinMap);
            }
            key = "shape";
            if (map.containsKey(key) && map.get(key) instanceof HashMap) {
                HashMap shapeMap = (HashMap) map.get(key);
                shape(shapeMap);
            }
            key = "filter";
            if (map.containsKey(key) && map.get(key) instanceof HashMap) {
                HashMap filterMap = (HashMap) map.get(key);
                filter(filterMap);
            }
            key = "makeUp";
            if (map.containsKey(key) && map.get(key) instanceof HashMap) {
                HashMap makeUpMap = (HashMap) map.get(key);
                makeUp(makeUpMap);
            }
            key = "bodyBeauty";
            if (map.containsKey(key) && map.get(key) instanceof HashMap) {
                HashMap bodyBeautyMap = (HashMap) map.get(key);
                bodyBeauty(bodyBeautyMap);
            }


        }catch (Exception e) {

        }
    }

    private void setLicense(MethodCall call, Result result){
        HashMap map = (HashMap) call.arguments();
        //map["url"], let key = map["key"]
        String url = (String) map.get("url");
        String key = (String) map.get("key");
        TXLiveBase.getInstance().setLicence(trtcContext, url, key);
        result.success(null);
    }

    private void resetValue(){
        FUAIKit.getInstance().setMaxFaces(4);
        switch (this.type) {
            case makeUp:
                if (this.makeUp() == null)
                    return;
                this.makeUp().setEnable(true);
//                FURenderKit.getInstance().setMakeup(this.makeUp());
                break;
            case filter:
            case skin:
            case shape:
                if (this.beauty() == null)
                    return;
                this.beauty().setEnable(true);
//                FURenderKit.getInstance().setFaceBeauty(this.beauty());
                break;
            case bodyBeauty:
                if (this.bodyBeauty() == null)
                    return;
                this.bodyBeauty().setEnable(true);
//                FURenderKit.getInstance().setBodyBeauty(this.bodyBeauty());
                break;
        }
    }
    private void skin(MethodCall call,Result result){
        skin(call.arguments());
        result.success(null);
    }

    /**
     * 相芯-美肤*/
    private void skin(HashMap map){
        if (this.type != null && this.type != _FuRenderChannel.skin) {
            this.type = _FuRenderChannel.skin;
            this.resetValue();
        }else if (this.type == null) {
            this.type = _FuRenderChannel.skin;
            this.resetValue();
        }
        String key = "blurLevel";
        if (map.containsKey(key) && map.get(key) instanceof Double) {
            Double value = (Double) map.get(key);
            this.beauty().setBlurIntensity(value);
        }

        key = "colorLevel";
        if (map.containsKey(key) && map.get(key) instanceof Double) {
            Double value = (Double) map.get(key);
            this.beauty().setColorIntensity(value);
        }
        key = "redLevel";
        if (map.containsKey(key) && map.get(key) instanceof Double) {
            Double value = (Double) map.get(key);
            this.beauty().setRedIntensity(value);
        }
        key = "sharpen";
        if (map.containsKey(key) && map.get(key) instanceof Double) {
            Double value = (Double) map.get(key);
            this.beauty().setSharpenIntensity(value);
        }
        key = "eyeBright";
        if (map.containsKey(key) && map.get(key) instanceof Double) {
            Double value = (Double) map.get(key);
            this.beauty().setEyeBrightIntensity(value);
        }
        key = "toothWhiten";
        if (map.containsKey(key) && map.get(key) instanceof Double) {
            Double value = (Double) map.get(key);
            this.beauty().setToothIntensity(value);
        }
        key = "removePouchStrength";
        if (map.containsKey(key) && map.get(key) instanceof Double) {
            Double value = (Double) map.get(key);
            this.beauty().setRemovePouchIntensity(value);
        }
        key = "removeNasolabialFoldsStrength";
        if (map.containsKey(key) && map.get(key) instanceof Double) {
            Double value = (Double) map.get(key);
            this.beauty().setRemoveLawPatternIntensity(value);
        }
    }

    private void shape(MethodCall call,Result result){
        shape(call.arguments());
        result.success(null);
    }
    /**
     * 相芯-美型*/
    private void shape(HashMap map) {
        if (this.type != null && this.type != _FuRenderChannel.shape) {
            this.type = _FuRenderChannel.shape;
            this.resetValue();
        }else if (this.type == null) {
            this.type = _FuRenderChannel.shape;
            this.resetValue();
        }
        String key = "cheekThinning";
        if (map.containsKey(key) && map.get(key) instanceof Double) {
            Double value = (Double) map.get(key);
            this.beauty().setCheekThinningIntensity(value);
        }
        key = "cheekV";
        if (map.containsKey(key) && map.get(key) instanceof Double) {
            Double value = (Double) map.get(key);
            this.beauty().setCheekVIntensity(value);
        }
        key = "cheekNarrow";
        if (map.containsKey(key) && map.get(key) instanceof Double) {
            Double value = (Double) map.get(key);
            this.beauty().setCheekNarrowIntensity(value);
        }
        key = "cheekSmall";
        if (map.containsKey(key) && map.get(key) instanceof Double) {
            Double value = (Double) map.get(key);
            this.beauty().setCheekSmallIntensity(value);
        }
        key = "intensityCheekbones";
        if (map.containsKey(key) && map.get(key) instanceof Double) {
            Double value = (Double) map.get(key);
            this.beauty().setCheekBonesIntensity(value);
        }
        key = "intensityLowerJaw";
        if (map.containsKey(key) && map.get(key) instanceof Double) {
            Double value = (Double) map.get(key);
            this.beauty().setLowerJawIntensity(value);
        }
        key = "eyeEnlarging";
        if (map.containsKey(key) && map.get(key) instanceof Double) {
            Double value = (Double) map.get(key);
            this.beauty().setEyeEnlargingIntensity(value);
        }
        key = "intensityEyeCircle";
        if (map.containsKey(key) && map.get(key) instanceof Double) {
            Double value = (Double) map.get(key);
            this.beauty().setEyeCircleIntensity(value);
        }
        key = "intensityChin";
        if (map.containsKey(key) && map.get(key) instanceof Double) {
            Double value = (Double) map.get(key);
            this.beauty().setChinIntensity(value);
        }
        key = "intensityForehead";
        if (map.containsKey(key) && map.get(key) instanceof Double) {
            Double value = (Double) map.get(key);
            this.beauty().setForHeadIntensity(value);
        }
        key = "intensityNose";
        if (map.containsKey(key) && map.get(key) instanceof Double) {
            Double value = (Double) map.get(key);
            this.beauty().setNoseIntensity(value);
        }
        key = "intensityMouth";
        if (map.containsKey(key) && map.get(key) instanceof Double) {
            Double value = (Double) map.get(key);
            this.beauty().setMouthIntensity(value);
        }
        key = "intensityCanthus";
        if (map.containsKey(key) && map.get(key) instanceof Double) {
            Double value = (Double) map.get(key);
            this.beauty().setCanthusIntensity(value);
        }
        key = "intensityEyeSpace";
        if (map.containsKey(key) && map.get(key) instanceof Double) {
            Double value = (Double) map.get(key);
            this.beauty().setEyeSpaceIntensity(value);
        }
        key = "intensityEyeRotate";
        if (map.containsKey(key) && map.get(key) instanceof Double) {
            Double value = (Double) map.get(key);
            this.beauty().setEyeRotateIntensity(value);
        }
        key = "intensityLongNose";
        if (map.containsKey(key) && map.get(key) instanceof Double) {
            Double value = (Double) map.get(key);
            this.beauty().setLongNoseIntensity(value);
        }
        key = "intensityPhiltrum";
        if (map.containsKey(key) && map.get(key) instanceof Double) {
            Double value = (Double) map.get(key);
            this.beauty().setPhiltrumIntensity(value);
        }
        key = "intensitySmile";
        if (map.containsKey(key) && map.get(key) instanceof Double) {
            Double value = (Double) map.get(key);
            this.beauty().setSmileIntensity(value);
        }
    }

    private void filter(MethodCall call,Result result){
        filter(call.arguments());
        result.success(null);
    }
    /**
     * 滤镜*/
    private void filter(HashMap map) {
        if (this.type != null && this.type != _FuRenderChannel.filter) {
            this.type = _FuRenderChannel.filter;
            this.resetValue();
        }else if (this.type == null) {
            this.type = _FuRenderChannel.filter;
            this.resetValue();
        }
        String key = "imageName";
        if (map.containsKey(key) && map.get(key) instanceof String) {
            String value = (String) map.get(key);
            this.beauty().setFilterName(value);
        }
        key = "filterLevel";
        if (map.containsKey(key) && map.get(key) instanceof Double) {
            Double value = (Double) map.get(key);
            this.beauty().setFilterIntensity(value);
        }
    }

    private void makeUp(MethodCall call,Result result){
        makeUp(call.arguments());
        result.success(null);
    }
    /**
     * 相芯-补妆*/
    private void makeUp(HashMap map) {
        if (this.type != null && this.type != _FuRenderChannel.makeUp) {
            this.type = _FuRenderChannel.makeUp;
            this.resetValue();
        }else if (this.type == null) {
            this.type = _FuRenderChannel.makeUp;
            this.resetValue();
        }
        String key = "imageName";
        if (map.containsKey(key) && map.get(key) instanceof String) {
            String value = (String) map.get(key);
            if (value == null) {
                this.makeUp().setCombinedConfig(null);
                return;
            }
            this.makeUp().setCombinedConfig(new FUBundleData("makeup/"+ value + ".bundle"));
        }
        key = "intensity";
        if (map.containsKey(key) && map.get(key) instanceof Double) {
            Double value = (Double) map.get(key);
            this.makeUp().setMakeupIntensity(value);
        }
    }

    private void bodyBeauty(MethodCall call,Result result){
        bodyBeauty(call.arguments());
        result.success(null);
    }
    /**
     * 相芯-美体*/
    private void bodyBeauty(HashMap map){
        if (this.type != null && this.type != _FuRenderChannel.bodyBeauty) {
            this.type = _FuRenderChannel.bodyBeauty;
            this.resetValue();
        }else if (this.type == null) {
            this.type = _FuRenderChannel.bodyBeauty;
            this.resetValue();
        }
        String key = "bodySlimStrength";
        if (map.containsKey(key) && map.get(key) instanceof Double) {
            Double value = (Double) map.get(key);
            this.bodyBeauty().setBodySlimIntensity(value);
        }
        key = "legSlimStrength";
        if (map.containsKey(key) && map.get(key) instanceof Double) {
            Double value = (Double) map.get(key);
            this.bodyBeauty().setLegSlimIntensity(value);
        }
        key = "waistSlimStrength";
        if (map.containsKey(key) && map.get(key) instanceof Double) {
            Double value = (Double) map.get(key);
            this.bodyBeauty().setWaistSlimIntensity(value);
        }
        key = "shoulderSlimStrength";
        if (map.containsKey(key) && map.get(key) instanceof Double) {
            Double value = (Double) map.get(key);
            this.bodyBeauty().setShoulderSlimIntensity(value);
        }
        key = "bodySlimStrength";
        if (map.containsKey(key) && map.get(key) instanceof Double) {
            Double value = (Double) map.get(key);
            this.bodyBeauty().setBodySlimIntensity(value);
        }
        key = "headSlim";
        if (map.containsKey(key) && map.get(key) instanceof Double) {
            Double value = (Double) map.get(key);
            this.bodyBeauty().setHeadSlimIntensity(value);
        }
        key = "legSlim";
        if (map.containsKey(key) && map.get(key) instanceof Double) {
            Double value = (Double) map.get(key);
            this.bodyBeauty().setLegSlimIntensity(value);
        }
    }

    /**
     * 创建 TRTCCloud 单例
     */
    private void sharedInstance(MethodCall call, Result result) {
        // 初始化实例
        trtcCloud = TRTCCloud.sharedInstance(trtcContext);
        trtcCloud.setListener(trtcListener);
        result.success(null);
    }

    /**
     * 销毁 TRTCCloud 单例
     */
    private void destroySharedInstance(MethodCall call, Result result) {
        TRTCCloud.destroySharedInstance();
        trtcCloud = null;
        result.success(null);
    }

    /**
     * 进入房间
     */
    private void enterRoom(MethodCall call, Result result) {
        //房间号大于2147483647时，两个人进房互相看不到
        //TRTCCloudDef.TRTCParams trtcP = new Gson().fromJson(param, TRTCCloudDef.TRTCParams.class);
        TRTCCloudDef.TRTCParams trtcP = new TRTCCloudDef.TRTCParams();
        trtcP.sdkAppId = CommonUtil.getParam(call, result, "sdkAppId");
        trtcP.userId = CommonUtil.getParam(call, result, "userId");
        trtcP.userSig = CommonUtil.getParam(call, result, "userSig");
        String roomId = CommonUtil.getParam(call, result, "roomId");
        trtcP.roomId = (int) (Long.parseLong(roomId) & 0xFFFFFFFF);
        trtcP.strRoomId = CommonUtil.getParam(call, result, "strRoomId");
        trtcP.role = CommonUtil.getParam(call, result, "role");
        trtcP.streamId = CommonUtil.getParam(call, result, "streamId");
        trtcP.userDefineRecordId = CommonUtil.getParam(call, result, "userDefineRecordId");
        trtcP.privateMapKey = CommonUtil.getParam(call, result, "privateMapKey");

        int scene = CommonUtil.getParam(call, result, "scene");
        trtcCloud.enterRoom(trtcP, scene);
        result.success(null);
    }
    
    /**
     * 离开房间
     */
    private void exitRoom(MethodCall call, Result result) {
        trtcCloud.exitRoom();
        result.success(null);
    }

    /**
     * 跨房通话
     */
    private void connectOtherRoom(MethodCall call, Result result) {
        String param = CommonUtil.getParam(call, result, "param");
        trtcCloud.ConnectOtherRoom(param);
        result.success(null);
    }

    /**
     * 退出跨房通话
     */
    private void disconnectOtherRoom(MethodCall call, Result result) {
        trtcCloud.DisconnectOtherRoom();
        result.success(null);
    }

    /**
     * 切换角色，仅适用于直播场景（TRTC_APP_SCENE_LIVE 和 TRTC_APP_SCENE_VOICE_CHATROOM）
     */
    private void switchRole(MethodCall call, Result result) {
        int role = CommonUtil.getParam(call, result, "role");
        trtcCloud.switchRole(role);
        result.success(null);
    }

    /**
     * 设置音视频数据接收模式，需要在进房前设置才能生效
     */
    private void setDefaultStreamRecvMode(MethodCall call, Result result) {
        boolean autoRecvAudio = CommonUtil.getParam(call, result, "autoRecvAudio");
        boolean autoRecvVideo = CommonUtil.getParam(call, result, "autoRecvVideo");
        trtcCloud.setDefaultStreamRecvMode(autoRecvAudio, autoRecvVideo);
        result.success(null);
    }

    /**
     * 切换房间
     */
    private void switchRoom(MethodCall call, Result result) {
        String config = CommonUtil.getParam(call, result, "config");
        trtcCloud.switchRoom(new Gson().fromJson(config, TRTCCloudDef.TRTCSwitchRoomConfig.class));
        result.success(null);
    }

    /**
     * 开始向腾讯云的直播 CDN 推流
     */
    private void startPublishing(MethodCall call, Result result) {
        String streamId = CommonUtil.getParam(call, result, "streamId");
        int streamType = CommonUtil.getParam(call, result, "streamType");
        trtcCloud.startPublishing(streamId, streamType);
        result.success(null);
    }

    /**
     * 停止向腾讯云的直播 CDN 推流
     */
    private void stopPublishing(MethodCall call, Result result) {
        trtcCloud.stopPublishing();
        result.success(null);
    }

    /**
     * 开始向腾讯云的直播 CDN 推流
     */
    private void startPublishCDNStream(MethodCall call, Result result) {
        String param = CommonUtil.getParam(call, result, "param");
        trtcCloud.startPublishCDNStream(new Gson().fromJson(param, TRTCCloudDef.TRTCPublishCDNParam.class));
        result.success(null);
    }

    /**
     * 停止向非腾讯云地址转推
     */
    private void stopPublishCDNStream(MethodCall call, Result result) {
        trtcCloud.stopPublishCDNStream();
        result.success(null);
    }

    /**
     * 设置云端的混流转码参数
     */
    private void setMixTranscodingConfig(MethodCall call, Result result) {
        String config = CommonUtil.getParam(call, result, "config");
        trtcCloud.setMixTranscodingConfig(new Gson().fromJson(config, TRTCCloudDef.TRTCTranscodingConfig.class));
        result.success(null);
    }

    /**
     * 停止本地视频采集及预览
     */
    private void stopLocalPreview(MethodCall call, Result result) {
        trtcCloud.stopLocalPreview();
        result.success(null);
    }

    /**
     * 停止显示远端视频画面，同时不再拉取该远端用户的视频数据流
     */
    private void stopRemoteView(MethodCall call, Result result) {
        String userId = CommonUtil.getParam(call, result, "userId");
        int streamType = CommonUtil.getParam(call, result, "streamType");
        trtcCloud.stopRemoteView(userId, streamType);
        result.success(null);
    }

    /**
     * 停止显示所有远端视频画面，同时不再拉取远端用户的视频数据流
     */
    private void stopAllRemoteView(MethodCall call, Result result) {
        trtcCloud.stopAllRemoteView();
        result.success(null);
    }

    /**
     * 静音/取消静音指定的远端用户的声音
     */
    private void muteRemoteAudio(MethodCall call, Result result) {
        String userId = CommonUtil.getParam(call, result, "userId");
        boolean mute = CommonUtil.getParam(call, result, "mute");
        trtcCloud.muteRemoteAudio(userId, mute);
        result.success(null);
    }

    /**
     * 静音/取消静音所有用户的声音
     */
    private void muteAllRemoteAudio(MethodCall call, Result result) {
        boolean mute = CommonUtil.getParam(call, result, "mute");
        trtcCloud.muteAllRemoteAudio(mute);
        result.success(null);
    }

    /**
     * 设置某个远程用户的播放音量
     */
    private void setRemoteAudioVolume(MethodCall call, Result result) {
        String userId = CommonUtil.getParam(call, result, "userId");
        int volume = CommonUtil.getParam(call, result, "volume");
        trtcCloud.setRemoteAudioVolume(userId, volume);
        result.success(null);
    }

    /**
     * 设置 SDK 采集音量。
     */
    private void setAudioCaptureVolume(MethodCall call, Result result) {
        int volume = CommonUtil.getParam(call, result, "volume");
        trtcCloud.setAudioCaptureVolume(volume);
        result.success(null);
    }

    /**
     * 获取 SDK 采集音量。
     */
    private void getAudioCaptureVolume(MethodCall call, Result result) {
        result.success(trtcCloud.getAudioCaptureVolume());
    }

    /**
     * 设置 SDK 播放音量。
     */
    private void setAudioPlayoutVolume(MethodCall call, Result result) {
        int volume = CommonUtil.getParam(call, result, "volume");
        trtcCloud.setAudioPlayoutVolume(volume);
        result.success(null);
    }

    /**
     * 获取 SDK 播放音量。
     */
    private void getAudioPlayoutVolume(MethodCall call, Result result) {
        result.success(trtcCloud.getAudioPlayoutVolume());
    }

    /**
     * 开启本地音频的采集和上行
     */
    private void startLocalAudio(MethodCall call, Result result) {
        int quality = CommonUtil.getParam(call, result, "quality");
        trtcCloud.startLocalAudio(quality);
        result.success(null);
    }

    /**
     * 关闭本地音频的采集和上行
     */
    private void stopLocalAudio(MethodCall call, Result result) {
        trtcCloud.stopLocalAudio();
        result.success(null);
    }

    /**
     * 暂停/恢复接收指定的远端视频流
     */
    private void muteRemoteVideoStream(MethodCall call, Result result) {
        String userId = CommonUtil.getParam(call, result, "userId");
        boolean mute = CommonUtil.getParam(call, result, "mute");
        trtcCloud.muteRemoteVideoStream(userId, mute);
        result.success(null);
    }

    /**
     * 暂停/恢复接收所有远端视频流
     */
    private void muteAllRemoteVideoStreams(MethodCall call, Result result) {
        boolean mute = CommonUtil.getParam(call, result, "mute");
        trtcCloud.muteAllRemoteVideoStreams(mute);
//        TXLiveBase.getInstance().setLicence(trtcContext, "", "");
        result.success(null);
    }

    /**
     * 设置视频编码器相关参数
     * 该设置决定了远端用户看到的画面质量（同时也是云端录制出的视频文件的画面质量）
     */
    private void setVideoEncoderParam(MethodCall call, Result result) {
        String param = CommonUtil.getParam(call, result, "param");
        trtcCloud.setVideoEncoderParam(new Gson().fromJson(param, TRTCCloudDef.TRTCVideoEncParam.class));
        result.success(null);
    }

    /**
     * 设置网络流控相关参数。
     * 该设置决定 SDK 在各种网络环境下的调控策略（例如弱网下选择“保清晰”或“保流畅”）
     */
    private void setNetworkQosParam(MethodCall call, Result result) {
        String param = CommonUtil.getParam(call, result, "param");
        trtcCloud.setNetworkQosParam(new Gson().fromJson(param, TRTCCloudDef.TRTCNetworkQosParam.class));
        result.success(null);
    }

    /**
     * 设置本地图像的渲染模式。
     */
    private void setLocalRenderParams(MethodCall call, Result result) {
        String param = CommonUtil.getParam(call, result, "param");
        trtcCloud.setLocalRenderParams(new Gson().fromJson(param, TRTCCloudDef.TRTCRenderParams.class));
        result.success(null);
    }

    /**
     * 设置远端图像的渲染模式。
     */
    private void setRemoteRenderParams(MethodCall call, Result result) {
        String userId = CommonUtil.getParam(call, result, "userId");
        int streamType = CommonUtil.getParam(call, result, "streamType");
        String param = CommonUtil.getParam(call, result, "param");
        trtcCloud.setRemoteRenderParams(
                userId,
                streamType,
                new Gson().fromJson(param, TRTCCloudDef.TRTCRenderParams.class));
        result.success(null);
    }

    /**
     * 设置视频编码输出的画面方向，即设置远端用户观看到的和服务器录制的画面方向
     */
    private void setVideoEncoderRotation(MethodCall call, Result result) {
        int rotation = CommonUtil.getParam(call, result, "rotation");
        trtcCloud.setVideoEncoderRotation(rotation);
        result.success(null);
    }

    /**
     * 设置编码器输出的画面镜像模式。
     */
    private void setVideoEncoderMirror(MethodCall call, Result result) {
        boolean mirror = CommonUtil.getParam(call, result, "mirror");
        trtcCloud.setVideoEncoderMirror(mirror);
        result.success(null);
    }

    /**
     * 设置重力感应的适应模式。
     */
    private void setGSensorMode(MethodCall call, Result result) {
        int mode = CommonUtil.getParam(call, result, "mode");
        trtcCloud.setGSensorMode(mode);
        result.success(null);
    }

    /**
     * 开启大小画面双路编码模式。
     */
    private void enableEncSmallVideoStream(MethodCall call, Result result) {
        boolean enable = CommonUtil.getParam(call, result, "enable");
        String smallVideoEncParam = CommonUtil.getParam(call, result, "smallVideoEncParam");
        int value = trtcCloud.enableEncSmallVideoStream(
                enable,
                new Gson().fromJson(smallVideoEncParam, TRTCCloudDef.TRTCVideoEncParam.class));
        result.success(value);
    }

    /**
     * 选定观看指定 uid 的大画面或小画面。
     */
    private void setRemoteVideoStreamType(MethodCall call, Result result) {
        String userId = CommonUtil.getParam(call, result, "userId");
        int streamType = CommonUtil.getParam(call, result, "streamType");
        int value = trtcCloud.setRemoteVideoStreamType(userId, streamType);
        result.success(value);
    }

//    private Integer getBitmapPixelDataMemoryPtr(JNIEnv *env, jclass clazz, jobject bitmap) {
//        AndroidBitmapInfo bitmapInfo;
//        int ret;
//        if ((ret = AndroidBitmap_getInfo(env, bitmap, &bitmapInfo)) < 0) {
//            LOGE("AndroidBitmap_getInfo() failed ! error=%d", ret);
//            return 0;
//        }
//        // 读取 bitmap 的像素数据块到 native 内存地址
//        void *addPtr;
//        if ((ret = AndroidBitmap_lockPixels(env, bitmap, &addPtr)) < 0) {
//            LOGE("AndroidBitmap_lockPixels() failed ! error=%d", ret);
//            return 0;
//        }
//        //unlock，保证不因这里获取地址导致bitmap被锁定
//        AndroidBitmap_unlockPixels(env, bitmap);
//        return (jlong)addPtr;
//    }

    /**
     * 视频画面截图
     */
    private void snapshotVideo(MethodCall call, final Result result) {
        String userId = CommonUtil.getParamCanBeNull(call, result, "userId");
        int streamType = CommonUtil.getParam(call, result, "streamType");
        final String path = CommonUtil.getParam(call, result, "path");

        trtcCloud.snapshotVideo(userId, streamType, new TRTCCloudListener.TRTCSnapshotListener() {
            @Override
            public void onSnapshotComplete(Bitmap bitmap) {
                try {
                    String[] pathArr = path.split("\\.");
                    Bitmap.CompressFormat bitComp = Bitmap.CompressFormat.PNG;
                    if (pathArr[pathArr.length - 1].equals("jpg")) {
                        bitComp = Bitmap.CompressFormat.JPEG;
                    } else if (pathArr[pathArr.length - 1].equals("webp")) {
                        bitComp = Bitmap.CompressFormat.WEBP;
                    }
                    FileOutputStream fos = new FileOutputStream(path);
                    boolean isSuccess = bitmap.compress(bitComp, 100, fos);
                    if (isSuccess) {
                        trtcListener.onSnapshotComplete(0, "success", path);
                    } else {
                        trtcListener.onSnapshotComplete(-101,"bitmap compress failed", null);
                    }

                } catch (FileNotFoundException e) {
                    TXLog.e(TAG,"|method=snapshotVideo|error=" + e);
                    trtcListener.onSnapshotComplete(-102,e.toString(), null);
                } catch (Exception e) {
                    TXLog.e(TAG,"|method=snapshotVideo|error=" + e);
                    trtcListener.onSnapshotComplete(-103,e.toString(), null);
                }
            }
        });

        result.success(null);
    }

    // 设置本地视频的自定义渲染回调
    private void setLocalVideoRenderListener(MethodCall call, final Result result) {
        boolean isFront = CommonUtil.getParam(call, result, "isFront");
        trtcCloud.startLocalPreview(isFront, null);
        surfaceEntry = textureRegistry.createSurfaceTexture();
        SurfaceTexture surfaceTexture = surfaceEntry.surfaceTexture();
        String userId = CommonUtil.getParam(call, result, "userId");
        int streamType = CommonUtil.getParam(call, result, "streamType");
        int width = CommonUtil.getParam(call, result, "width");
        int height = CommonUtil.getParam(call, result, "height");
        surfaceTexture.setDefaultBufferSize(width, height);
        CustomRenderVideoFrame customRender =  new CustomRenderVideoFrame(userId, streamType);
        int pixelFormat = TRTCCloudDef.TRTC_VIDEO_PIXEL_FORMAT_Texture_2D;
        int bufferType = TRTCCloudDef.TRTC_VIDEO_BUFFER_TYPE_TEXTURE;
        trtcCloud.setLocalVideoRenderListener(pixelFormat, bufferType, customRender);
        customRender.start(surfaceTexture, width, height);
        result.success(surfaceEntry.id());
    }

    // 设置远端视频的自定义渲染回调
    private void setRemoteVideoRenderListener(MethodCall call, final Result result) {
        String userId = CommonUtil.getParam(call, result, "userId");
        int streamType = CommonUtil.getParam(call, result, "streamType");
        int width = CommonUtil.getParam(call, result, "width");
        int height = CommonUtil.getParam(call, result, "height");
        trtcCloud.startRemoteView(userId, streamType, null);
        surfaceEntry = textureRegistry.createSurfaceTexture();
        SurfaceTexture surfaceTexture = surfaceEntry.surfaceTexture();
        surfaceTexture.setDefaultBufferSize(width, height);
        CustomRenderVideoFrame customRender =  new CustomRenderVideoFrame(userId, streamType);
        int pixelFormat = TRTCCloudDef.TRTC_VIDEO_PIXEL_FORMAT_Texture_2D;
        int bufferType = TRTCCloudDef.TRTC_VIDEO_BUFFER_TYPE_TEXTURE;
        trtcCloud.setRemoteVideoRenderListener(userId, pixelFormat, bufferType, customRender);
        customRender.start(surfaceTexture, width, height);
        result.success(surfaceEntry.id());
    }

    /**
     * 静音/取消静音本地的音频
     */
    private void muteLocalAudio(MethodCall call, Result result) {
        boolean mute = CommonUtil.getParam(call, result, "mute");
        trtcCloud.muteLocalAudio(mute);
        result.success(null);
    }

    /**
     * 暂停/恢复推送本地的视频数据
     */
    private void muteLocalVideo(MethodCall call, Result result) {
        boolean mute = CommonUtil.getParam(call, result, "mute");
        trtcCloud.muteLocalVideo(mute);
        result.success(null);
    }

    /**
     * 设置暂停推送本地视频时要推送的图片
     */
    private void setVideoMuteImage(MethodCall call, final Result result) {
        String type = CommonUtil.getParam(call, result, "type");
        final String imageUrl = CommonUtil.getParamCanBeNull(call, result, "imageUrl");
        final int fps = CommonUtil.getParam(call, result, "fps");
        if (imageUrl == null) {
            trtcCloud.setVideoMuteImage(null, fps);
        } else {
            if (type.equals("network")) {
                new Thread() {
                    @Override
                    public void run() {
                        try {
                            URL url = new URL(imageUrl);
                            HttpURLConnection connection = (HttpURLConnection) url.openConnection();
                            connection.setDoInput(true);
                            connection.connect();
                            InputStream input = connection.getInputStream();
                            Bitmap myBitmap = BitmapFactory.decodeStream(input);
                            trtcCloud.setVideoMuteImage(myBitmap, fps);
                        } catch (IOException e) {
                            TXLog.e(TAG, "|method=setVideoMuteImage|error=" + e);
                        }
                    }
                }.start();
            } else {
                try {
                    String path = flutterAssets.getAssetFilePathByName(imageUrl);
                    AssetManager mAssetManger = trtcContext.getAssets();
                    InputStream mystream = mAssetManger.open(path);
                    Bitmap myBitmap = BitmapFactory.decodeStream(mystream);
                    trtcCloud.setVideoMuteImage(myBitmap, fps);
                } catch (Exception e) {
                    TXLog.e(TAG, "|method=setVideoMuteImage|error=" + e);
                }
            }
        }
        result.success(null);
    }

    /**
     * 设置音频路由。
     */
    private void setAudioRoute(MethodCall call, Result result) {
        int route = CommonUtil.getParam(call, result, "route");
        trtcCloud.setAudioRoute(route);
        result.success(null);
    }

    /**
     * 启用音量大小提示。
     */
    private void enableAudioVolumeEvaluation(MethodCall call, Result result) {
        int intervalMs = CommonUtil.getParam(call, result, "intervalMs");
        trtcCloud.enableAudioVolumeEvaluation(intervalMs);
        result.success(null);
    }

    /**
     * 开始录音。
     */
    private void startAudioRecording(MethodCall call, Result result) {
        String param = CommonUtil.getParam(call, result, "param");
        int value = trtcCloud.startAudioRecording(
                new Gson().fromJson(param, TRTCCloudDef.TRTCAudioRecordingParams.class));
        result.success(value);
    }

    /**
     * 停止录音。
     */
    private void stopAudioRecording(MethodCall call, Result result) {
        trtcCloud.stopAudioRecording();
        result.success(null);
    }

    /**
     * 设置通话时使用的系统音量类型。
     */
    private void setSystemVolumeType(MethodCall call, Result result) {
        int type = CommonUtil.getParam(call, result, "type");
        trtcCloud.setSystemVolumeType(type);
        result.success(null);
    }

    /**
     * 查询是否是前置摄像头
     */
    private void isFrontCamera(MethodCall call, Result result) {
        result.success(txDeviceManager.isFrontCamera());
    }

    /**
     * 切换摄像头。
     */
    private void switchCamera(MethodCall call, Result result) {
        boolean isFrontCamera = CommonUtil.getParam(call, result, "isFrontCamera");
        result.success(txDeviceManager.switchCamera(isFrontCamera));
    }

    /**
     * 获取摄像头的缩放因子。
     */
    private void getCameraZoomMaxRatio(MethodCall call, Result result) {
        result.success(txDeviceManager.getCameraZoomMaxRatio());
    }

    /**
     * 设置摄像头缩放因子（焦距）。
     */
    private void setCameraZoomRatio(MethodCall call, Result result) {
        String value = CommonUtil.getParam(call, result, "value");
        float ratioValue = Float.parseFloat(value);
        result.success(txDeviceManager.setCameraZoomRatio(ratioValue));
    }

    /**
     * 设置是否自动识别人脸位置
     */
    private void enableCameraAutoFocus(MethodCall call, Result result) {
        boolean enable = CommonUtil.getParam(call, result, "enable");
        result.success(txDeviceManager.enableCameraAutoFocus(enable));
    }

    /**
     * 查询是否支持自动识别人脸位置。
     */
    private void isAutoFocusEnabled(MethodCall call, Result result) {
        result.success(txDeviceManager.isAutoFocusEnabled());
    }

    /**
     * 开启闪光灯
     */
    private void enableCameraTorch(MethodCall call, Result result) {
        boolean enable = CommonUtil.getParam(call, result, "enable");
        result.success(txDeviceManager.enableCameraTorch(enable));
    }

    /**
     * 设置摄像头焦点。
     */
    private void setCameraFocusPosition(MethodCall call, Result result) {
        int x = CommonUtil.getParam(call, result, "x");
        int y = CommonUtil.getParam(call, result, "y");
        txDeviceManager.setCameraFocusPosition(x, y);
        result.success(null);
    }

    //获取设备管理对象
    private void getDeviceManager(MethodCall call, Result result) {
        txDeviceManager = trtcCloud.getDeviceManager();
    }

    //获取美颜管理对象
    private void getBeautyManager(MethodCall call, Result result) {
        txBeautyManager = trtcCloud.getBeautyManager();
    }

    //获取音效管理类 TXAudioEffectManager
    private void getAudioEffectManager(MethodCall call, Result result) {
        txAudioEffectManager = trtcCloud.getAudioEffectManager();
    }

    //启动屏幕分享
    private void startScreenCapture(MethodCall call, Result result) {
        String encParams = CommonUtil.getParam(call, result, "encParams");
        trtcCloud.startScreenCapture(new Gson().fromJson(encParams, TRTCCloudDef.TRTCVideoEncParam.class),null);
        result.success(null);
    }

    //停止屏幕采集
    private void stopScreenCapture(MethodCall call, Result result) {
        trtcCloud.stopScreenCapture();
        result.success(null);
    }

    //暂停屏幕分享
    private void pauseScreenCapture(MethodCall call, Result result) {
        trtcCloud.pauseScreenCapture();
        result.success(null);
    }

    //恢复屏幕分享
    private void resumeScreenCapture(MethodCall call, Result result) {
        trtcCloud.resumeScreenCapture();
        result.success(null);
    }

    /**
     * 添加水印
     */
    private void setWatermark(MethodCall call, Result result) {
        final String imageUrl = CommonUtil.getParam(call, result, "imageUrl");
        String type = CommonUtil.getParam(call, result, "type");
        final int streamType = CommonUtil.getParam(call, result, "streamType");
        String xStr = CommonUtil.getParam(call, result, "x");
        final float x = Float.parseFloat(xStr);
        String yStr = CommonUtil.getParam(call, result, "y");
        final float y = Float.parseFloat(yStr);
        String widthStr = CommonUtil.getParam(call, result, "width");
        final float width = Float.parseFloat(widthStr);
        if (type.equals("network")) {
            new Thread() {
                @Override
                public void run() {
                    try {
                        URL url = new URL(imageUrl);
                        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
                        connection.setDoInput(true);
                        connection.connect();
                        InputStream input = connection.getInputStream();
                        Bitmap myBitmap = BitmapFactory.decodeStream(input);
                        trtcCloud.setWatermark(myBitmap, streamType, x, y, width);
                    } catch (IOException e) {
                        TXLog.e(TAG,"|method=setWatermark|error=" + e);
                    }
                }
            }.start();
        } else {
            try {
                Bitmap myBitmap;
                //文档目录或sdcard图片
                if (imageUrl.startsWith("/")) {
                    myBitmap = BitmapFactory.decodeFile(imageUrl);
                } else {
                    String path = flutterAssets.getAssetFilePathByName(imageUrl);
                    AssetManager mAssetManger = trtcContext.getAssets();
                    InputStream mystream = mAssetManger.open(path);
                    myBitmap = BitmapFactory.decodeStream(mystream);
                }
                trtcCloud.setWatermark(myBitmap, streamType, x, y, width);
            } catch (Exception e) {
                TXLog.e(TAG,"|method=setWatermark|error=" + e);
            }
        }
        result.success(null);
    }

    /**
     * 发送自定义消息给房间内所有用户
     */
    private void sendCustomCmdMsg(MethodCall call, Result result) {
        int cmdID = CommonUtil.getParam(call, result, "cmdID");
        String data = CommonUtil.getParam(call, result, "data");
        boolean reliable = CommonUtil.getParam(call, result, "reliable");
        boolean ordered = CommonUtil.getParam(call, result, "ordered");
        boolean value = trtcCloud.sendCustomCmdMsg(cmdID, data.getBytes(), reliable, ordered);
        result.success(value);
    }

    /**
     * 将小数据量的自定义数据嵌入视频帧中
     */
    private void sendSEIMsg(MethodCall call, Result result) {
        String data = CommonUtil.getParam(call, result, "data");
        int repeatCount = CommonUtil.getParam(call, result, "repeatCount");
        boolean value = trtcCloud.sendSEIMsg(data.getBytes(), repeatCount);
        result.success(value);
    }

    /**
     * 开始进行网络测速（视频通话期间请勿测试，以免影响通话质量）
     */
    private void startSpeedTest(MethodCall call, Result result) {
        int sdkAppId = CommonUtil.getParam(call, result, "sdkAppId");
        String userId = CommonUtil.getParam(call, result, "userId");
        String userSig = CommonUtil.getParam(call, result, "userSig");
        trtcCloud.startSpeedTest(sdkAppId,userId,userSig);
        result.success(null);
    }

    /**
     * 停止服务器测速
     */
    private void stopSpeedTest(MethodCall call, Result result) {
        trtcCloud.stopSpeedTest();
        result.success(null);
    }

    /**
     * 获取 SDK 版本信息
     */
    private void getSDKVersion(MethodCall call, Result result) {
        result.success(trtcCloud.getSDKVersion());
    }

    /**
     * 设置 Log 输出级别
     */
    private void setLogLevel(MethodCall call, Result result) {
        int level = CommonUtil.getParam(call, result, "level");
        trtcCloud.setLogLevel(level);
        result.success(null);
    }

    /**
     * 启用或禁用控制台日志打印
     */
    private void setConsoleEnabled(MethodCall call, Result result) {
        boolean enabled = CommonUtil.getParam(call, result, "enabled");
        TRTCCloud.setConsoleEnabled(enabled);
        result.success(null);
    }

    /**
     * 修改日志保存路径
     */
    private void setLogDirPath(MethodCall call, Result result) {
        String path = CommonUtil.getParam(call, result, "path");
        TRTCCloud.setLogDirPath(path);
        result.success(null);
    }

    /**
     * 启用或禁用 Log 的本地压缩。
     */
    private void setLogCompressEnabled(MethodCall call, Result result) {
        boolean enabled = CommonUtil.getParam(call, result, "enabled");
        TRTCCloud.setLogCompressEnabled(enabled);
        result.success(null);
    }

    /**
     * 显示仪表盘
     * 仪表盘是状态统计和事件消息浮层　view，方便调试
     */
    private void showDebugView(MethodCall call, Result result) {
        int mode = CommonUtil.getParam(call, result, "mode");
        trtcCloud.showDebugView(mode);
        result.success(null);
    }

    // 调用实验性 API 接口
    private void callExperimentalAPI(MethodCall call, Result result) {
        String jsonStr = CommonUtil.getParam(call, result, "jsonStr");
        trtcCloud.callExperimentalAPI(jsonStr);
        result.success(null);
    }

    /**
     * 设置美颜类型
     */
    private void setBeautyStyle(MethodCall call, Result result) {
        int beautyStyle = CommonUtil.getParam(call, result, "beautyStyle");
        txBeautyManager.setBeautyStyle(beautyStyle);
        result.success(null);
    }

    /**
     * 设置指定素材滤镜特效
     */
    private void setFilter(MethodCall call, final Result result) {
        String type = CommonUtil.getParam(call, result, "type");
        final String imageUrl = CommonUtil.getParam(call, result, "imageUrl");
        if (type.equals("network")) {
            new Thread() {
                @Override
                public void run() {
                    try {
                        URL url = new URL(imageUrl);
                        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
                        connection.setDoInput(true);
                        connection.connect();
                        InputStream input = connection.getInputStream();
                        Bitmap myBitmap = BitmapFactory.decodeStream(input);
                        txBeautyManager.setFilter(myBitmap);
                    } catch (IOException e) {
                        TXLog.e(TAG,"|method=setFilter|error=" + e);
                    }
                }
            }.start();
        } else {
            try {
                Bitmap myBitmap;
                //文档目录或sdcard图片
                if (imageUrl.startsWith("/")) {
                    myBitmap = BitmapFactory.decodeFile(imageUrl);
                } else {
                    String path = flutterAssets.getAssetFilePathByName(imageUrl);
                    AssetManager mAssetManger = trtcContext.getAssets();
                    InputStream mystream = mAssetManger.open(path);
                    myBitmap = BitmapFactory.decodeStream(mystream);
                }
                txBeautyManager.setFilter(myBitmap);

            } catch (Exception e) {
                TXLog.e(TAG,"|method=setFilter|error=" + e);
            }
        }
        result.success(null);
    }

    /**
     * 设置滤镜浓度
     */
    private void setFilterStrength(MethodCall call, Result result) {
        String strength = CommonUtil.getParam(call, result, "strength");
        float strengthFloat = Float.parseFloat(strength);
        txBeautyManager.setFilterStrength(strengthFloat);
        result.success(null);
    }

    /**
     * 设置美颜级别
     */
    private void setBeautyLevel(MethodCall call, Result result) {
        int beautyLevel = CommonUtil.getParam(call, result, "beautyLevel");
        txBeautyManager.setBeautyLevel(beautyLevel);
        result.success(null);
    }

    /**
     * 设置美白级别
     */
    private void setWhitenessLevel(MethodCall call, Result result) {
        int whitenessLevel = CommonUtil.getParam(call, result, "whitenessLevel");
        txBeautyManager.setWhitenessLevel(whitenessLevel);
        result.success(null);
    }

    /**
     * 开启清晰度增强
     */
    private void enableSharpnessEnhancement(MethodCall call, Result result) {
        boolean enable = CommonUtil.getParam(call, result, "enable");
        txBeautyManager.enableSharpnessEnhancement(enable);
        result.success(null);
    }

    /**
     * 设置红润级别
     */
    private void setRuddyLevel(MethodCall call, Result result) {
        int ruddyLevel = CommonUtil.getParam(call, result, "ruddyLevel");
        txBeautyManager.setRuddyLevel(ruddyLevel);
        result.success(null);
    }

    /**
     * 开启耳返
     */
    private void enableVoiceEarMonitor(MethodCall call, Result result) {
        boolean enable = CommonUtil.getParam(call, result, "enable");
        txAudioEffectManager.enableVoiceEarMonitor(enable);
        result.success(null);
    }

    /**
     * 设置耳返音量。
     */
    private void setVoiceEarMonitorVolume(MethodCall call, Result result) {
        int volume = CommonUtil.getParam(call, result, "volume");
        txAudioEffectManager.setVoiceEarMonitorVolume(volume);
        result.success(null);
    }

    /**
     * 设置人声的混响效果（KTV、小房间、大会堂、低沉、洪亮...）
     */
    private void setVoiceReverbType(MethodCall call, Result result) {
        int type = CommonUtil.getParam(call, result, "type");
        TXAudioEffectManager.TXVoiceReverbType reverbType =
                TXAudioEffectManager.TXVoiceReverbType.TXLiveVoiceReverbType_0;
        switch (type) {
            case 0:
                reverbType = TXAudioEffectManager.TXVoiceReverbType.TXLiveVoiceReverbType_0;
                break;
            case 1:
                reverbType = TXAudioEffectManager.TXVoiceReverbType.TXLiveVoiceReverbType_1;
                break;
            case 2:
                reverbType = TXAudioEffectManager.TXVoiceReverbType.TXLiveVoiceReverbType_2;
                break;
            case 3:
                reverbType = TXAudioEffectManager.TXVoiceReverbType.TXLiveVoiceReverbType_3;
                break;
            case 4:
                reverbType = TXAudioEffectManager.TXVoiceReverbType.TXLiveVoiceReverbType_4;
                break;
            case 5:
                reverbType = TXAudioEffectManager.TXVoiceReverbType.TXLiveVoiceReverbType_5;
                break;
            case 6:
                reverbType = TXAudioEffectManager.TXVoiceReverbType.TXLiveVoiceReverbType_6;
                break;
            case 7:
                reverbType = TXAudioEffectManager.TXVoiceReverbType.TXLiveVoiceReverbType_7;
                break;
            default:
                reverbType = TXAudioEffectManager.TXVoiceReverbType.TXLiveVoiceReverbType_0;
                break;
        }
        txAudioEffectManager.setVoiceReverbType(reverbType);
        result.success(null);
    }

    /**
     * 设置人声的变声特效（萝莉、大叔、重金属、外国人...）
     */
    private void setVoiceChangerType(MethodCall call, Result result) {
        int type = CommonUtil.getParam(call, result, "type");
        TXAudioEffectManager.TXVoiceChangerType changerType =
                TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_0;
        switch (type) {
            case 0:
                changerType = TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_0;
                break;
            case 1:
                changerType = TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_1;
                break;
            case 2:
                changerType = TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_2;
                break;
            case 3:
                changerType = TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_3;
                break;
            case 4:
                changerType = TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_4;
                break;
            case 5:
                changerType = TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_5;
                break;
            case 6:
                changerType = TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_6;
                break;
            case 7:
                changerType = TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_7;
                break;
            case 8:
                changerType = TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_8;
                break;
            case 9:
                changerType = TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_9;
                break;
            case 10:
                changerType = TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_10;
                break;
            case 11:
                changerType = TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_11;
                break;
            default:
                changerType = TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_0;
                break;
        }
        txAudioEffectManager.setVoiceChangerType(changerType);
        result.success(null);
    }
    
    /**
     * 设置麦克风采集人声的音量
     */
    private void setVoiceCaptureVolume(MethodCall call, Result result) {
        int volume = CommonUtil.getParam(call, result, "volume");
        txAudioEffectManager.setVoiceCaptureVolume(volume);
        result.success(null);
    }

    /**
     * 设置背景音乐的播放进度回调接口
     */
    private void setMusicObserver(MethodCall call, Result result) {
        int id = CommonUtil.getParam(call, result, "id");
        txAudioEffectManager.setMusicObserver(id, new TXAudioEffectManager.TXMusicPlayObserver() {
            @Override
            public void onStart(int i, int i1) {
                trtcListener.onMusicObserverStart(i, i1);
            }

            @Override
            public void onPlayProgress(int i, long l, long l1) {
                trtcListener.onMusicObserverPlayProgress(i, l,l1);
            }

            @Override
            public void onComplete(int i, int i1) {
                trtcListener.onMusicObserverComplete(i, i1);
            }
        });
        result.success(null);
    }


    /**
     * 开始播放背景音乐
     */
    private void startPlayMusic(MethodCall call, Result result) {
        String musicParam = CommonUtil.getParam(call, result, "musicParam");
        TXAudioEffectManager.AudioMusicParam audioMusicParam =
                new Gson().fromJson(musicParam, TXAudioEffectManager.AudioMusicParam.class);
        boolean isSuccess = txAudioEffectManager.startPlayMusic(audioMusicParam);
        result.success(isSuccess);
        txAudioEffectManager.setMusicObserver(audioMusicParam.id, new TXAudioEffectManager.TXMusicPlayObserver() {
            @Override
            public void onStart(int i, int i1) {
                trtcListener.onMusicObserverStart(i, i1);
            }

            @Override
            public void onPlayProgress(int i, long l, long l1) {
                trtcListener.onMusicObserverPlayProgress(i, l,l1);
            }

            @Override
            public void onComplete(int i, int i1) {
                trtcListener.onMusicObserverComplete(i, i1);
            }
        });
    }

    /**
     * 停止播放背景音乐
     */
    private void stopPlayMusic(MethodCall call, Result result) {
        int id = CommonUtil.getParam(call, result, "id");
        txAudioEffectManager.stopPlayMusic(id);
        result.success(null);
    }

    /**
     * 暂停播放背景音乐
     */
    private void pausePlayMusic(MethodCall call, Result result) {
        int id = CommonUtil.getParam(call, result, "id");
        txAudioEffectManager.pausePlayMusic(id);
        result.success(null);
    }

    /**
     * 恢复播放背景音乐
     */
    private void resumePlayMusic(MethodCall call, Result result) {
        int id = CommonUtil.getParam(call, result, "id");
        txAudioEffectManager.resumePlayMusic(id);
        result.success(null);
    }

    /**
     * 设置背景音乐的远端音量大小，即主播可以通过此接口设置远端观众能听到的背景音乐的音量大小。
     */
    private void setMusicPublishVolume(MethodCall call, Result result) {
        int id = CommonUtil.getParam(call, result, "id");
        int volume = CommonUtil.getParam(call, result, "volume");
        txAudioEffectManager.setMusicPublishVolume(id, volume);
        result.success(null);
    }

    /**
     * 设置背景音乐的本地音量大小，即主播可以通过此接口设置主播自己本地的背景音乐的音量大小。
     */
    private void setMusicPlayoutVolume(MethodCall call, Result result) {
        int id = CommonUtil.getParam(call, result, "id");
        int volume = CommonUtil.getParam(call, result, "volume");
        txAudioEffectManager.setMusicPlayoutVolume(id, volume);
        result.success(null);
    }

    /**
     * 设置全局背景音乐的本地和远端音量的大小
     */
    private void setAllMusicVolume(MethodCall call, Result result) {
        int volume = CommonUtil.getParam(call, result, "volume");
        txAudioEffectManager.setAllMusicVolume(volume);
        result.success(null);
    }

    /**
     * 调整背景音乐的音调高低
     */
    private void setMusicPitch(MethodCall call, Result result) {
        int volume = CommonUtil.getParam(call, result, "volume");
        String pitchParam = CommonUtil.getParam(call, result, "pitch");
        float pitch = Float.parseFloat(pitchParam);
        txAudioEffectManager.setMusicPitch(volume, pitch);
        result.success(null);
    }

    /**
     * 调整背景音乐的变速效果
     */
    private void setMusicSpeedRate(MethodCall call, Result result) {
        int id = CommonUtil.getParam(call, result, "id");
        String speedRateParam = CommonUtil.getParam(call, result, "speedRate");
        float speedRate = Float.parseFloat(speedRateParam);
        txAudioEffectManager.setMusicSpeedRate(id, speedRate);
        result.success(null);
    }

    /**
     * 获取背景音乐当前的播放进度（单位：毫秒）
     */
    private void getMusicCurrentPosInMS(MethodCall call, Result result) {
        int id = CommonUtil.getParam(call, result, "id");
        result.success(txAudioEffectManager.getMusicCurrentPosInMS(id));
    }

    /**
     * 设置背景音乐的播放进度（单位：毫秒）
     */
    private void seekMusicToPosInMS(MethodCall call, Result result) {
        int id = CommonUtil.getParam(call, result, "id");
        int pts = CommonUtil.getParam(call, result, "pts");
        txAudioEffectManager.seekMusicToPosInMS(id, pts);
        result.success(null);
    }

    /**
     * 获取景音乐文件的总时长（单位：毫秒）
     */
    private void getMusicDurationInMS(MethodCall call, Result result) {
        String path = CommonUtil.getParamCanBeNull(call, result, "path");
        result.success(txAudioEffectManager.getMusicDurationInMS(path));
    }
}