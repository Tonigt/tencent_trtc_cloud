//
//  tencentTRTCCloudExtension.swift
//  tencent_trtc_cloud
//
//  Created by Tonight on 2021/8/27.
//


import FURenderKit
import Flutter

extension TencentTRTCCloud {
    /// 设置修改
    private var beauty: FUBeauty? {
        return FURenderKit.share().beauty
    }
    private var makeUp: FUMakeup? {
        return FURenderKit.share().makeup
    }
    private var bodyBeauty: FUBodyBeauty? {
        return FURenderKit.share().bodyBeauty
    }
    
    /// 启动
    func furenderSetUp(call: FlutterMethodCall, result: @escaping FlutterResult) {
//        if beauty == nil {

//        }

        
        
        guard let map = call.arguments as? [String: Any] else {
            result(nil)
            return
        }
        
        
        let authPack = map["authPack"] as! [Int]
        
        let p: UnsafeMutablePointer<Int8> = UnsafeMutablePointer.allocate(capacity: authPack.count)
        
        for i in 0..<authPack.count {
            p.advanced(by: i).pointee = Int8(authPack[i])
        }

        let config = FUSetupConfig()
        let auth =  FUAuthPackMake(p, Int32(authPack.count))
        config.authPack = auth
        FURenderKit.setup(with: config)
        
        if let maxFace = map["maxFace"] as? Int {
            FUAIKit.share().maxTrackFaces = Int32(maxFace)
        }
        
        DispatchQueue.main.async {[weak self] in
            
            let facePath = Bundle.main.path(forResource: "ai_face_processor", ofType: "bundle")
            let bodyPath = Bundle.main.path(forResource: "ai_human_processor", ofType: "bundle")
            FUAIKit.loadAIMode(withAIType: FUAITYPE_HUMAN_PROCESSOR, dataPath: bodyPath!)
            FUAIKit.loadAIMode(withAIType: FUAITYPE_FACEPROCESSOR, dataPath: facePath!)
            /// Int32(0.5) = 0
            FUAIKit.setFaceTrackParam("mouth_expression_more_flexible", value: 0)
            
            let makeUpBundle = Bundle.main.path(forResource: "face_makeup", ofType: "bundle")!
            FURenderKit.share().makeup = FUMakeup.init(path: makeUpBundle, name: "face_makeup")

            let bodyBundle = Bundle.main.path(forResource: "body_slim", ofType: "bundle")!
            FURenderKit.share().bodyBeauty = FUBodyBeauty.init(path: bodyBundle, name: "body_slim")
            
            let bundle = Bundle.main.path(forResource: "face_beautification.bundle", ofType: nil)!
            FURenderKit.share().beauty = FUBeauty(path: bundle, name: "FUBeauty")
            
            guard let strongSelf = self else {
                return
            }
            
            //MARK: -原始参数设置
            if let skinMap = map["skin"] as? [String: Any] {
                strongSelf.skinSetting(map: skinMap)
            }
            if let shapeMap = map["shape"] as? [String: Any] {
                strongSelf.shapeSetting(map: shapeMap)
            }
            if let filterMap = map["filter"] as? [String: Any] {
                strongSelf.filterSetting(map: filterMap)
            }
            if let makeUpMap = map["makeUp"] as? [String: Any] {
                strongSelf.makeUpSetting(map: makeUpMap)
            }
            if let bodyBeautyMap = map["bodyBeauty"] as? [String: Any] {
                strongSelf.bodyBeauty(map: bodyBeautyMap)
            }
            
//                self.makeUp?.isMakeupOn = true
//                self.makeUp?.enable = false
//                self.bodyBeauty?.debug = 0
//                self.bodyBeauty?.enable = false
//
//                self.beauty?.heavyBlur = 0
//                self.beauty?.blurType = 2
//                self.beauty?.faceShape = 4
//                self.beauty?.enable = true
        }
    }
    
    
    /**
     相芯 美肤
     */
    func skinSetting(map: [String: Any]) {
        if let type = self.type, type != FuRenderChannel.skin {
            self.type = FuRenderChannel.skin
            resetValue()
        }else if self.type == nil {
            self.type = FuRenderChannel.skin
            resetValue()
        }
        //MARK: -skin（美肤）
        if let blurLevel = map["blurLevel"] as? Double {
            beauty?.blurLevel = blurLevel
        }
        
        if let colorLevel = map["colorLevel"] as? Double {
            beauty?.colorLevel = colorLevel
        }
        if let redLevel = map["redLevel"] as? Double {
            beauty?.redLevel = redLevel
        }
        if let sharpen = map["sharpen"] as? Double {
            beauty?.sharpen = sharpen
        }
        if let eyeBright = map["eyeBright"] as? Double {
            beauty?.eyeBright = eyeBright
        }
        if let toothWhiten = map["toothWhiten"] as? Double {
            beauty?.toothWhiten = toothWhiten
        }
        if let removePouchStrength = map["removePouchStrength"] as? Double {
            beauty?.removePouchStrength = removePouchStrength
        }
        if let removeNasolabialFoldsStrength = map["removeNasolabialFoldsStrength"] as? Double {
            beauty?.removeNasolabialFoldsStrength = removeNasolabialFoldsStrength
        }
    }
    
    
    /**
     美型设置*/
    func shapeSetting(map: [String: Any]) {
//        resetValue()
        if let type = self.type, type != FuRenderChannel.shape {
            self.type = FuRenderChannel.shape
            resetValue()
        }else if self.type == nil {
            self.type = FuRenderChannel.shape
            resetValue()
        }
        //MARK:- shape(美型)
        if let cheekThinning = map["cheekThinning"] as? Double {
            beauty?.cheekThinning = cheekThinning
        }
        
        if let cheekV = map["cheekV"] as? Double {
            beauty?.cheekV = cheekV
        }
        if let cheekNarrow = map["cheekNarrow"] as? Double {
            beauty?.cheekNarrow = cheekNarrow
        }
        if let cheekSmall = map["cheekSmall"] as? Double {
            beauty?.cheekSmall = cheekSmall
        }
        if let intensityCheekbones = map["intensityCheekbones"] as? Double {
            beauty?.intensityCheekbones = intensityCheekbones
        }
        if let intensityLowerJaw = map["intensityLowerJaw"] as? Double {
            beauty?.intensityLowerJaw = intensityLowerJaw
        }
        if let eyeEnlarging = map["eyeEnlarging"] as? Double {
            beauty?.eyeEnlarging = eyeEnlarging
        }
        if let intensityEyeCircle = map["intensityEyeCircle"] as? Double {
            beauty?.intensityEyeCircle = intensityEyeCircle
        }
        if let intensityChin = map["intensityChin"] as? Double {
            beauty?.intensityChin = intensityChin
        }
        if let intensityForehead = map["intensityForehead"] as? Double {
            beauty?.intensityForehead = intensityForehead
        }
        if let intensityNose = map["intensityNose"] as? Double {
            beauty?.intensityNose = intensityNose
        }
        if let intensityMouth = map["intensityMouth"] as? Double {
            beauty?.intensityMouth = intensityMouth
        }
        if let intensityCanthus = map["intensityCanthus"] as? Double {
            beauty?.intensityCanthus = intensityCanthus
        }
        if let intensityEyeSpace = map["intensityEyeSpace"] as? Double {
            beauty?.intensityEyeSpace = intensityEyeSpace
        }
        if let intensityEyeRotate = map["intensityEyeRotate"] as? Double {
            beauty?.intensityEyeRotate = intensityEyeRotate
        }
        if let intensityLongNose = map["intensityLongNose"] as? Double {
            beauty?.intensityLongNose = intensityLongNose
        }
        if let intensityPhiltrum = map["intensityPhiltrum"] as? Double {
            beauty?.intensityPhiltrum = intensityPhiltrum
        }
        if let intensitySmile = map["intensitySmile"] as? Double {
            beauty?.intensitySmile = intensitySmile
        }
//        resetValue()
    }
    
    
    /**
     相芯滤镜设置*/
    func filterSetting(map: [String: Any]){
        if let type = self.type, type != FuRenderChannel.filter {
            self.type = FuRenderChannel.filter
            resetValue()
        }else if self.type == nil {
            self.type = FuRenderChannel.filter
            resetValue()
        }
        //MARK:- filter（滤镜）
        if let imageName = map["imageName"] as? String {
            beauty?.filterName = FUFilter(rawValue: imageName)
        }
        
        if let filterLevel = map["filterLevel"] as? Double{
            beauty?.filterLevel = filterLevel
        }
    }
    
    
    /**
     相芯补妆*/
    func makeUpSetting(map: [String: Any]) {
        if let type = self.type, type != FuRenderChannel.makeUp {
            self.type = FuRenderChannel.makeUp
            resetValue()
        }else if self.type == nil {
            self.type = FuRenderChannel.makeUp
            resetValue()
        }
        //MARK:- makeup（补妆）
        if let imageName = map["imageName"] as? String, !imageName.isEmpty {
            if let path = Bundle.main.path(forResource: imageName, ofType: "bundle") {
                makeUp?.updatePackage(FUItem.init(path: path, name: imageName), needCleanSubItem: false)
            }else {
                makeUp?.updatePackage(nil, needCleanSubItem: false)
            }
        }
        
        if let intensity = map["intensity"] as? Double {
            makeUp?.intensity = intensity
        }
    }
    
    /**
     相芯美体*/
    func bodyBeauty(map: [String: Any]) {
        if let type = self.type, type != FuRenderChannel.bodyBeauty {
            self.type = FuRenderChannel.bodyBeauty
            resetValue()
        }else if self.type == nil {
            self.type = FuRenderChannel.bodyBeauty
            resetValue()
        }
        //MARK:- bodyBeauty（美体）
        if let bodySlimStrength = map["bodySlimStrength"] as? Double {
            bodyBeauty?.bodySlimStrength = bodySlimStrength
        }
        
        if let legSlimStrength = map["legSlimStrength"] as? Double {
            bodyBeauty?.legSlimStrength = legSlimStrength
        }
        if let waistSlimStrength = map["waistSlimStrength"] as? Double {
            bodyBeauty?.waistSlimStrength = waistSlimStrength
        }
        if let shoulderSlimStrength = map["shoulderSlimStrength"] as? Double {
            bodyBeauty?.shoulderSlimStrength = shoulderSlimStrength
        }
        if let hipSlimStrength = map["bodySlimStrength"] as? Double {
            bodyBeauty?.hipSlimStrength = hipSlimStrength
        }
        if let headSlim = map["headSlim"] as? Double {
            bodyBeauty?.headSlim = headSlim
        }
        if let legSlim = map["legSlim"] as? Double {
            bodyBeauty?.legSlim = legSlim
        }
    }
    
    private func resetValue() {
        FUAIKit.share().maxTrackFaces = 4
        switch type {
        case .makeUp:
            makeUp?.enable = true
            FURenderKit.share().makeup = makeUp
        case .filter:
            fallthrough
        case .skin:
            fallthrough
        case .shape:
            beauty?.enable = true
            FURenderKit.share().beauty = beauty
            break
        case .bodyBeauty:
            bodyBeauty?.enable = true
            FURenderKit.share().bodyBeauty = bodyBeauty
        default:
            break
        }
    }
}
