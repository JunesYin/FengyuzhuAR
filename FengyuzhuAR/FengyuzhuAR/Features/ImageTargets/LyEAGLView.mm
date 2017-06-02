//
//  LyEAGLView.m
//  FengyuzhuAR
//
//  Created by wJunes on 2017/5/10.
//  Copyright © 2017年 Junes. All rights reserved.
//

#import "LyEAGLView.h"
#import "LyProgressView.h"

#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <sys/time.h>

#import <Vuforia/Vuforia.h>
#import <Vuforia/State.h>
#import <Vuforia/Tool.h>
#import <Vuforia/Renderer.h>
#import <Vuforia/TrackableResult.h>
#import <Vuforia/ImageTarget.h>

#import "SampleApplicationUtils.h"
#import "SampleApplicationShaderUtils.h"
#import "SampleMath.h"
#import "Quad.h"


#import "LyUtil.h"


namespace {
 
    NSString *targetNames[kNumImageTargets] =
    {
        @"ChengXiangXiao",   // 承相孝
        @"CuiYongYuan",      // 崔永元
        @"GaoYiXiang",       // 高以翔
        @"GuoJingMing",      // 郭敬明
        @"HeJingTang",       // 何镜堂
        @"HuangLing",        // 黄龄
        @"LiuKaiWei",        // 刘恺威
        @"LuGengXu",         // 卢庚戌
        @"PanTao",           // 潘涛
        @"YangErJuNaMu",     // 杨二车娜姆
        @"YaoMing",          // 姚明
        @"ZhuDan",           // 朱丹
    };
    
    NSString *videoNames[kNumImageTargets] =
    {
        @"https://www.gendew.com/FyzExhibition/ChengXiangXiao.mp4",
        @"https://www.gendew.com/FyzExhibition/CuiYongYuan_GuoJingMing.mp4",
        @"https://www.gendew.com/FyzExhibition/GaoYiXiang.mp4",
        @"https://www.gendew.com/FyzExhibition/CuiYongYuan_GuoJingMing.mp4",
        @"https://www.gendew.com/FyzExhibition/HeJingTang.mp4",
        @"https://www.gendew.com/FyzExhibition/HuangLing.mp4",
        @"https://www.gendew.com/FyzExhibition/LiuKaiWei.mp4",
        @"https://www.gendew.com/FyzExhibition/LuGengXu.mp4",
        @"https://www.gendew.com/FyzExhibition/PanTao.mp4",
        @"https://www.gendew.com/FyzExhibition/YangErJuNaMu.mp4",
        @"https://www.gendew.com/FyzExhibition/YaoMing.mp4",
        @"https://www.gendew.com/FyzExhibition/ZhuDan.mp4",
    };
    
    NSDictionary *dicVideoUrls = @{
                                   targetNames[0]: videoNames[0],
                                   targetNames[1]: videoNames[1],
                                   targetNames[2]: videoNames[2],
                                   targetNames[3]: videoNames[3],
                                   targetNames[4]: videoNames[4],
                                   targetNames[5]: videoNames[5],
                                   targetNames[6]: videoNames[6],
                                   targetNames[7]: videoNames[7],
                                   targetNames[8]: videoNames[8],
                                   targetNames[9]: videoNames[9],
                                   targetNames[10]: videoNames[10],
                                   targetNames[11]: videoNames[11],
                                   targetNames[12]: videoNames[12],
                                   };
    
    
#ifdef isNeedRender3DModel_ImageTarget
    NSString *daeNames[kNumImageTargets] =
    {
        @"huotuo",
        @"huotuo",
        @"huotuo",
        @"huotuo",
        @"huotuo",
        @"huotuo",
        @"huotuo",
        @"huotuo",
        @"huotuo",
        @"huotuo",
        @"huotuo",
        @"huotuo",
    };
#endif

    
    const NSTimeInterval TRACKING_LOST_TIMEOUT = 0.01f;
    
    // 视频四边纹理坐标
    const GLfloat videoQuadTextureCoords[] =
    {
        0.0, 1.0,
        1.0, 1.0,
        1.0, 0.0,
        0.0, 0.0
    };
    
    struct tagVideoData {
        // 计算触摸点是否在目标内
        Vuforia::Matrix44F modelViewMatrix;
        
        // 可追踪物的大小
        Vuforia::Vec2F targetPositiveDimensions;
        
        // 当前是否激活
        BOOL isActive;
    } videoData[kNumImageTargets];
    
    
    static const float jObjectScaleLevel = 0.1f;
    
    
    static NSString *ScanGearAnimationKey = @"ScanGearAnimationKey";
    static const CGFloat ScanGearAnimationDuration = 30;
    
    static NSString *ScanAdornAnimationKey = @"ScanAdornAnimationKey";
    static const CGFloat ScanAdornAnimationDuration = 60;
    
    static NSString *ScanGridAnimationKey = @"ScanGridAnimationKey";
    static const CGFloat ScanGridAnimationDuration = 5;
}




@interface LyEAGLView (PrivateMethods)

- (void)initShaders;
- (void)createFramebuffer;
- (void)deleteFramebuffer;
- (void)setFramebuffer;
- (BOOL)presentFramebuffer;

@end



@interface LyEAGLView ()
{
    UIImageView *ivScanMaskGrid;
    
    UIImageView *ivScanGear;
    UIImageView *ivScanAdorn;
    
    UIView *viewScanPane;
    UIImageView *ivScanGrid;
}

@end



@implementation LyEAGLView

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}


#pragma mark - Lifecycle
- (instancetype)initWithFrame:(CGRect)frame
           rootViewController:(LyEAGLViewController *)rootViewController
                   appSession:(SampleApplicationSession *)vapp
{
    if (self = [super initWithFrame:frame])
    {
        _vapp = vapp;
        
        _videoPlaybackViewController = rootViewController;
        
        // 启用视网膜模式(retina)
        if ([_vapp isRetinaDisplay])
        {
            [self setContentScaleFactor:SCREEN_SCALE];
        }
        
        
        // 创建OpenGL ES context
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        
        if (context != [EAGLContext currentContext])
        {
            [EAGLContext setCurrentContext:context];
        }
        
        
        sampleAppRenderer = [[SampleAppRenderer alloc] initWithSampleAppRendererControl:self
                                                                           deviceMode:Vuforia::Device::MODE_AR
                                                                               stereo:false
                                                                            nearPlane:0.01
                                                                             farPlane:5];
        
        
        [sampleAppRenderer initRendering];
        [self initShaders];
        
#ifdef isNeedRender3DModel_ImageTarget
        _renderer = [SCNRenderer rendererWithContext:context options:nil];
        _renderer.playing = YES;
    
        dicScene = [[NSMutableDictionary alloc] initWithCapacity:1];
#endif
        
        
        // Blue mask grid
        ivScanMaskGrid = [[UIImageView alloc] initWithFrame:SCREEN_BOUNDS];
        ivScanMaskGrid.image = [LyUtil imageNamed:@"ScanMaskGrid"];
        ivScanMaskGrid.contentMode = UIViewContentModeScaleAspectFit;
        
        // Scan gear
        CGFloat ivScanGearWidth = SCREEN_WIDTH * 1.1;
        ivScanGear = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH/2.0 - ivScanGearWidth/2.0), SCREEN_HEIGHT/2.0 - ivScanGearWidth/2.0, ivScanGearWidth, ivScanGearWidth)];
        ivScanGear.image = [LyUtil imageNamed:@"ScanGear"];
        ivScanGear.contentMode = UIViewContentModeScaleAspectFill;
        
        // Scan adorn
        CGFloat ivScanAdornWidth = ivScanGearWidth + 20.0;
        ivScanAdorn = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2.0 - ivScanAdornWidth/2.0, SCREEN_HEIGHT/2.0 - ivScanAdornWidth/2.0, ivScanAdornWidth, ivScanAdornWidth)];
        ivScanAdorn.contentMode = UIViewContentModeScaleAspectFill;
        ivScanAdorn.image = [LyUtil imageNamed:@"ScanAdorn"];
        ivScanAdorn.clipsToBounds = YES;
        
        // Scan pane
        viewScanPane = [[UIView alloc] initWithFrame:ivScanGear.frame];
        viewScanPane.backgroundColor = [UIColor clearColor];
        viewScanPane.clipsToBounds = YES;
        viewScanPane.layer.cornerRadius = ivScanGearWidth / 2.0;
        
        // Scan grid
        UIImage *image = [LyUtil imageNamed:@"ScanGrid"];
        CGFloat ivScanGridWidth = ivScanGearWidth;
        CGFloat ivScanGridHeight = ivScanGearWidth * image.size.height / image.size.width;
        ivScanGrid = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ivScanGridWidth, ivScanGridHeight)];
        ivScanGrid.image = image;
        ivScanGrid.contentMode = UIViewContentModeScaleAspectFill;
        ivScanGrid.alpha = 0.5;
        
        
        [self addSubview:ivScanMaskGrid];
        [self addSubview:ivScanGear];
        [self addSubview:ivScanAdorn];
        [self addSubview:viewScanPane];
        
    }
    
    return self;
}


- (void)prepare
{
//    // 遍历每个目标，撞见VideoPlayerHelper对象，并将目标唯独置零
//    for (int i = 0; i < kNumImageTargets; ++i)
//    {
//        videoPlayerHelper[i] = [[VideoPlayerHelper alloc] initWithRootViewController:videoPlaybackViewController];
//        videoData[i].targetPositiveDimensions.data[0] = 0.0;
//        videoData[i].targetPositiveDimensions.data[1] = 0.0;
//    }
//    
//    // 应用首次运行的当前位置（开始位置）开始播放视频
//    for (int i = 0; i < kNumImageTargets; ++i)
//    {
//        videoPlaybackTime[i] = VIDEO_PLAYBACK_CURRENT_POSITION;
//    }
//    
//    // 遍历每个视频增强物目标
//    for (int i = 0; i < kNumImageTargets; ++i)
//    {
//        // 为播放读取本地文件，如果应用进入后台时正在播放则唤醒播放
//        if (![videoPlayerHelper[i] load:videoNames[i] playImmediately:YES fromPosition:videoPlaybackTime[i]])
//        {
//            NSLog(@"Fialed to load media");
//        }
//    }
    
    for (int i = 0; i < kNumImageTargets; ++i)
    {
        // 遍历每个目标，撞创建VideoPlayerHelper对象，并将目标唯独置零
        videoPlayerHelper[i] = [[VideoPlayerHelper alloc] initWithRootViewController:_videoPlaybackViewController];
        videoData[i].targetPositiveDimensions.data[0] = 0.0;
        videoData[i].targetPositiveDimensions.data[1] = 0.0;
        
//        // 应用首次运行的当前位置（开始位置）开始播放视频
//        videoPlaybackTime[i] = VIDEO_PLAYBACK_CURRENT_POSITION;
        
//        // 为播放读取本地文件，如果应用进入后台时正在播放则唤醒播放
//        if (![videoPlayerHelper[i] load:videoNames[i] playImmediately:YES fromPosition:VIDEO_PLAYBACK_CURRENT_POSITION])
//        {
//            NSLog(@"Fialed to load media");
//        }
        
        
    }
}


- (void)dismiss
{
    for (int i = 0; i < kNumImageTargets; ++i)
    {
        [videoPlayerHelper[i] unload];
        videoPlayerHelper[i] = nil;
    }
}


- (void)dealloc
{
    [self deleteFramebuffer];
    
    // 销毁context
    if (context == [EAGLContext currentContext])
    {
        [EAGLContext setCurrentContext:nil];
    }
    
    
    for (int i = 0; i < kNumImageTargets; ++i)
    {
        videoPlayerHelper[i] = nil;
    }
}


/*
 * 被applicationWillResignActive
 * 渲染循环已经停止，确保在进入后台之前所有OpenGL ES置零都已完成
 */
- (void)finishOpenGLESCommands
{
    if (context)
    {
        [EAGLContext setCurrentContext:context];
        glFinish();
    }
}



/*
 * 被applicationDidEnterBackground调用
 * 释放可重建的OpenGL ES资源
 */
- (void)freeOpenGLESResources
{
    [self deleteFramebuffer];
    glFinish();
}


- (void)preparePlayers
{
    [self prepare];
}


- (void)dismissPlayers
{
    [self dismiss];
}


- (void)updateRenderingPrimitives
{
    [sampleAppRenderer updateRenderingPrimitives];
}


#pragma mark - Data Choose
- (int)imageIndexFrom:(const Vuforia::ImageTarget &)imageTarget
{
    int imageIndex = -1;
#ifdef isNeedRender3DModel_ImageTarget
    nextSceneKey = @"";
#endif
    
    const char *targetName = imageTarget.getName();
    for (int i = 0; i < kNumImageTargets; ++i)
    {
        if (0 == strcmp(targetName, [targetNames[i] cStringUsingEncoding:NSUTF8StringEncoding]))
        {
            imageIndex = i;
#ifdef isNeedRender3DModel_ImageTarget
            nextSceneKey = daeNames[i];
#endif
            break;
        }
    }
    
//    NSLog(@"当前识别：%s  index:%d", targetName, imageIndex);
    
    return imageIndex;
}

#ifdef isNeedRender3DModel_ImageTarget
- (BOOL)changeSceneWithKey:(NSString *)key
{
    if (nil == key || key.length < 1)
    {
        return NO;
    }
    
    if ([key isEqualToString:curSceneKey])
    {
        return YES;
    }
    
    curSceneKey = key;
    SCNScene *scene = dicScene[curSceneKey];
    if (nil == scene)
    {
        NSString *sceneName = [[NSString alloc] initWithFormat:@"DAE.scnassets/%@.DAE", curSceneKey];
        scene = [SCNScene sceneNamed:sceneName];
        
        if (nil == scene)
        {
            return NO;
        }
        
        SCNCamera *camera = [SCNCamera camera];
        SCNNode *cameraNode = [SCNNode node];
        cameraNode.camera = camera;
        cameraNode.camera.projectionTransform = _projectionTransform;
        [scene.rootNode addChildNode:cameraNode];
        _cameraNode = cameraNode;
        
        SCNLight *light = [SCNLight light];
        SCNNode *lightNode = [SCNNode node];
        lightNode.light = light;
        lightNode.light.type = SCNLightTypeOmni;
        lightNode.position = SCNVector3Make(0, 120, 170);
        [scene.rootNode addChildNode:lightNode];
        
        [dicScene setObject:scene forKey:curSceneKey];
        
    }
    
    _renderer.scene = scene;
    _renderer.pointOfView = _cameraNode;
    
    return YES;
}
#endif


#pragma mark - UIGLViewProtoco methods
// 使用OpenGL绘制当前帧

/*
 * 自动被Vuforia调用，绘制当前帧缓存到屏幕
 * 可能由后台线程调用
 */
- (void)renderFrameVuforia
{
    if (!_vapp.cameraIsStarted)
    {
        return;
    }
    
    [sampleAppRenderer renderFrameVuforia];
}


- (void)renderFrameWithState:(const Vuforia::State &)state projectMatrix:(Vuforia::Matrix44F &)projectionMatrix
{
    [self setFramebuffer];
    
    // 清除之前的颜色缓存和深度缓存
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // 后台渲染视频
    [sampleAppRenderer renderVideoBackground];
    
    Vuforia::Renderer::getInstance().begin();
    Vuforia::Renderer::getInstance().drawVideoBackground();
    
    glEnable(GL_DEPTH_TEST);
    
    // We must detect if background reflection is active and adjust the culling
    // direction.  If the reflection is active, this means the pose matrix has
    // been reflected as well, therefore standard counter clockwise face culling
    // will result in "inside out" models
    // 必须检测背景反射是否激活，并调整提出方向。如果反射激活了，这意味着位置矩阵已经被很好反射出来了。
    // 因此标准的逆时针方向。。。。。。。
    glEnable(GL_CULL_FACE);
    glCullFace(GL_BACK);
    
    
    // 获取激活的可追踪物
    int numActiveTrackables = state.getNumTrackableResults();
    
    // ---------- 异步数据访问 begin -------
    [dataLock lock];
    
    // 假定所有目标都未激活（计算点击位置时使用）
    for (int i = 0; i < kNumImageTargets; ++i)
    {
        videoData[i].isActive = NO;
    }
    

    for (int i = 0; i < numActiveTrackables; ++i)
    {
        
        // 获取trackable
        const Vuforia::TrackableResult *trackableResult = state.getTrackableResult(i);
        const Vuforia::ImageTarget &imageTarget = (const Vuforia::ImageTarget &)trackableResult->getTrackable();
        
        // 当前target使用的VideoPlayerHelper
        int imageIndex = [self imageIndexFrom:imageTarget];
        
        if (!videoPlayerHelper[imageIndex].isLoaded)
        {
            [videoPlayerHelper[imageIndex] load:dicVideoUrls[targetNames[imageIndex]] playImmediately:YES fromPosition:VIDEO_PLAYBACK_CURRENT_POSITION];
        }
        
        
        // 标记video（target）为激活状态
        videoData[imageIndex].isActive = YES;
        
        
        // 获取target尺寸（用于计算点击点是否在target内）
        if (0.0 == videoData[imageIndex].targetPositiveDimensions.data[0] ||
            0.0 == videoData[imageIndex].targetPositiveDimensions.data[1])
        {
            Vuforia::Vec3F size = imageTarget.getSize();
            videoData[imageIndex].targetPositiveDimensions.data[0] = size.data[0];
            videoData[imageIndex].targetPositiveDimensions.data[1] = size.data[1];
            
            // 这个位置传递了这个target的中心，因此其规模从-width/2到width/2，从-height/2到height/2
            videoData[imageIndex].targetPositiveDimensions.data[0] /= 2.0f;
            videoData[imageIndex].targetPositiveDimensions.data[1] /= 2.0f;
        }
        
        
        // 获取当前trackable的位置
        const Vuforia::Matrix34F &trackablePose = trackableResult->getPose();
        
        // 此矩阵用于计算屏幕标记的位置
        videoData[imageIndex].modelViewMatrix = Vuforia::Tool::convertPose2GLMatrix(trackablePose);
        
        float aspectRatio = 0.0;
        const GLvoid *texCoords;
        GLuint frameTextureID = 0;
        BOOL displayVideoFrame = YES;
        

        
        // 保留调用之间的值
        static GLuint videoTextureID[kNumImageTargets] = {0};
        
        MEDIA_STATE curStatus = [videoPlayerHelper[imageIndex] getStatus];
        
        // ----- INFORMATION -----
        // 此时可以开始视频的自动播放，如果当前状态不是PLAYING，可以调用VideoPlayerHelper对象的播放方法来实现
        // 卫视更新curStatus，在调用播放方法之后，应该再次调用getStatus方法
        // ----- INFORMATION -----
        
        switch (curStatus) {
            case PLAYING: {
                // 如果tracking lost timer已经调度，终止
                if (nil != trackingLostTimer)
                {
                    // 计时器的终止操作必须在调度的线程执行
                    [self performSelectorOnMainThread:@selector(terminateTrackingLostTimer) withObject:nil waitUntilDone:YES];
                }
                
                // 将最新的解码视频数据上传到OpenGL并获取视频纹理ID
                GLuint videoTexID = [videoPlayerHelper[imageIndex] updateVideoData];
                
                if (0 == videoTextureID[imageIndex])
                {
                    videoTextureID[imageIndex] = videoTexID;
                }
                
                // Fallthrough
            }
            case PAUSED: {
                if (0 == videoTextureID[imageIndex])
                {
                    // 没有可用的视频纹理，展示关键帧
                    displayVideoFrame = NO;
                }
                else
                {
                    // 展示从[VideoPlayerHelper updateVideoData]中最近的纹理
                    frameTextureID = videoTextureID[imageIndex];
                }
                break;
            }
            default: {
                videoTextureID[imageIndex] = 0;
                displayVideoFrame = NO;
                break;
            }
        }
        
        
        if (displayVideoFrame)
        {
            // 展示视频帧
            aspectRatio = (float)[videoPlayerHelper[imageIndex] getVideoHeight] / (float)[videoPlayerHelper[imageIndex] getVideoWidth];
            
            texCoords = videoQuadTextureCoords;
        }
        
        
        // 如果当前状态为无效（ERROR或不是NOT_READY），渲染刚刚渲染的纹理的轮廓
        if (NOT_READY != curStatus && displayVideoFrame)
        {
            // 转换trackable的位置为矩阵以供OpenGL使用
            Vuforia::Matrix44F modelViewMatrixVideo = Vuforia::Tool::convertPose2GLMatrix(trackablePose);
            Vuforia::Matrix44F modelViewProjectionVideo;
            
            
            // 保持原有比例
            SampleApplicationUtils::scalePoseMatrix(videoData[imageIndex].targetPositiveDimensions.data[0],
                                                    videoData[imageIndex].targetPositiveDimensions.data[1],
                                                    videoData[imageIndex].targetPositiveDimensions.data[0],
                                                    modelViewMatrixVideo.data);
            
//            // 保持宽度
//            SampleApplicationUtils::scalePoseMatrix(videoData[imageIndex].targetPositiveDimensions.data[0],
//                                                    videoData[imageIndex].targetPositiveDimensions.data[0] * aspectRatio,
//                                                    videoData[imageIndex].targetPositiveDimensions.data[0],
//                                                    modelViewMatrixVideo.data);
            
//            // 保持高度
//            SampleApplicationUtils::scalePoseMatrix(videoData[imageIndex].targetPositiveDimensions.data[1] / aspectRatio,
//                                                    videoData[imageIndex].targetPositiveDimensions.data[1],
//                                                    videoData[imageIndex].targetPositiveDimensions.data[0],
//                                                    modelViewMatrixVideo.data);
            
            
            SampleApplicationUtils::multiplyMatrix(projectionMatrix.data,
                                                   modelViewMatrixVideo.data,
                                                   modelViewProjectionVideo.data);
            
            glUseProgram(shaderProgramID);
            
            glVertexAttribPointer(vertexHandle, 3, GL_FLOAT, GL_FALSE, 0, quadVertices);
            glVertexAttribPointer(normalHandle, 3, GL_FLOAT, GL_FALSE, 0, quadNormals);
            glVertexAttribPointer(textureCoordHandle, 2, GL_FLOAT, GL_FALSE, 0, texCoords);
            
            glEnableVertexAttribArray(vertexHandle);
            glEnableVertexAttribArray(normalHandle);
            glEnableVertexAttribArray(textureCoordHandle);
            
            glActiveTexture(GL_TEXTURE0);
            glBindTexture(GL_TEXTURE_2D, frameTextureID);
            glUniformMatrix4fv(mvpMatrixHandle, 1, GL_FALSE, (GLfloat *)modelViewProjectionVideo.data);
            glUniform1i(texSampler2DHandle, 0 /* GL_TEXTURE0 */);
            glDrawElements(GL_TRIANGLES, kNumQuadIndices, GL_UNSIGNED_SHORT, quadIndices);
            
            glDisableVertexAttribArray(vertexHandle);
            glDisableVertexAttribArray(normalHandle);
            glDisableVertexAttribArray(textureCoordHandle);
            
            glUseProgram(0);
        }
        
#ifdef isNeedRender3DModel_ImageTarget
        // 渲染3D模型
        
        
        if (PLAYING == curStatus)
        {
            if ([self changeSceneWithKey:nextSceneKey])
            {
                [self setProjectionMatrix:projectionMatrix];
                
                
                // 获取modelViewMatrix
                Vuforia::Matrix44F modelViewMatrix = Vuforia::Tool::convertPose2GLMatrix(trackablePose);
                
                SampleApplicationUtils::translatePoseMatrix(0.1,
                                                            -0.1,
                                                            jObjectScaleLevel,
                                                            modelViewMatrix.data);
                SampleApplicationUtils::scalePoseMatrix(0.001,
                                                        0.001,
                                                        0.001,
                                                        modelViewMatrix.data);
                
                [self setCameraMatrix:modelViewMatrix];
                
                [_renderer renderAtTime:CFAbsoluteTimeGetCurrent()];
            }
        }
#endif
        
        if (ERROR != curStatus && NOT_READY != curStatus && PLAYING != curStatus )
        {
            // 播放视频
            NSLog(@"Playing video with on-texture player");
            [videoPlayerHelper[imageIndex] play:NO fromPosition:VIDEO_PLAYBACK_CURRENT_POSITION];
        }
        
        SampleApplicationUtils::checkGlError("VideoPlayback renderFrameVuforia");
        
        
        float loadProgress = videoPlayerHelper[imageIndex].loadProgress;
        AVPlayerTimeControlStatus playerStatus = videoPlayerHelper[imageIndex].player.timeControlStatus;
        
//        NSLog(@"loadProgress: %.2f      playerStatus: %d", loadProgress, (int)playerStatus);
        NSLog(@"imageName: %@-------loadProgress: %.0f%%", targetNames[imageIndex], loadProgress * 100.0);
        
        if (loadProgress < 1.0 && AVPlayerTimeControlStatusPlaying != playerStatus)
        {
            if (nil == _progressView)
            {
                _progressView = [[LyProgressView alloc] initWithFrame:CGRectMake(0, 0, 70, 70)];
            }
            
            if (nil == _progressView.superview)
            {
                [self addSubview:_progressView];
            }
            
            CGPoint center = [self getScreenPointByPose:trackablePose];
            _progressView.center = center;
            
//            Vuforia::Matrix44F modelViewMatrix = Vuforia::Tool::convertPose2GLMatrix(trackablePose);
//            [_progressView.layer setTransform:[self CATransform3DFromVuforiaMatrix44:modelViewMatrix]];
            
            _progressView.progress = loadProgress;
        }
        else
        {
            [_progressView removeFromSuperview];
            _progressView = nil;
        }
    }
    
    
    // ------- INFORMATION -------
    // 此时可以停止视频的自动播放，只需啊哟滴啊用VideoPlayerHelper的pause方法（不需要设置计时器）
    // ------- INFORMATION -------
    
    // 如果视频正在纹理上播放并且失去了目标物的追踪，在主线程创建一个计时器
    // 这个计时器将在TRACKING_LOST_TIMEOUT秒后暂停视频的播放
    for (int i = 0; i < kNumImageTargets; ++i)
    {
        if (nil == trackingLostTimer && !videoData[i].isActive && PLAYING == [videoPlayerHelper[i] getStatus])
        {
            
            if (nil != _progressView && _progressView.superview)
            {
                [_progressView removeFromSuperview];
                _progressView = nil;
            }
            
            [self performSelectorOnMainThread:@selector(createTrackingLostTimer) withObject:nil waitUntilDone:YES];
            
//            break;
        }
            
    }
    
    [dataLock unlock];
    //  ------- 异步数据访问 end -------
    
    glDisable(GL_DEPTH_TEST);
    glDisable(GL_CULL_FACE);
    
    Vuforia::Renderer::getInstance().end();
    
    [self presentFramebuffer];
}


/*
 * 创建追踪丢失计时器
 */
- (void)createTrackingLostTimer
{
    trackingLostTimer = [NSTimer scheduledTimerWithTimeInterval:TRACKING_LOST_TIMEOUT
                                                         target:self
                                                       selector:@selector(trackingLostTimerFired:)
                                                       userInfo:nil
                                                        repeats:NO];
}


/*
 * 终止追踪丢失计时器
 */
- (void)terminateTrackingLostTimer
{
    [trackingLostTimer invalidate];
    trackingLostTimer = nil;
}


/*
 * 追踪丢失计时器出发，暂停视频播放
 */
- (void)trackingLostTimerFired:(NSTimer *)timer
{
    // Tracking丢失了TRACKING_LOST_TIMEOUT秒，停止播放（安全地对所有VideoPlayerHelper对象操作）
    for (int i = 0; i < kNumImageTargets; ++i)
    {
        [videoPlayerHelper[i] pause];
    }
    
    trackingLostTimer = nil;
}



- (void)configureVideoBackgroundWithViewWidth:(float)viewWidth andHeight:(float)viewHeight
{
    [sampleAppRenderer configureVideoBackgroundWithViewWidth:viewWidth andHeight:viewHeight];
}



#pragma mark - OpenGL ES management
- (void)initShaders
{
    shaderProgramID = [SampleApplicationShaderUtils createProgramWithVertexShaderFileName:@"Simple.vertsh"
                                                                   fragmentShaderFileName:@"Simple.fragsh"];
    
    if (0 < shaderProgramID)
    {
        vertexHandle = glGetAttribLocation(shaderProgramID, "vertexPosition");
        normalHandle = glGetAttribLocation(shaderProgramID, "vertexNormal");
        textureCoordHandle = glGetAttribLocation(shaderProgramID, "vertexTexCoord");
        mvpMatrixHandle = glGetUniformLocation(shaderProgramID, "modelViewProjectionMatrix");
        texSampler2DHandle = glGetUniformLocation(shaderProgramID, "texSampler2D");
    }
    else
    {
        NSLog(@"Could not initialize augmentation shader");
    }
}


- (void)createFramebuffer
{
    if (context)
    {
        // 创建默认帧缓存对象
        glGenFramebuffers(1, &defaultFramebuffer);
        glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
        
        // 创建颜色缓存并分配空间
        glGenRenderbuffers(1, &colorRenderbuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
        
        // 为颜色缓存分配空间（与绘画对象共享）
        [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
        GLint frameBufferWidth;
        GLint frameBufferHeight;
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &frameBufferWidth);
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &frameBufferHeight);
        
        // 创建深度缓存并分配空间
        glGenRenderbuffers(1, &depthRenderbuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, depthRenderbuffer);
        glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, frameBufferWidth, frameBufferHeight);
        
        // 将颜色缓存和深度缓存附加到帧缓存上
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderbuffer);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRenderbuffer);
        
        // 保留颜色渲染缓存区，以便将来渲染操作可以直接对其作用
        glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
    }
}


- (void)deleteFramebuffer
{
    if (context)
    {
        [EAGLContext setCurrentContext:context];
        
        if (defaultFramebuffer)
        {
            glDeleteFramebuffers(1, &defaultFramebuffer);
            defaultFramebuffer = 0;
        }
        
        if (colorRenderbuffer)
        {
            glDeleteRenderbuffers(1, &colorRenderbuffer);
            colorRenderbuffer = 0;
        }
        
        if (depthRenderbuffer)
        {
            glDeleteRenderbuffers(1, &depthRenderbuffer);
            depthRenderbuffer = 0;
        }
    }
}


- (void)setFramebuffer
{
    if (context != [EAGLContext currentContext])
    {
        [EAGLContext setCurrentContext:context];
    }
    
    if (!defaultFramebuffer)
    {
        // 在主线程执行以确保共享内存的分配
        // 上述操作结束才停止阻塞以防止同时访问OpenGL ES context
        [self performSelectorOnMainThread:@selector(createFramebuffer) withObject:self waitUntilDone:YES];
    }
    
    glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
}


/*
 * 必须在presentFramebuffer之前调用
 * 因此，此时context有效，并且已设置为当前context
 */
- (BOOL)presentFramebuffer
{
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
    
    return [context presentRenderbuffer:GL_RENDERBUFFER];
}




- (CGPoint)getScreenPointByPose:(Vuforia::Matrix34F)pose
{
    // need to account for the orientation on view size
    CGFloat viewWidth = self.frame.size.height; // Portrait
    CGFloat viewHeight = self.frame.size.width; // Portrait
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsLandscape(orientation))
    {
        viewWidth = self.frame.size.width;
        viewHeight = self.frame.size.height;
    }
    
    // calculate any mismatch of screen to video size
    Vuforia::CameraDevice& cameraDevice = Vuforia::CameraDevice::getInstance();
    const Vuforia::CameraCalibration& cameraCalibration = cameraDevice.getCameraCalibration();
    Vuforia::VideoMode videoMode = cameraDevice.getVideoMode(Vuforia::CameraDevice::MODE_DEFAULT);
    
    CGFloat scale = viewWidth/videoMode.mWidth;
    if (videoMode.mHeight * scale < viewHeight)
        scale = viewHeight/videoMode.mHeight;
    CGFloat scaledWidth = videoMode.mWidth * scale;
    CGFloat scaledHeight = videoMode.mHeight * scale;
    
    CGPoint margin = {(scaledWidth - viewWidth)/2, (scaledHeight - viewHeight)/2};
    CGPoint center =[self projectCoord:CGPointMake(0,0) inView:cameraCalibration andPose:pose withOffset:margin andScale:scale];
    //    NSLog(@"center = %@",[NSValue valueWithCGPoint:center]);
    
    CGPoint centerNew = center;
    centerNew.x = viewHeight - center.y;
    centerNew.y = center.x;
    //    NSLog(@"centerNew = %@",[NSValue valueWithCGPoint:centerNew]);
    
    return  centerNew;
    
}

- (CGPoint) projectCoord:(CGPoint)coord inView:(const Vuforia::CameraCalibration&)cameraCalibration andPose:(Vuforia::Matrix34F)pose withOffset:(CGPoint)offset andScale:(CGFloat)scale
{
    CGPoint converted;
    
    Vuforia::Vec3F vec(coord.x,coord.y,0);
    Vuforia::Vec2F sc = Vuforia::Tool::projectPoint(cameraCalibration, pose, vec);
    converted.x = sc.data[0]*scale - offset.x;
    converted.y = sc.data[1]*scale - offset.y;
    
    return converted;
}



- (CATransform3D)CATransform3DFromVuforiaMatrix44:(Vuforia::Matrix44F)matrix
{
    CATransform3D transform;
    transform.m11 = matrix.data[0];
    transform.m12 = matrix.data[1];
    transform.m13 = matrix.data[2];
    transform.m14 = matrix.data[3];
    
    transform.m21 = matrix.data[4];
    transform.m22 = matrix.data[5];
    transform.m23 = matrix.data[6];
    transform.m24 = matrix.data[7];
    
    transform.m31 = matrix.data[8];
    transform.m32 = matrix.data[9];
    transform.m33 = matrix.data[10];
    transform.m34 = matrix.data[11];
    
    transform.m41 = matrix.data[12];
    transform.m42 = matrix.data[13];
    transform.m43 = matrix.data[14];
    transform.m44 = matrix.data[15];
    
    return transform;
    
}


#ifdef isNeedRender3DModel_ImageTarget
- (SCNMatrix4)SCNMatrix4FromVuforiaMatrix44:(Vuforia::Matrix44F)matrix
{
    GLKMatrix4 glkMatrix;
    for (int i = 0; i < 16; ++i)
    {
        glkMatrix.m[i] = matrix.data[i];
    }
    
    return SCNMatrix4FromGLKMatrix4(glkMatrix);
}


/*
 * Set camerea node matrix
 */
- (void)setCameraMatrix:(Vuforia::Matrix44F)matrix
{
    SCNMatrix4 extrinsic = [self SCNMatrix4FromVuforiaMatrix44:matrix];
    SCNMatrix4 inverted = SCNMatrix4Invert(extrinsic);
    
    _cameraNode.transform = inverted;
}


- (void)setProjectionMatrix:(Vuforia::Matrix44F)matrix
{
    _cameraNode.camera.projectionTransform = _projectionTransform = [self SCNMatrix4FromVuforiaMatrix44:matrix];
}
#endif








- (void)addSpecialEffects
{
    [viewScanPane addSubview:ivScanGrid];
    
    // Scan gear animation
    CABasicAnimation *scanGearAnimation = [CABasicAnimation animationWithKeyPath:RotationAnimationKeyPath];
    scanGearAnimation.duration = ScanGearAnimationDuration;
    scanGearAnimation.fromValue = @(M_PI * 2);
    scanGearAnimation.toValue = @(0.0);
    scanGearAnimation.repeatCount = HUGE_VALF;
    scanGearAnimation.fillMode = kCAFillModeForwards;
    scanGearAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [ivScanGear.layer addAnimation:scanGearAnimation forKey:ScanGearAnimationKey];
    
    // Scan adorn animation
    CABasicAnimation *scanAdornAnimation = [CABasicAnimation animationWithKeyPath:RotationAnimationKeyPath];
    scanAdornAnimation.duration = ScanAdornAnimationDuration;
    scanAdornAnimation.fromValue = @(0.0);
    scanAdornAnimation.toValue = @(M_PI * 2);
    scanAdornAnimation.repeatCount = HUGE_VALF;
    [ivScanAdorn.layer addAnimation:scanAdornAnimation forKey:ScanAdornAnimationKey];
    
    // Scan grid animation
    CABasicAnimation *scanGridAnimation = [CABasicAnimation animationWithKeyPath:TranslationYAnimationKeyPath];
    scanGridAnimation.fromValue = @(-ivScanGear.bounds.size.height * 2);
    scanGridAnimation.toValue = @(ivScanGear.bounds.size.height);
    scanGridAnimation.duration = ScanGridAnimationDuration;
    scanGridAnimation.repeatCount = HUGE_VALF;
    scanGridAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [ivScanGrid.layer addAnimation:scanGridAnimation forKey:ScanGridAnimationKey];
}


- (void)removeSpecialEffects
{
    [ivScanGear.layer removeAllAnimations];
    [ivScanAdorn.layer removeAllAnimations];
    [ivScanGrid.layer removeAllAnimations];
    
    [ivScanGrid removeFromSuperview];
}




@end
