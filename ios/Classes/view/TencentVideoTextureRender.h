//
//  TencentVideoTextureRender.h
//  tencent_trtc_cloud
//
//  Created by aydenli on 2021/3/30.
//

#import <UIKit/UIKit.h>
#import <Flutter/Flutter.h>
#import <TXLiteAVSDK_Professional/TRTCCloud.h>
#import <TXLiteAVSDK_Professional/TRTCCloudDef.h>
//#import <TXLiteAVSDK_TRTC/TRTCCloudDef.h>


NS_ASSUME_NONNULL_BEGIN

typedef void(^FrameUpdateCallback)(void);

@interface TencentVideoTextureRender : NSObject<FlutterTexture ,TRTCVideoRenderDelegate,TRTCVideoFrameDelegate> //TRTCVideoRenderDelegate


- (instancetype)initWithFrameCallback:(FrameUpdateCallback)calback;

@end

NS_ASSUME_NONNULL_END
