import Flutter
//import TXLiteAVSDK_TRTC
import FURenderKit

enum FuRenderChannel: String {
    
    /// 插件启动
    case FUSetUp
    
    
    case skin
    case shape
    case filter
    case makeUp
    case bodyBeauty
    
    case setLicense
}

public class TencentTRTCCloud: NSObject, FlutterPlugin, TRTCCloudDelegate {
    
    private static var channel: FlutterMethodChannel?;
    
    private static var registrar: FlutterPluginRegistrar?;
    
	
	private var beautyManager: BeautyManager?;
	
	private var deviceManager: DeviceManager?;
	
	private var audioEffectManager: AudioEffectManager?;
    
    var type: FuRenderChannel?
	
	private var cloudManager: CloudManager?;
	
	private var listener: Listener?;
	private static let LISTENER_FUNC_NAME = "onListener";
	
	public static func register(with registrar: FlutterPluginRegistrar) {
		let channel = FlutterMethodChannel(name: "trtcCloudChannel", binaryMessenger: registrar.messenger())
		let instance = TencentTRTCCloud()
        
		TencentTRTCCloud.channel = channel;
        TencentTRTCCloud.registrar = registrar;
		registrar.addMethodCallDelegate(instance, channel: channel);
		
		// 视图工厂
		let viewFactory = TRTCCloudVideoPlatformViewFactory(message: registrar.messenger());
		
		// 注册界面
		registrar.register(
			viewFactory,
			withId: TRTCCloudVideoPlatformViewFactory.SIGN
		);
        registrar.register(viewFactory, withId: "FuRenderKitBottomBar")
	}
	
	public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
		defer {
			CommonUtils.logFlutterMethodCall(call)
		}
		
		switch call.method {
		case "sharedInstance":
			self.sharedInstance(call: call, result: result);
			break;
		case "destroySharedInstance":
			self.destroySharedInstance(call: call, result: result);
			break;
		case "enterRoom":
			cloudManager!.enterRoom(call: call, result: result);
			break;
		case "exitRoom":
			cloudManager!.exitRoom(call: call, result: result);
			break;
		case "switchRoom":
			cloudManager!.switchRoom(call: call, result: result);
			break;
		case "connectOtherRoom":
			cloudManager!.connectOtherRoom(call: call, result: result);
			break;
		case "disconnectOtherRoom":
			cloudManager!.disconnectOtherRoom(call: call, result: result);
			break;
		case "switchRole":
			cloudManager!.switchRole(call: call, result: result);
			break;
		case "setDefaultStreamRecvMode":
			cloudManager!.setDefaultStreamRecvMode(call: call, result: result);
			break;
		case "stopLocalPreview":
			cloudManager!.stopLocalPreview(call: call, result: result);
			break;
		case "muteRemoteAudio":
			cloudManager!.muteRemoteAudio(call: call, result: result);
			break;
		case "muteAllRemoteAudio":
			cloudManager!.muteAllRemoteAudio(call: call, result: result);
			break;
		case "setRemoteAudioVolume":
			cloudManager!.setRemoteAudioVolume(call: call, result: result);
			break;
		case "setAudioCaptureVolume":
			cloudManager!.setAudioCaptureVolume(call: call, result: result);
			break;
		case "getAudioCaptureVolume":
			cloudManager!.getAudioCaptureVolume(call: call, result: result);
			break;
		case "setAudioPlayoutVolume":
			cloudManager!.setAudioPlayoutVolume(call: call, result: result);
			break;
		case "getAudioPlayoutVolume":
			cloudManager!.getAudioPlayoutVolume(call: call, result: result);
			break;
		case "stopRemoteView":
			cloudManager!.stopRemoteView(call: call, result: result);
			break;
		case "startLocalAudio":
			cloudManager!.startLocalAudio(call: call, result: result);
			break;
		case "stopLocalAudio":
			cloudManager!.stopLocalAudio(call: call, result: result);
			break;
		case "setLocalRenderParams":
			cloudManager!.setLocalRenderParams(call: call, result: result);
			break;
		case "setRemoteRenderParams":
			cloudManager!.setRemoteRenderParams(call: call, result: result);
			break;
		case "stopAllRemoteView":
			cloudManager!.stopAllRemoteView(call: call, result: result);
			break;
		case "muteRemoteVideoStream":
			cloudManager!.muteRemoteVideoStream(call: call, result: result);
			break;
		case "muteAllRemoteVideoStreams":
			cloudManager!.muteAllRemoteVideoStreams(call: call, result: result);
			break;
		case "setVideoEncoderParam":
			cloudManager!.setVideoEncoderParam(call: call, result: result);
			break;
		case "startPublishing":
			cloudManager!.startPublishing(call: call, result: result);
			break;
		case "stopPublishing":
			cloudManager!.stopPublishing(call: call, result: result);
			break;
		case "startPublishCDNStream":
			cloudManager!.startPublishCDNStream(call: call, result: result);
			break;
		case "stopPublishCDNStream":
			cloudManager!.stopPublishCDNStream(call: call, result: result);
			break;
		case "setMixTranscodingConfig":
			cloudManager!.setMixTranscodingConfig(call: call, result: result);
			break;
		case "setNetworkQosParam":
			cloudManager!.setNetworkQosParam(call: call, result: result);
			break;
		case "setVideoEncoderRotation":
			cloudManager!.setVideoEncoderRotation(call: call, result: result);
			break;
		case "setVideoMuteImage":
			cloudManager!.setVideoMuteImage(call: call, result: result);
			break;
		case "setVideoEncoderMirror":
			cloudManager!.setVideoEncoderMirror(call: call, result: result);
			break;
		case "setGSensorMode":
			cloudManager!.setGSensorMode(call: call, result: result);
			break;
		case "enableEncSmallVideoStream":
			cloudManager!.enableEncSmallVideoStream(call: call, result: result);
			break;
		case "setRemoteVideoStreamType":
			cloudManager!.setRemoteVideoStreamType(call: call, result: result);
			break;
		case "snapshotVideo":
			cloudManager!.snapshotVideo(call: call, result: result);
			break;
		case "muteLocalAudio":
			cloudManager!.muteLocalAudio(call: call, result: result);
			break;
		case "muteLocalVideo":
			cloudManager!.muteLocalVideo(call: call, result: result);
			break;
		case "enableAudioVolumeEvaluation":
			cloudManager!.enableAudioVolumeEvaluation(call: call, result: result);
			break;
		case "startAudioRecording":
			cloudManager!.startAudioRecording(call: call, result: result);
			break;
		case "stopAudioRecording":
			cloudManager!.stopAudioRecording(call: call, result: result);
			break;
		case "enableAudioEarMonitoring":
			// cloudManager!.enableAudioEarMonitoring(call: call, result: result);
			break;
		case "switchCamera":
			deviceManager!.switchCamera(call: call, result: result);
			break;
		case "isFrontCamera":
			deviceManager!.isFrontCamera(call: call, result: result);
			break;
		case "getCameraZoomMaxRatio":
			deviceManager!.getCameraZoomMaxRatio(call: call, result: result);
			break;
		case "setCameraZoomRatio":
			deviceManager!.setCameraZoomRatio(call: call, result: result);
			break;
		case "enableCameraAutoFocus":
			deviceManager!.enableCameraAutoFocus(call: call, result: result);
			break;
		case "enableCameraTorch":
			deviceManager!.enableCameraTorch(call: call, result: result);
			break;
		case "setCameraFocusPosition":
			deviceManager!.setCameraFocusPosition(call: call, result: result);
			break;
		case "isAutoFocusEnabled":
			deviceManager!.isAutoFocusEnabled(call: call, result: result);
			break;
		case "setSystemVolumeType":
			deviceManager!.setSystemVolumeType(call: call, result: result);
			break;
		case "setAudioRoute":
			deviceManager!.setAudioRoute(call: call, result: result);
			break;
		case "getBeautyManager":
			self.getBeautyManager(call: call, result: result);
			break;
		case "getDeviceManager":
			self.getDeviceManager(call: call, result: result);
			break;
		case "getAudioEffectManager":
			self.getAudioEffectManager(call: call, result: result);
			break;
		case "setWatermark":
			cloudManager!.setWatermark(call: call, result: result);
			break;
		case "startScreenCaptureInApp":
			cloudManager!.startScreenCaptureInApp(call: call, result: result);
			break;
		case "startScreenCaptureByReplaykit":
			cloudManager!.startScreenCaptureByReplaykit(call: call, result: result);
			break;
		case "startScreenCapture":
			cloudManager!.startScreenCapture(call: call, result: result);
			break;
		case "stopScreenCapture":
			cloudManager!.stopScreenCapture(call: call, result: result);
			break;
		case "pauseScreenCapture":
			cloudManager!.pauseScreenCapture(call: call, result: result);
			break;
		case "resumeScreenCapture":
			cloudManager!.resumeScreenCapture(call: call, result: result);
			break;
		// case "sendCustomVideoData":
		// 	cloudManager!.sendCustomVideoData(call: call, result: result);
		// 	break;
		case "sendCustomCmdMsg":
			cloudManager!.sendCustomCmdMsg(call: call, result: result);
			break;
		case "sendSEIMsg":
			cloudManager!.sendSEIMsg(call: call, result: result);
			break;
		case "startSpeedTest":
			cloudManager!.startSpeedTest(call: call, result: result);
			break;
		case "stopSpeedTest":
			cloudManager!.stopSpeedTest(call: call, result: result);
			break;
		case "setLocalVideoRenderListener":
            cloudManager!.setLocalVideoRenderListener(call: call, result: result);
			break;
		case "setRemoteVideoRenderListener":
            cloudManager!.setRemoteVideoRenderListener(call: call, result: result);
			break;
		case "getSDKVersion":
			self.getSDKVersion(call: call, result: result);
			break;
		case "setLogCompressEnabled":
			self.setLogCompressEnabled(call: call, result: result);
			break;
		case "setLogDirPath":
			self.setLogDirPath(call: call, result: result);
			break;
		case "setLogLevel":
			self.setLogLevel(call: call, result: result);
			break;
		case "callExperimentalAPI":
            cloudManager!.callExperimentalAPI(call: call, result: result);
			break;
		case "setConsoleEnabled":
			self.setConsoleEnabled(call: call, result: result);
			break;
		case "showDebugView":
			cloudManager!.showDebugView(call: call, result: result);
			break;
		case "setBeautyStyle":
			beautyManager!.setBeautyStyle(call: call, result: result);
			break;
		case "setBeautyLevel":
			beautyManager!.setBeautyLevel(call: call, result: result);
			break;
		case "setWhitenessLevel":
			beautyManager!.setWhitenessLevel(call: call, result: result);
			break;
		case "enableSharpnessEnhancement":
			beautyManager!.enableSharpnessEnhancement(call: call, result: result);
			break;
		case "setRuddyLevel":
			beautyManager!.setRuddyLevel(call: call, result: result);
			break;
		case "setFilter":
			beautyManager!.setFilter(call: call, result: result);
			break;
		case "setFilterStrength":
			beautyManager!.setFilterStrength(call: call, result: result);
			break;
		case "setEyeScaleLevel":
			beautyManager!.setEyeScaleLevel(call: call, result: result);
			break;
		case "setFaceSlimLevel":
			beautyManager!.setFaceSlimLevel(call: call, result: result);
			break;
		case "setFaceVLevel":
			beautyManager!.setFaceVLevel(call: call, result: result);
			break;
		case "setChinLevel":
			beautyManager!.setChinLevel(call: call, result: result);
			break;
		case "setFaceShortLevel":
			beautyManager!.setFaceShortLevel(call: call, result: result);
			break;
		case "setNoseSlimLevel":
			beautyManager!.setNoseSlimLevel(call: call, result: result);
			break;
		case "setEyeLightenLevel":
			beautyManager!.setEyeLightenLevel(call: call, result: result);
			break;
		case "setToothWhitenLevel":
			beautyManager!.setToothWhitenLevel(call: call, result: result);
			break;
		case "setWrinkleRemoveLevel":
			beautyManager!.setWrinkleRemoveLevel(call: call, result: result);
			break;
		case "setPounchRemoveLevel":
			beautyManager!.setPounchRemoveLevel(call: call, result: result);
			break;
		case "setSmileLinesRemoveLevel":
			beautyManager!.setSmileLinesRemoveLevel(call: call, result: result);
			break;
		case "setForeheadLevel":
			beautyManager!.setForeheadLevel(call: call, result: result);
			break;
		case "setEyeDistanceLevel":
			beautyManager!.setEyeDistanceLevel(call: call, result: result);
			break;
		case "setEyeAngleLevel":
			beautyManager!.setEyeAngleLevel(call: call, result: result);
			break;
		case "setMouthShapeLevel":
			beautyManager!.setMouthShapeLevel(call: call, result: result);
			break;
		case "setNoseWingLevel":
			beautyManager!.setNoseWingLevel(call: call, result: result);
			break;
		case "setNosePositionLevel":
			beautyManager!.setNosePositionLevel(call: call, result: result);
			break;
		case "setLipsThicknessLevel":
			beautyManager!.setLipsThicknessLevel(call: call, result: result);
			break;
		case "setFaceBeautyLevel":
			beautyManager!.setFaceBeautyLevel(call: call, result: result);
			break;
		case "enableVoiceEarMonitor":
			audioEffectManager!.enableVoiceEarMonitor(call: call, result: result);
			break;
		case "setVoiceEarMonitorVolume":
			audioEffectManager!.setVoiceEarMonitorVolume(call: call, result: result);
			break;
		case "setVoiceReverbType":
			audioEffectManager!.setVoiceReverbType(call: call, result: result);
			break;
		case "setVoiceChangerType":
			audioEffectManager!.setVoiceChangerType(call: call, result: result);
			break;
		case "setVoiceCaptureVolume":
			audioEffectManager!.setVoiceCaptureVolume(call: call, result: result);
			break;
		case "setMusicObserver":
			// self.setMusicObserver(call: call, result: result);
			break;
		case "startPlayMusic":
			audioEffectManager!.startPlayMusic(call: call, result: result);
			break;
		case "stopPlayMusic":
			audioEffectManager!.stopPlayMusic(call: call, result: result);
			break;
		case "pausePlayMusic":
			audioEffectManager!.pausePlayMusic(call: call, result: result);
			break;
		case "resumePlayMusic":
			audioEffectManager!.resumePlayMusic(call: call, result: result);
			break;
		case "setMusicPublishVolume":
			audioEffectManager!.setMusicPublishVolume(call: call, result: result);
			break;
		case "setMusicPlayoutVolume":
			audioEffectManager!.setMusicPlayoutVolume(call: call, result: result);
			break;
		case "setAllMusicVolume":
			audioEffectManager!.setAllMusicVolume(call: call, result: result);
			break;
		case "setMusicPitch":
			audioEffectManager!.setMusicPitch(call: call, result: result);
			break;
		case "setMusicSpeedRate":
			audioEffectManager!.setMusicSpeedRate(call: call, result: result);
			break;
		case "getMusicCurrentPosInMS":
			audioEffectManager!.getMusicCurrentPosInMS(call: call, result: result);
			break;
		case "seekMusicToPosInMS":
			audioEffectManager!.seekMusicToPosInMS(call: call, result: result);
			break;
		case "getMusicDurationInMS":
			audioEffectManager!.getMusicDurationInMS(call: call, result: result);
			break;
        case FuRenderChannel.FUSetUp.rawValue:
            furenderSetUp(call: call, result: result)
        case FuRenderChannel.skin.rawValue:
            if let map = call.arguments as? [String: Any] {
                skinSetting(map: map)
            }
            result(nil)
        case FuRenderChannel.shape.rawValue:
            if let map = call.arguments as? [String: Any] {
                shapeSetting(map: map)
            }
            result(nil)
        case FuRenderChannel.filter.rawValue:
            if let map = call.arguments as? [String: Any]{
                filterSetting(map: map)
            }
            result(nil)
        case FuRenderChannel.makeUp.rawValue:
            if let map = call.arguments as? [String: Any] {
                makeUpSetting(map: map)
            }
            result(nil)
        case FuRenderChannel.bodyBeauty.rawValue:
            if let map = call.arguments as? [String: Any] {
                bodyBeauty(map: map)
            }
            result(nil)
        case FuRenderChannel.setLicense.rawValue:
            if let map = call.arguments as? [String: String], let url = map["url"], let key = map["key"] {
                TXLiveBase.setLicenceURL(url, key: key)
            }
            result(nil)
		default:
			CommonUtils.logError(call: call, errCode: -1, errMsg: "method not Implemented");
			result(FlutterMethodNotImplemented);
		}
	}
	
	/**
	* 启用或禁用控制台日志打印
	*/
	public func setConsoleEnabled(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let enabled = CommonUtils.getParamByKey(call: call, result: result, param: "enabled") as? Bool {
			TRTCCloud.setConsoleEnabled(enabled);
			result(nil);
		}
	}
	
	/**
	* 启用或禁用 Log 的本地压缩。
	*/
	public func setLogCompressEnabled(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let enabled = CommonUtils.getParamByKey(call: call, result: result, param: "enabled") as? Bool {
			TRTCCloud.setLogCompressEnabled(enabled);
			result(nil);
		}
	}
	
	/**
	* 启用或禁用 Log 的本地压缩。
	*/
	public func setLogDirPath(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let path = CommonUtils.getParamByKey(call: call, result: result, param: "path") as? String {
			TRTCCloud.setLogDirPath(path);
			result(nil);
		}
	}
	
	/**
	* 设置 Log 输出级别
	*/
	public func setLogLevel(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let level = CommonUtils.getParamByKey(call: call, result: result, param: "level") as? Int {
			TRTCCloud.setLogLevel(TRTCLogLevel(rawValue: level)!);
			result(nil);
		}
	}
	
	/**
	* 创建 TRTCCloud 单例
	*/
	public func sharedInstance(call: FlutterMethodCall, result: @escaping FlutterResult) {
		listener = Listener();
        cloudManager = CloudManager(registrar: TencentTRTCCloud.registrar);
		TRTCCloud.sharedInstance()?.delegate = listener;
		
		result(nil);
	}
	
	/**
	* 销毁 TRTCCloud 单例
	*/
	public func destroySharedInstance(call: FlutterMethodCall, result: @escaping FlutterResult) {
		listener = nil;
		beautyManager = nil;
		cloudManager = nil;
		deviceManager = nil;
		audioEffectManager = nil;
		TRTCCloud.sharedInstance()?.delegate = nil;
		TRTCCloud.destroySharedIntance();
		
		result(nil);
	}
	
	/**
	* 获取美颜管理对象
	*/
	public func getBeautyManager(call: FlutterMethodCall, result: @escaping FlutterResult) {
		beautyManager = BeautyManager(registrar: TencentTRTCCloud.registrar)
		result(nil);
	}
	
	/**
	* 获取设备管理对象
	*/
	public func getDeviceManager(call: FlutterMethodCall, result: @escaping FlutterResult) {
		deviceManager = DeviceManager()
		result(nil);
	}
	
	/**
	* 获取音效管理对象
	*/
	public func getAudioEffectManager(call: FlutterMethodCall, result: @escaping FlutterResult) {
		audioEffectManager = AudioEffectManager()
		result(nil);
	}
	
	/**
	* 监听回调
	*/
	static func invokeListener(type: ListenerType, params: Any?) {
		var resultParams: [String: Any] = [:];
		resultParams["type"] = type;
		if let p = params {
			resultParams["params"] = p;
		}
		TencentTRTCCloud.channel!.invokeMethod(TencentTRTCCloud.LISTENER_FUNC_NAME, arguments: JsonUtil.toJson(resultParams));
	}
	
	/**
	* 获取 SDK 版本信息
	*/
	public func getSDKVersion(call: FlutterMethodCall, result: @escaping FlutterResult) {
		result(TRTCCloud.getSDKVersion());
	}
}
