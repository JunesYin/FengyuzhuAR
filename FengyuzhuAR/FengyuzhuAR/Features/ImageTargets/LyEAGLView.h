//
//  LyEAGLView.h
//  FengyuzhuAR
//
//  Created by wJunes on 2017/5/10.
//  Copyright © 2017年 Junes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Vuforia/UIGLViewProtocol.h>

#import "Texture.h"
#import "SampleApplicationSession.h"
#import "VideoPlayerHelper.h"
#import "SampleGLResourceHandler.h"
#import "SampleAppRenderer.h"



//#define isNeedRender3DModel_ImageTarget


#ifdef isNeedRender3DModel_ImageTarget
#import <GLKit/GLKit.h>
#import <SceneKit/SceneKit.h>
#endif


static const int kNumImageTargets = 12;

@class LyEAGLViewController;
@class LyProgressView;

@interface LyEAGLView : UIView <UIGLViewProtocol, SampleGLResourceHandler, SampleAppRendererControl>
{
    // 为每一个目标实例化一个VideoPlayerHelper
    VideoPlayerHelper *videoPlayerHelper[kNumImageTargets];
//    float videoPlaybackTime[kNumImageTargets];
    
//    LyEAGLViewController *videoPlaybackViewController;
    
    // 追踪物丢失目标后停止视频播放的计时器
    // Note: 被两个线程读写，但永远不会同时发生
    NSTimer *trackingLostTimer;
    
    // 为可能被同时读写的异步数据加锁
    NSLock *dataLock;
    
    // OpenGL ES context
    EAGLContext *context;
    
    // 用于渲染视图的帧缓存，颜色缓存，深度缓存
    GLuint defaultFramebuffer;
    GLuint colorRenderbuffer;
    GLuint depthRenderbuffer;
    
    // Shader handles
    GLuint shaderProgramID;
    GLint vertexHandle;
    GLint normalHandle;
    GLint textureCoordHandle;
    GLint mvpMatrixHandle;
    GLint texSampler2DHandle;
    
    // 用于绘制的纹理
    SampleAppRenderer *sampleAppRenderer;
    
#ifdef isNeedRender3DModel_ImageTarget
    NSMutableDictionary *dicScene;
    NSString *curSceneKey;
    NSString *nextSceneKey;
#endif
}


@property (weak, nonatomic) LyEAGLViewController *videoPlaybackViewController;;
@property (weak, nonatomic) SampleApplicationSession *vapp;

@property (strong, nonatomic) LyProgressView *progressView;


#ifdef isNeedRender3DModel_ImageTarget
@property (strong, nonatomic) SCNRenderer *renderer;
@property (strong, nonatomic) SCNNode *cameraNode;
@property (assign, nonatomic, readonly) SCNMatrix4 projectionTransform;
#endif








- (instancetype)initWithFrame:(CGRect)frame
           rootViewController:(LyEAGLViewController *)rootViewController
                   appSession:(SampleApplicationSession *)vapp;


- (void)prepare;
- (void)dismiss;

- (void)finishOpenGLESCommands;
- (void)freeOpenGLESResources;
- (void)configureVideoBackgroundWithViewWidth:(float)viewWidth andHeight:(float)viewHeight;

- (void)preparePlayers;
- (void)dismissPlayers;
- (void)updateRenderingPrimitives;


- (void)addSpecialEffects;
- (void)removeSpecialEffects;


@end
