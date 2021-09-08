



//class TRTCCloud: NSObject {
//    static private var _instance: TRTCCloud?
//
//    private var livePusher: TXLivePush? {
//        didSet {
//            livePusher!.delegate = self
//            livePusher?.setVideoQuality(.VIDEO_QUALITY_HIGH_DEFINITION, adjustBitrate: false, adjustResolution: false)
//        }
//    }
//
//    static func sharedInstance() -> TRTCCloud {
//        if _instance == nil {
//            _instance = TRTCCloud()
//        }
//        return _instance!
//    }
//
//    /// 禁止外部初始化
//    private override init() {
//
//        let config = TXLivePushConfig()
//        config.pauseFps = 15
//        config.pauseTime = 300
//        config.videoEncodeGop = 2
//        livePusher = TXLivePush(config: config)
//    }
//
//    override func copy() -> Any {
//        return self
//    }
//
//    func getBeautyManager() -> TXBeautyManager {
//        return livePusher!.getBeautyManager()
//    }
//}
//
//extension TRTCCloud: TXLivePushListener {
//    func onPushEvent(_ EvtID: Int32, withParam param: [AnyHashable : Any]!) {
//
//    }
//
//    func onNetStatus(_ param: [AnyHashable : Any]!) {
//
//    }
//
//    func onScreenCaptureStarted() {
//
//    }
//
//    func onScreenCapturePaused(_ reason: Int32) {
//
//    }
//
//    func onScreenCaptureResumed(_ reason: Int32) {
//
//    }
//
//    func onScreenCaptureStoped(_ reason: Int32) {
//
//    }
//
//
//}
