//
//  LyEAGLViewController.h
//  FengyuzhuAR
//
//  Created by wJunes on 2017/5/10.
//  Copyright © 2017年 Junes. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <Vuforia/DataSet.h>


@class LyEAGLView;
@class SampleApplicationSession;




@interface LyEAGLViewController : UIViewController
{
    Vuforia::DataSet *dataSet;
    BOOL isFullScreenPlayerPlaying;
    
    BOOL continuousAutoFocusEnabled;
}


@property (strong, nonatomic) LyEAGLView *eaglView;
@property (strong, nonatomic) SampleApplicationSession *vapp;


- (void)rootViewControllerPresentViewController:(UIViewController *)viewController inContext:(BOOL)curContext;

- (void)rootViewControllerDismissPresentedViewController;




@end
