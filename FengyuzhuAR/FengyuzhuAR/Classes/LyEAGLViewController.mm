//
//  LyEAGLViewController.m
//  FengyuzhuAR
//
//  Created by wJunes on 2017/5/10.
//  Copyright © 2017年 Junes. All rights reserved.
//

#import "LyEAGLViewController.h"
#import "LyEAGLView.h"
#import "LyUtil.h"

#import "AppDelegate.h"
#import "SampleApplicationSession.h"

#import <Vuforia/Vuforia.h>
#import <Vuforia/TrackerManager.h>
#import <Vuforia/ObjectTracker.h>
#import <Vuforia/Trackable.h>
#import <Vuforia/DataSet.h>
#import <Vuforia/CameraDevice.h>




@interface LyEAGLViewController ()  <SampleApplicationControl>

@end

@implementation LyEAGLViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}




- (void)loadView
{
    _vapp = [[SampleApplicationSession alloc] initWithDelegate:self];
    
    _eaglView = [[LyEAGLView alloc] initWithFrame:[self getCurARViewFrame]
                               rootViewController:self
                                       appSession:_vapp];
    
    [self setView:_eaglView];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.glResourceHandler = _eaglView;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dismissARViewController)
                                                 name:@"kDismissARViewController"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(takeResignActive)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(takeBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    // 初始化AR
    [_vapp initAR:Vuforia::GL_20 orientation:APPLICATION_ORIENTATION];
}





- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_eaglView prepare];
    
    // 设置UINavigationControllerDelegate
    // 强制竖屏
    self.navigationController.delegate = (id<UINavigationControllerDelegate>)self;
    
//    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.translucent = YES;
    
    
    UIImage *image = [LyUtil imageNamed:@"AR"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    
    self.navigationItem.titleView = imageView;
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = NO;
}



- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [_eaglView addSpecialEffects];
}


/*
 * 全屏播放时调用
 * 检查布尔值防止AR关闭
 */
- (void)viewWillDisappear:(BOOL)animated
{
    if (!isFullScreenPlayerPlaying)
    {
        [_eaglView dismiss];
        
        [_vapp stopAR:nil];
        
        // Vuforia已经暂停，渲染线程停止执行，通知RootViewController的EAGLView应该
        // 停止一切OpenGL ES，置零
        [self finishOpenGLESCommands];
        
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        appDelegate.glResourceHandler = nil;
    }
    
    [_eaglView removeSpecialEffects];
    
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = YES;
}


- (CGRect)getCurARViewFrame
{
    CGRect viewFrame = SCREEN_BOUNDS;
    
    if (_vapp.isRetinaDisplay)
    {
        viewFrame.size.width *= SCREEN_SCALE;
        viewFrame.size.height *= SCREEN_SCALE;
    }
    
    return viewFrame;
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


/*
 * 被applicationWillResignActive调用
 * 通知EAGLView
 */
- (void)finishOpenGLESCommands
{
    [_eaglView finishOpenGLESCommands];
}


/*
 * 被applicationDidEnterBackground调用
 * 通知EAGLView
 */
- (void)freeOpenGLESResources
{
    [_eaglView freeOpenGLESResources];
}



#pragma mark - SampleApplicationControl
/*
 * 初始化应用tracker
 */
- (bool)doInitTrackers
{
    // 初始化image tracker
    Vuforia::TrackerManager &tackerManager = Vuforia::TrackerManager::getInstance();
    Vuforia::Tracker *trackerBase = tackerManager.initTracker(Vuforia::ObjectTracker::getClassType());
    
    if (NULL == trackerBase)
    {
        NSLog(@"ERROR: Faile to initialize ObjectTracker.");
        return false;
    }
    
    return true;
}


/*
 * 读取trackers关联数据
 */
- (bool)doLoadTrackersData
{
    return [self loadAndActivateImageTrackerDataSet:@"girl.xml"];
}


/*
 * 启动应用trackers
 */
- (bool)doStartTrackers
{
    Vuforia::setHint(Vuforia::HINT_MAX_SIMULTANEOUS_IMAGE_TARGETS, jNumVideoTargets);
    
    Vuforia::TrackerManager &trackerManager = Vuforia::TrackerManager::getInstance();
    Vuforia::Tracker *tracker = trackerManager.getTracker(Vuforia::ObjectTracker::getClassType());
    
    if (NULL == tracker)
    {
        return false;
    }
    
    tracker->start();
    
    return true;
        
}


/*
 * AR初始化过程完成回调
 */
- (void)onInitARDone:(NSError *)initError
{
    if (nil == initError)
    {
        NSError *error = nil;
        [_vapp startAR:Vuforia::CameraDevice::CAMERA_DIRECTION_BACK error:&error];
        
        [_eaglView updateRenderingPrimitives];
        
        // 默认情况，尝试设置持续自动对焦模式
        continuousAutoFocusEnabled = Vuforia::CameraDevice::getInstance().setFocusMode(Vuforia::CameraDevice::FOCUS_MODE_CONTINUOUSAUTO);
    }
    else
    {
        NSLog(@"ERROR: initalizing AR: %@", initError.description);
        __weak typeof(self) weakSelf = self;
        __weak typeof(initError) weakError = initError;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            __strong typeof(weakError) strongError = weakError;
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"ERROR"
                                                                           message:strongError.localizedDescription
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [[NSNotificationCenter defaultCenter] postNotificationName:@"kDismissARViewController" object:nil];
                                                    }]];
            
            [strongSelf presentViewController:alert animated:YES completion:nil];
        });
    }
}


- (void)dismissARViewController
{
    [self.navigationController popToRootViewControllerAnimated:NO];
}


- (void)configureVideoBackgroundWithViewWidth:(float)viewWidth andHeight:(float)viewHeight
{
    [_eaglView configureVideoBackgroundWithViewWidth:viewWidth andHeight:viewHeight];
}


/*
 * Update from the Vuforia loop
 */
- (void)onVuforiaUpdate:(Vuforia::State *)state
{
    
}


/*
 * 停止trackers
 */
- (bool)doStopTrackers
{
    Vuforia::TrackerManager &trackerManger = Vuforia::TrackerManager::getInstance();
    Vuforia::Tracker *tracker = trackerManger.getTracker(Vuforia::ObjectTracker::getClassType());
    
    if (NULL == tracker)
    {
        NSLog(@"ERROR: Fialed to get the tracker from the tracker manager");
        return false;
    }
    
    tracker->stop();
    
    return true;
}


/*
 * 销毁trackers关联数据
 */
- (bool)doUnloadTrackersData
{
    if (NULL != dataSet)
    {
        // 获取imageTracker
        Vuforia::TrackerManager &trackerManager = Vuforia::TrackerManager::getInstance();
        Vuforia::ObjectTracker *objectTracker = static_cast<Vuforia::ObjectTracker *>(trackerManager.getTracker(Vuforia::ObjectTracker::getClassType()));
        
        if (NULL == objectTracker)
        {
            NSLog(@"Failed to unload tracking data set because the ImageTracker has not been initialized");
            return false;
        }
        
        
        // 反激活dataSet
        if (!objectTracker->deactivateDataSet(dataSet))
        {
            NSLog(@"Failed to deactivate dataSet.");
            return false;
        }
        
        // 销毁dataSet
        if (!objectTracker->destroyDataSet(dataSet))
        {
            NSLog(@"Failed to destroy dataSet.");
            return false;
        }
        
        dataSet = NULL;
    }
    
    
    return true;
}


/*
 * 析构trackers
 */
- (bool)doDeinitTrackers
{
    Vuforia::TrackerManager &trackerManager = Vuforia::TrackerManager::getInstance();
    trackerManager.deinitTracker(Vuforia::ObjectTracker::getClassType());
    
    return true;
}


/*
 * 读取imageTracker dataSet
 */
- (BOOL)loadAndActivateImageTrackerDataSet:(NSString *)dataFile
{
    NSLog(@"loadAndActivateImageTrackerDataSet (%@)", dataFile);
    BOOL ret = YES;
    dataSet = NULL;
    
    Vuforia::TrackerManager &trackerManager = Vuforia::TrackerManager::getInstance();
    Vuforia::ObjectTracker *objectTracker = static_cast<Vuforia::ObjectTracker *>(trackerManager.getTracker(Vuforia::ObjectTracker::getClassType()));
    
    if (NULL == objectTracker)
    {
        NSLog(@"ERROR: Failed to get the ImageTracker from the TrackerManager");
        ret = NO;
    }
    else
    {
        dataSet = objectTracker->createDataSet();
        
        if (NULL != dataSet)
        {
            // 从应用本地资源读取dataSet
            if (!dataSet->load([dataFile cStringUsingEncoding:NSASCIIStringEncoding], Vuforia::STORAGE_APPRESOURCE))
            {
                NSLog(@"ERROR: Failed to load dataSet");
                objectTracker->destroyDataSet(dataSet);
                dataSet = NULL;
                ret = NO;
            }
            else
            {
                // 激活dataSet
                if (objectTracker->activateDataSet(dataSet))
                {
                    NSLog(@"INFO: Successfully activated dataSet");
                }
                else
                {
                    NSLog(@"ERROR: Failed to activate dataSet");
                    ret = NO;
                }
            }
        }
        else
        {
            NSLog(@"ERROR: Failed to create dataSet");
        }
    }
    
    return ret;
}



- (BOOL)setExtendedTrackingForDataSet:(Vuforia::DataSet *)theDataSet start:(BOOL)start
{
    BOOL result = YES;
    for (int tIdx = 0; tIdx < theDataSet->getNumTrackables(); ++tIdx)
    {
        Vuforia::Trackable *trackable = theDataSet->getTrackable(tIdx);
        if (start)
        {
            if (!trackable->startExtendedTracking())
            {
                NSLog(@"Failed to start extended tracking on: %s", trackable->getName());
                result = NO;
            }
        }
        else
        {
            if (!trackable->stopExtendedTracking())
            {
                NSLog(@"Failed to stop extended tracking: %s", trackable->getName());
                result = NO;
            }
        }
    }
    
    return result;
}


#pragma mark - Navigation
- (void)rootViewControllerPresentViewController:(UIViewController *)viewController inContext:(BOOL)curContext
{
    [self.navigationController pushViewController:viewController animated:YES];
}


- (void)rootViewControllerDismissPresentedViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}




#pragma mark - Notifacation
- (void)takeResignActive
{
    [_eaglView dismissPlayers];
    [_eaglView removeSpecialEffects];
    
    NSError *error = nil;
    if (![_vapp pauseAR:&error])
    {
        NSLog(@"ERROR: pausing AR: %@", error.description);
    }
}


- (void)takeBecomeActive
{
    [_eaglView preparePlayers];
    [_eaglView addSpecialEffects];
    
    NSError *error = nil;
    if (![_vapp resumeAR:&error])
    {
        NSLog(@"ERROR: resuming AR: %@", error.description);
    }
    
    [_eaglView updateRenderingPrimitives];
    
    // 为了唤醒AR， 重设闪光
    Vuforia::CameraDevice::getInstance().setFlashTorchMode(false);
}





@end
