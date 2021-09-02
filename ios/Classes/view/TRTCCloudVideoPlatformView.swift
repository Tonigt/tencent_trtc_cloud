import TXLiteAVSDK_TRTC
import Flutter
import FURenderKit


public class TRTCCloudVideoPlatformViewFactory : NSObject,FlutterPlatformViewFactory{

	public static let SIGN = "trtcCloudChannelView";
	private var message : FlutterBinaryMessenger;
	
	init(message : FlutterBinaryMessenger) {
		self.message = message;
	}
    
    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance();
    }
	
	public func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        if let argu = args, argu is [String: String], let type = (argu as! [String: String])["type"] {
            if type == "FuRenderKitBottomBar" {
                return FuRenderKitBottomBar(frame: frame, args: args)
            }
        }
		
        let view = TRTCCloudVideoPlatformView(frame,self.message,viewId);
		
//		// 绑定方法监听
//		FlutterMethodChannel(
//			name: "\(TRTCCloudVideoPlatformViewFactory.SIGN)_\(viewId)",
//			binaryMessenger: message
//		).setMethodCallHandler(view.handle);
		
		return view;
	}
}

public class TRTCCloudVideoPlatformView : NSObject,FlutterPlatformView{
	private var remoteView : UIView;
	private var frame : CGRect;
    private let channel: FlutterMethodChannel?;
	init(_ frame : CGRect,_ messager: FlutterBinaryMessenger,_ viewId: Int64) {
		self.frame = frame;
		self.remoteView = UIView();
        self.channel = FlutterMethodChannel(name: "trtcCloudChannelView_\(viewId)", binaryMessenger: messager);
        super.init();
        self.channel?.setMethodCallHandler(handle);
	}
	
	public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
		switch call.method {
		case "startRemoteView":
			self.startRemoteView(call: call, result: result);
			break;
		case "startLocalPreview":
			self.startLocalPreview(call: call, result: result);
			break;
        case "updateLocalView":
            self.updateLocalView(call: call, result: result);
            break;
		case "updateRemoteView":
            self.updateRemoteView(call: call, result: result);
            break;
		default:
			result(FlutterMethodNotImplemented);
		}
	}
	
	public func view() -> UIView {
		return remoteView;
	}
	
	deinit {
        if channel != nil {
            channel?.setMethodCallHandler(nil);
        }
	}
	
	public func startRemoteView(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let userId = CommonUtils.getParamByKey(call: call, result: result, param: "userId") as? String, 
      	let streamType = CommonUtils.getParamByKey(call: call, result: result, param: "streamType") as? Int {
			TRTCCloud.sharedInstance()?.startRemoteView(userId, streamType: TRTCVideoStreamType(rawValue: streamType)!, view: self.remoteView);
			result(nil);
		}
	}
	
	public func startLocalPreview(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let frontCamera = CommonUtils.getParamByKey(call: call, result: result, param: "frontCamera") as? Bool{
            let data = try? JSONSerialization.data(withJSONObject: [
                "api": "setCustomRenderMode",
                "params": ["mode": 1]
            ], options: [])
            let str = String(data: data!, encoding: .utf8)
//            FUManager.share().flipx = true
//            FUManager.share().trackFlipx = true
//            FUManager.share().isRender = true
            
            TRTCCloud.sharedInstance()?.callExperimentalAPI(str)
            TRTCCloud.sharedInstance()?.setLocalVideoRenderDelegate(self, pixelFormat: ._NV12, bufferType: .pixelBuffer)
            TRTCCloud.sharedInstance()?.startLocalAudio(.default)
            TRTCCloud.sharedInstance()?.setGSensorMode(.disable)

			TRTCCloud.sharedInstance()?.startLocalPreview(frontCamera, view: self.remoteView);
			result(nil);
		}
	}

    public func updateLocalView(call: FlutterMethodCall, result: @escaping FlutterResult) {
        TRTCCloud.sharedInstance()?.updateLocalView(self.remoteView);
        result(nil);
    }

    public func updateRemoteView(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let userId = CommonUtils.getParamByKey(call: call, result: result, param: "userId") as? String, 
			let streamType = CommonUtils.getParamByKey(call: call, result: result, param: "streamType") as? Int {
            TRTCCloud.sharedInstance()?.updateRemoteView(self.remoteView, streamType: TRTCVideoStreamType(rawValue: streamType)!, forUser: userId);
			result(nil);
		}
    }
}


extension TRTCCloudVideoPlatformView: TRTCVideoRenderDelegate {
    public func onRenderVideoFrame(_ frame: TRTCVideoFrame, userId: String?, streamType: TRTCVideoStreamType) {
        
        let input: FURenderInput = FURenderInput()
        input.renderConfig.imageOrientation = FUImageOrientationUP
        input.pixelBuffer = frame.pixelBuffer
        input.renderConfig.gravityEnable = true
        input.renderConfig.readBackToPixelBuffer = true
        FURenderKit.share().render(with: input)
//        fuGetSystemError()

//
//        let pixelBuffer: CVPixelBuffer? = frame.pixelBuffer
//        let input: FURenderInput = FURenderInput()
//        input.renderConfig.imageOrientation = FUImageOrientationUP
//        input.renderConfig.isFromFrontCamera = txCloudManager.getDeviceManager().isFrontCamera()
//        input.pixelBuffer = frame.pixelBuffer
//        input.renderConfig.gravityEnable = true
//        let outPut: FURenderOutput = FURenderKit.share().render(with: input)
//        let resultBuffer = outPut.pixelBuffer
//        if frame.pixelFormat == ._NV12 {
//            NV12PixelBufferCopySrcBuffer(resultBuffer!, pixelBuffer!)
//        }else if frame.pixelFormat == ._32BGRA {
//            rgbPixelBufferCopySrcBuffer(resultBuffer!, pixelBuffer!)
//        }else {
//
//        }
    }
    
    func NV12PixelBufferCopySrcBuffer(_ srcPixelBuffer: CVPixelBuffer, _ despixelBuffer: CVPixelBuffer) {
        let flags = CVPixelBufferLockFlags(rawValue: 0)
        CVPixelBufferLockBaseAddress(srcPixelBuffer, flags)
        CVPixelBufferLockBaseAddress(despixelBuffer, flags)
        let desStrdeY = CVPixelBufferGetBaseAddressOfPlane(despixelBuffer, 0)
        let desStrdeUV = CVPixelBufferGetBaseAddressOfPlane(despixelBuffer, 1)
        
        let srcStrdeY = CVPixelBufferGetBaseAddressOfPlane(srcPixelBuffer, 0)
        let srcStrdeUV = CVPixelBufferGetBaseAddressOfPlane(srcPixelBuffer, 1)
        
        let desWidth = CVPixelBufferGetWidth(despixelBuffer)
        
        let srcWidth = CVPixelBufferGetWidth(srcPixelBuffer)
        let srcHeight = CVPixelBufferGetHeight(srcPixelBuffer)
        
        let w_nv21 = ((srcWidth + 3) >> 2)
        let h_uv = ((srcHeight + 1) >> 1)
        
        for i in 0..<srcHeight {
            memcpy(desStrdeY! + desWidth * i, srcStrdeY! + (w_nv21 * 4) * i, srcWidth)
        }
        
        let des_w_uv = 2 * ((desWidth + 1) >> 1)
        let src_w_uv = 2 * ((srcWidth + 1) >> 1)
        for i in 0..<h_uv {
            memcpy(desStrdeUV! + i * des_w_uv, srcStrdeUV! + i * w_nv21 * 4, src_w_uv)
        }
        CVPixelBufferUnlockBaseAddress(despixelBuffer, flags)
        CVPixelBufferUnlockBaseAddress(srcPixelBuffer, flags)
    }
    
    
    func rgbPixelBufferCopySrcBuffer(_ srcPixelBuffer: CVPixelBuffer, _ desPixelBuffer: CVPixelBuffer) {
        let flags = CVPixelBufferLockFlags(rawValue: 0)
        CVPixelBufferLockBaseAddress(srcPixelBuffer, flags)
        CVPixelBufferLockBaseAddress(desPixelBuffer, flags)
        
        let srcBufferAddress = CVPixelBufferGetBaseAddress(srcPixelBuffer)
        let srcStride = CVPixelBufferGetBytesPerRow(srcPixelBuffer)
        let srcHeight = CVPixelBufferGetHeight(srcPixelBuffer)
        let desBufferAddress = CVPixelBufferGetBaseAddress(desPixelBuffer)
        let desStride = CVPixelBufferGetBytesPerRow(desPixelBuffer)
        
        for i in 0..<srcHeight {
            memcpy(desBufferAddress! + i * desStride, srcBufferAddress! + i * srcStride , desStride)
        }
        
        CVPixelBufferUnlockBaseAddress(desPixelBuffer, flags)
        CVPixelBufferUnlockBaseAddress(srcPixelBuffer, flags)
    }
}
