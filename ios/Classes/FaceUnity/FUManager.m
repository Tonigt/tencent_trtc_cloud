//
//  FUManager.m
//  FULiveDemo
//
//  Created by 刘洋 on 2017/8/18.
//  Copyright © 2017年 刘洋. All rights reserved.
//

#import "FUManager.h"

#import <CoreMotion/CoreMotion.h>
#import "authpack.h"
#import <sys/utsname.h>


#import "FUTestRecorder.h"
#import <FURenderKit/FURenderKit.h>
#import <FURenderKit/FUAIKit.h>

@interface FUManager ()
@property (nonatomic, strong) CMMotionManager *motionManager;

@property (nonatomic, assign) FUImageOrientation deviceOrientation;



@end

static FUManager *shareManager = NULL;

@implementation FUManager

+ (FUManager *)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareManager = [[FUManager alloc] init];
    });

    return shareManager;
}

+ (void)authManager {
    
    FUSetupConfig *setupConfig = [[FUSetupConfig alloc] init];

    
    setupConfig.authPack = FUAuthPackMake(g_auth_package, sizeof(g_auth_package));
    // 初始化 FURenderKit
    [FURenderKit setupWithSetupConfig:setupConfig];
}

- (instancetype)init
{
    if (self = [super init]) {
        _asyncLoadQueue = dispatch_queue_create("com.faceLoadItem", DISPATCH_QUEUE_SERIAL);

        /**这里新增了一个参数shouldCreateContext，设为YES的话，不用在外部设置context操作，我们会在内部创建并持有一个context。
         还有设置为YES,则需要调用FURenderer.h中的接口，不能再调用funama.h中的接口。*/
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
        
//        FUSetupConfig *setupConfig = [[FUSetupConfig alloc] init];
//
//        setupConfig.authPack = FUAuthPackMake(g_auth_package, sizeof(g_auth_package));
//        // 初始化 FURenderKit  fuIsLibraryInit
//        [FURenderKit setupWithSetupConfig:setupConfig];
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            // 加载人脸 AI 模型
//            NSString *faceAIPath = [[NSBundle mainBundle] pathForResource:@"ai_face_processor" ofType:@"bundle"];
//            [FUAIKit loadAIModeWithAIType:FUAITYPE_FACEPROCESSOR dataPath:faceAIPath];
//
//            // 加载身体 AI 模型
//            NSString *bodyAIPath = [[NSBundle mainBundle] pathForResource:@"ai_human_processor" ofType:@"bundle"];
//            [FUAIKit loadAIModeWithAIType:FUAITYPE_HUMAN_PROCESSOR dataPath:bodyAIPath];

            CFAbsoluteTime endTime = (CFAbsoluteTimeGetCurrent() - startTime);

            //TODO: todo 是否需要用？？？？？
            /* 设置嘴巴灵活度 默认= 0*/ //
            float flexible = 0.5;
            [FUAIKit setFaceTrackParam:@"mouth_expression_more_flexible" value:flexible];
            NSLog(@"---%lf",endTime);
        });

        NSLog(@"faceunitySDK version:%@",[FURenderKit getVersion]);
        [FUAIKit shareKit].maxTrackFaces = 4;

        [[FUTestRecorder shareRecorder] setupRecord];
        
        self.viewModelManager = [FUViewModelManager new];
    }
    
    return self;
}


/**销毁全部道具*/
- (void)destoryItems
{
    [self.viewModelManager removeAllViewModel];
    
}

//-(void)getNeedRenderItems:()


#pragma mark -  render
/**将道具绘制到pixelBuffer*/
- (CVPixelBufferRef)renderItemsToPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    if (_isRender) {
        /* 美妆，美体，贴纸 性能问题不共用 */
        FURenderInput *input = [[FURenderInput alloc] init];
        // 处理效果对比问题
        input.renderConfig.imageOrientation = 0;
        input.pixelBuffer = pixelBuffer;
        //开启重力感应，内部会自动计算正确方向，设置fuSetDefaultRotationMode，无须外面设置
        input.renderConfig.gravityEnable = YES;
        
//        if (_flipx) {
//            
//            input.renderConfig.isFromFrontCamera = YES;
//        }
//        input.renderConfig.stickerFlipH = _flipx;
        input.renderConfig.readBackToPixelBuffer = YES;
        FURenderOutput *outPut = [[FURenderKit shareRenderKit] renderWithInput:input];
        pixelBuffer = outPut.pixelBuffer;
    }
    
    return pixelBuffer;
}

/**处理YUV*/
- (void)processFrameWithY:(void*)y U:(void*)u V:(void*)v yStride:(int)ystride uStride:(int)ustride vStride:(int)vstride FrameWidth:(int)width FrameHeight:(int)height {
    
//TODO: todo 可参考 - (CVPixelBufferRef)renderItemsToPixelBuffer:(CVPixelBufferRef)pixelBuffer 接入
    
//    if ([self isDeviceMotionChange]) {
//        fuSetDefaultRotationMode(self.deviceOrientation);
//        /* 解决旋转屏幕效果异常 onCameraChange*/
//        [FURenderer onCameraChange];
//    }
//
//    /* 由于 rose 妆可能会镜像，下面代码对妆容做镜像翻转 */
//     int temp = self.flipx? 1:0;
//    [FURenderer itemSetParam:items[FUNamaHandleTypeMakeup] withName:@"is_flip_points" value:@(temp)];
//
//    /* 美妆，美体，贴纸 性能问题不共用 */
//    static int readerItems[2] = {0};
//    readerItems[0] = items[FUNamaHandleTypeBeauty];
//    if (_currentType == FUDataTypeMakeup) {
//        readerItems[1] = items[FUNamaHandleTypeMakeup];
//    }
//    if (_currentType == FUDataTypeSticker) {
//        readerItems[1] = items[FUNamaHandleTypeItem];
//    }
//    if (_currentType == FUDataTypebody) {
//        readerItems[1] = items[FUNamaHandleTypeBodySlim];
//    }
//
//    [[FURenderer shareRenderer] renderFrame:y u:u  v:v  ystride:ystride ustride:ustride vstride:vstride width:width height:height frameId:frameID items:readerItems itemCount:2];
//    frameID ++ ;
}

/**将道具绘制到pixelBuffer*/

- (int)renderItemWithTexture:(int)texture Width:(int)width Height:(int)height {
    if (_isRender) {
      
        FURenderInput *input = [[FURenderInput alloc] init];
        // 处理效果对比问题
        input.renderConfig.imageOrientation = 0;
        FUTexture tex = {texture, CGSizeMake(width, height)};
        input.texture = tex;
        
        //开启重力感应，内部会自动计算正确方向，设置fuSetDefaultRotationMode，无须外面设置
        input.renderConfig.gravityEnable = YES;
        input.renderConfig.textureTransform = CCROT0_FLIPVERTICAL;
        if (_flipx) {
            
            input.renderConfig.isFromFrontCamera = YES;
        }
        input.renderConfig.stickerFlipH = !_flipx;
        FURenderOutput *outPut = [[FURenderKit shareRenderKit] renderWithInput:input];
       
        return outPut.texture.ID;
    }

//TODO: todo 可参考 - (CVPixelBufferRef)renderItemsToPixelBuffer:(CVPixelBufferRef)pixelBuffer 接入
    
//    if ([self isDeviceMotionChange]) {
//        // 设置识别方向
//        fuSetDefaultRotationMode(self.deviceOrientation);
//        /* 解决旋转屏幕效果异常 onCameraChange*/
//        [FURenderer onCameraChange];
//    }
//    [self prepareToRender];
//
//    /* 由于 rose 妆可能会镜像，下面代码对妆容做镜像翻转 */
//     int temp = self.flipx? 1:0;
//    [FURenderer itemSetParam:items[FUNamaHandleTypeMakeup] withName:@"is_flip_points" value:@(temp)];
//
//    /* 美妆，美体，贴纸 性能问题不共用 */
//    static int readerItems[2] = {0};
//    readerItems[0] = items[FUNamaHandleTypeBeauty];
//    if (_currentType == FUDataTypeMakeup) {
//        readerItems[1] = items[FUNamaHandleTypeMakeup];
//    }
//    if (_currentType == FUDataTypeSticker) {
//        readerItems[1] = items[FUNamaHandleTypeItem];
//    }
//    if (_currentType == FUDataTypebody) {
//        readerItems[1] = items[FUNamaHandleTypeBodySlim];
//    }
//
//    if(self.flipx){
//       fuRenderItemsEx2(FU_FORMAT_RGBA_TEXTURE,&texture, FU_FORMAT_RGBA_TEXTURE, &texture, width, height, frameID, readerItems, 2, NAMA_RENDER_OPTION_FLIP_X | NAMA_RENDER_FEATURE_FULL, NULL);
//    }else{
//       fuRenderItemsEx(FU_FORMAT_RGBA_TEXTURE, &texture, FU_FORMAT_RGBA_TEXTURE, &texture, width, height, frameID, readerItems, 2) ;
//    }
//
//    [self renderFlush];
//
//    frameID ++ ;
//
//    return texture;
    return 0;
}

// 此方法用于提高 FaceUnity SDK 和 腾讯 SDK 的兼容性
 static int enabled[10];
- (void)prepareToRender {
    for (int i = 0; i<10; i++) {
        glGetVertexAttribiv(i,GL_VERTEX_ATTRIB_ARRAY_ENABLED,&enabled[i]);
    }
}

// 此方法用于提高 FaceUnity SDK 和 腾讯 SDK 的兼容性
- (void)renderFlush {
    glFlush();
    
    for (int i = 0; i<10; i++) {
        
        if(enabled[i]){
            glEnableVertexAttribArray(i);
        }
        else{
            glDisableVertexAttribArray(i);
        }
    }
}


/**获取图像中人脸中心点*/
- (CGPoint)getFaceCenterInFrameSize:(CGSize)frameSize{
    
    static CGPoint preCenter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        preCenter = CGPointMake(0.5, 0.5);
    });
    
    // 获取人脸矩形框，坐标系原点为图像右下角，float数组为矩形框右下角及左上角两个点的x,y坐标（前两位为右下角的x,y信息，后两位为左上角的x,y信息）
    float faceRect[4];
    int ret = [FUAIKit getFaceInfo:0 name:@"face_rect" pret:faceRect number:4];
    
    if (ret == 0) {
        return preCenter;
    }
    
    // 计算出中心点的坐标值
    CGFloat centerX = (faceRect[0] + faceRect[2]) * 0.5;
    CGFloat centerY = (faceRect[1] + faceRect[3]) * 0.5;
    
    // 将坐标系转换成以左上角为原点的坐标系
    centerX = frameSize.width - centerX;
    centerX = centerX / frameSize.width;
    
    centerY = frameSize.height - centerY;
    centerY = centerY / frameSize.height;
    
    CGPoint center = CGPointMake(centerX, centerY);
    
    preCenter = center;
    
    return center;
}

/**获取75个人脸特征点*/
- (void)getLandmarks:(float *)landmarks
{
    int ret = [FUAIKit getFaceInfo:0 name:@"landmarks" pret:landmarks number:150];
    
    if (ret == 0) {
        memset(landmarks, 0, sizeof(float)*150);
    }
}


/**切换摄像头要调用此函数*/
- (void)onCameraChange
{
    [FUAIKit resetTrackedResult];
}

/**获取错误信息*/
- (NSString *)getError
{
    return [FURenderKit getSystemErrorString];
}


#pragma mark - VideoFilterDelegate
/// process your video frame here
- (CVPixelBufferRef)processFrame:(CVPixelBufferRef)frame {
    if(self.enabled) {
        [[FUTestRecorder shareRecorder] processFrameWithLog];
        CVPixelBufferRef buffer = [self renderItemsToPixelBuffer:frame];
        
        if ([self.delegate respondsToSelector:@selector(checkAI)]) {
            [self.delegate checkAI];
        }
        return buffer;
    }
    return frame;
}



@end
