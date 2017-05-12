//
//  LyUtil.h
//  LyVuforia
//
//  Created by wJunes on 2017/3/21.
//  Copyright © 2017年 wJunes. All rights reserved.
//

#import <Foundation/Foundation.h>



#define SCREEN_BOUNDS                   [UIScreen mainScreen].bounds
#define SCREEN_SCALE                    [UIScreen mainScreen].nativeScale
#define SCREEN_SIZE                     [UIScreen mainScreen].bounds.size
#define SCREEN_WIDTH                    [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT                   [UIScreen mainScreen].bounds.size.height
#define SCREEN_CENTER

#define APPLICATION_ORIENTATION         [UIApplication sharedApplication].statusBarOrientation


static const CGFloat HorizontalMargin = 10.0;
static const CGFloat VerticalMargin = 5.0;


static NSString *ScaleAnimationKeyPath = @"transform.scale";
static NSString *OpacityAnimationKeyPath = @"opacity";
static NSString *RotationAnimationKeyPath = @"transform.rotation";
static NSString *PositionAnimationKeyPath = @"position";
static NSString *TranslationXAnimationKeyPath = @"transform.translation.x";
static NSString *TranslationYAnimationKeyPath = @"transform.translation.y";



@interface LyUtil : NSObject


+ (UIImage *)imageNamed:(NSString *)name;


@end
