//
//  LyEAGLView.h
//  FengyuzhuAR
//
//  Created by wJunes on 2017/5/10.
//  Copyright © 2017年 Junes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import <Vuforia/UIGLViewProtocol.h>
#import <SceneKit/SceneKit.h>

#import "Texture.h"
#import "SampleApplicationSession.h"
#import "VideoPlayerHelper.h"
#import "SampleGLResourceHandler.h"
#import "SampleAppRenderer.h"


static const int jNumVideoTargets = 2;



@interface LyEAGLView : UIView <UIGLViewProtocol, SampleGLResourceHandler, SampleAppRendererControl>
{
    // 为每一个目标实例化一个VideoPlayerHelper
    VideoPlayerHelper *videoPlayerHelper[jNumVideoTargets];
    float videoPlaybackTime[jNumVideoTargets];
    
    LyEAGLViewController *videoPlaybackViewController;
    
    // 追踪物丢失目标后停止视频播放的计时器
    // Note: 被两个线程读写，但永远不会同时发生
    NSTimer *trackingLostTimer;
    
    // 为可能被同时读写的异步数据加锁
    NSLock *dataLock;
    
    // OpenGL ES context
    EAGLContext *context;
    
    // 用于渲染视图的帧缓存，颜色缓存，深度缓存
    GLuint defaultFrameBuffer;
    GLuint colorRenderBuffer;
    GLuint depthRenderBuffer;
    
    // Shader handles
    GLuint shaderProgramID;
    GLint vertexHandle;
    GLint normalHandle;
    GLint textureCoordHandle;
    GLint mvpMatrixHandle;
    GLint texSampler2DHandle;
    
    // 用于绘制的纹理
//    Texture *augmentationTexure[jNumAugmentationTextures];
    SampleAppRenderer *sampleAppRenderer;
    
    
    NSMutableDictionary *dicScene;
    NSString *curSceneKey;
    NSString *nextSceneKey;
}


@property (weak, nonatomic) SampleApplicationSession *vapp;

@property (strong, nonatomic) SCNRenderer *renderer;
@property (strong, nonatomic) SCNNode *cameraNode;
@property (assign, nonatomic, readonly) SCNMatrix4 projectionTransform;
@property (assign, nonatomic) CFAbsoluteTime startTime;








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
