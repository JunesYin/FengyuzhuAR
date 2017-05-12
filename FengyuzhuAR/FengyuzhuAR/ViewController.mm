//
//  ViewController.m
//  FengyuzhuAR
//
//  Created by wJunes on 2017/5/10.
//  Copyright © 2017年 Junes. All rights reserved.
//

#import "ViewController.h"

#import "LyEAGLViewController.h"
#import "LyUtil.h"


#import <QuartzCore/QuartzCore.h>



namespace {
    
    static NSString *CircleScaleAnimationKey = @"CircleScaleAnimationKey";
    
    static NSString *CircleOpacityAnimationKey = @"CircleOpaqueAnimationKey";
    
    static const CGFloat CircleScaleAnimationFromValue = 0.1;
    static const CGFloat CircleOpacityAnimationToValue = 0.0;
    static const CFTimeInterval CircleAnimationDuration = 6;
    
    static const CGFloat CircleCount = 5;
    
    
    
    
    
    static NSString *ShapeAnimationKey = @"ShapeAnimationKey";
    
    static const CGFloat ShapeAnimationDuration = 3.7;
    
    static const CGFloat ShapeScaleToValue = 0.3;
    
}


@interface ViewController ()
{
    NSArray *arrIvCircle;
    
}

@property (weak, nonatomic) IBOutlet UIButton *btnStart;

@property (weak, nonatomic) IBOutlet UIImageView *ivCircleSmall;

@property (weak, nonatomic) IBOutlet UIImageView *ivShape_1;
@property (weak, nonatomic) IBOutlet UIImageView *ivShape_2;
@property (weak, nonatomic) IBOutlet UIImageView *ivShape_3;
@property (weak, nonatomic) IBOutlet UIImageView *ivShape_4;
@property (weak, nonatomic) IBOutlet UIImageView *ivShape_5;
@property (weak, nonatomic) IBOutlet UIImageView *ivShape_6;
@property (weak, nonatomic) IBOutlet UIImageView *ivShape_7;
@property (weak, nonatomic) IBOutlet UIImageView *ivShape_8;
@property (weak, nonatomic) IBOutlet UIImageView *ivShape_9;
@property (weak, nonatomic) IBOutlet UIImageView *ivShape_10;
@property (weak, nonatomic) IBOutlet UIImageView *ivShape_11;
@property (weak, nonatomic) IBOutlet UIImageView *ivShape_12;
@property (weak, nonatomic) IBOutlet UIImageView *ivShape_13;
@property (weak, nonatomic) IBOutlet UIImageView *ivShape_14_1;
@property (weak, nonatomic) IBOutlet UIImageView *ivShape_14_2;
@property (weak, nonatomic) IBOutlet UIImageView *ivShape_15;
@property (weak, nonatomic) IBOutlet UIImageView *ivShape_16;
@property (weak, nonatomic) IBOutlet UIImageView *ivShape_17;



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.hidden = YES;
    self.navigationController.navigationItem.backBarButtonItem.title = @"";
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(takeResignActive)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(takeBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
 
    
    // 波纹
    CGFloat circleWidth = SCREEN_WIDTH * 0.9;
    CGRect circleRect = CGRectMake(SCREEN_WIDTH/2.0 - circleWidth/2.0, SCREEN_HEIGHT/2.0 - circleWidth/2.0, circleWidth, circleWidth);
    
    UIImageView *ivCircleMid_1 = [[UIImageView alloc] initWithFrame:circleRect];
    ivCircleMid_1.image = [LyUtil imageNamed:@"CircleMid"];
    
    UIImageView *ivCircleMid_2 = [[UIImageView alloc] initWithFrame:circleRect];
    ivCircleMid_2.image = [LyUtil imageNamed:@"CircleMid"];
    
    UIImageView *ivCircleHuge_1 = [[UIImageView alloc] initWithFrame:circleRect];
    ivCircleHuge_1.image = [LyUtil imageNamed:@"CircleHuge"];
    
    UIImageView *ivCircleHuge_2 = [[UIImageView alloc] initWithFrame:circleRect];
    ivCircleHuge_2.image = [LyUtil imageNamed:@"CircleHuge"];
    
    _ivCircleSmall.image = [LyUtil imageNamed:@"CircleSmall"];
 
    arrIvCircle = @[ivCircleMid_1, ivCircleHuge_1, ivCircleMid_2, ivCircleHuge_2, _ivCircleSmall];
    
    [self.view addSubview:ivCircleMid_1];
    [self.view addSubview:ivCircleMid_2];
    [self.view addSubview:ivCircleHuge_1];
    [self.view addSubview:ivCircleHuge_2];
//    [self.view addSubview:_ivCircleSmall];
    
    
    
    
    _ivShape_1.image = [LyUtil imageNamed:@"1"];
    _ivShape_2.image = [LyUtil imageNamed:@"2"];
    _ivShape_3.image = [LyUtil imageNamed:@"3"];
    _ivShape_4.image = [LyUtil imageNamed:@"4"];
    _ivShape_5.image = [LyUtil imageNamed:@"5"];
    _ivShape_6.image = [LyUtil imageNamed:@"6"];
    _ivShape_7.image = [LyUtil imageNamed:@"7"];
    _ivShape_8.image = [LyUtil imageNamed:@"8"];
    _ivShape_9.image = [LyUtil imageNamed:@"9"];
    _ivShape_10.image = [LyUtil imageNamed:@"10"];
    _ivShape_11.image = [LyUtil imageNamed:@"11"];
    _ivShape_12.image = [LyUtil imageNamed:@"12"];
    _ivShape_13.image = [LyUtil imageNamed:@"13"];
    _ivShape_14_1.image = [LyUtil imageNamed:@"14"];
    _ivShape_14_2.image = [LyUtil imageNamed:@"14"];
    _ivShape_15.image = [LyUtil imageNamed:@"15"];
    _ivShape_16.image = [LyUtil imageNamed:@"16"];
    _ivShape_17.image = [LyUtil imageNamed:@"17"];
    
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    arrIvCircle = nil;
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self addSpecialEffects];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self removeSpecialEffects];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (IBAction)takeStart:(UIButton *)sender {
    LyEAGLViewController *arViewController = [[LyEAGLViewController alloc] init];
    
    [self performSelector:@selector(start:) withObject:arViewController afterDelay:0.05];
}


- (void)start:(LyEAGLViewController *)arViewController
{
    [self.navigationController pushViewController:arViewController animated:NO];
}


- (void)addSpecialEffects
{
    
    CABasicAnimation *circleScaleAnimation = [CABasicAnimation animationWithKeyPath:ScaleAnimationKeyPath];
    circleScaleAnimation.fromValue = @(CircleScaleAnimationFromValue);
    circleScaleAnimation.toValue = @(1);
    
    CABasicAnimation *circleOpacityAnimation = [CABasicAnimation animationWithKeyPath:OpacityAnimationKeyPath];
    circleOpacityAnimation.fromValue = @(1);
    circleOpacityAnimation.toValue = @(CircleOpacityAnimationToValue);
    
    
    
    for (int i = 0; i < arrIvCircle.count; ++i) {
        UIImageView *ivCircle = arrIvCircle[i];
        ivCircle.hidden = NO;
        
        CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
        animationGroup.animations = @[circleScaleAnimation, circleOpacityAnimation];
        animationGroup.duration = CircleAnimationDuration;
        animationGroup.repeatCount = HUGE_VALF;
        animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        CFTimeInterval beginTime = CircleAnimationDuration / CircleCount * (CFTimeInterval)i;
//        if (arrIvCircle.count - 1 == i)
//        {
//            beginTime -= CircleAnimationDuration / CircleCount * (CFTimeInterval)i / (CFTimeInterval)(arrIvCircle.count / 3);
//        }
        animationGroup.beginTime = beginTime;
        [ivCircle.layer addAnimation:animationGroup forKey:CircleScaleAnimationKey];
    }
    
    
    
    _ivShape_1.hidden = NO;
    _ivShape_2.hidden = NO;
    _ivShape_3.hidden = NO;
    _ivShape_4.hidden = NO;
    _ivShape_5.hidden = NO;
    _ivShape_6.hidden = NO;
    _ivShape_7.hidden = NO;
    _ivShape_8.hidden = NO;
    _ivShape_9.hidden = NO;
    _ivShape_10.hidden = NO;
    _ivShape_11.hidden = NO;
    _ivShape_12.hidden = NO;
    _ivShape_13.hidden = NO;
    _ivShape_14_1.hidden = NO;
    _ivShape_14_2.hidden = NO;
    _ivShape_15.hidden = NO;
    _ivShape_16.hidden = NO;
    _ivShape_17.hidden = NO;
    
    
    CABasicAnimation *shapeAnimation_1 = [CABasicAnimation animationWithKeyPath:PositionAnimationKeyPath];
    shapeAnimation_1.autoreverses = YES;
    shapeAnimation_1.fromValue = [NSValue valueWithCGPoint:_ivShape_1.layer.position];
    shapeAnimation_1.toValue = [NSValue valueWithCGPoint:CGPointMake(_ivShape_1.layer.position.x + 30, _ivShape_1.layer.position.y + 30)];
    shapeAnimation_1.repeatCount = HUGE_VALF;
    shapeAnimation_1.duration = ShapeAnimationDuration;
    [_ivShape_1.layer addAnimation:shapeAnimation_1 forKey:ShapeAnimationKey];
    
    CABasicAnimation *shapeAnimation_5 = [CABasicAnimation animationWithKeyPath:RotationAnimationKeyPath];
    shapeAnimation_5.fromValue = @(0);
    shapeAnimation_5.toValue = @(360);
    shapeAnimation_5.repeatCount = HUGE_VALF;
    shapeAnimation_5.duration = ShapeAnimationDuration * 50;
    [_ivShape_5.layer addAnimation:shapeAnimation_5 forKey:ShapeAnimationKey];
    
    CABasicAnimation *shapeAnimation_7 = [CABasicAnimation animationWithKeyPath:OpacityAnimationKeyPath];
    shapeAnimation_7.autoreverses = YES;
    shapeAnimation_7.fromValue = @(1);
    shapeAnimation_7.toValue = @(CircleOpacityAnimationToValue);
    shapeAnimation_7.repeatCount = HUGE_VALF;
    shapeAnimation_7.duration = ShapeAnimationDuration;
    [_ivShape_7.layer addAnimation:shapeAnimation_7 forKey:ShapeAnimationKey];
    
    CABasicAnimation *shapeAnimation_10 = [CABasicAnimation animationWithKeyPath:PositionAnimationKeyPath];
    shapeAnimation_10.autoreverses = YES;
    shapeAnimation_10.fromValue = [NSValue valueWithCGPoint:_ivShape_10.layer.position];
    shapeAnimation_10.toValue = [NSValue valueWithCGPoint:CGPointMake(_ivShape_10.layer.position.x - 30, _ivShape_10.layer.position.y + 20)];
    shapeAnimation_10.repeatCount = HUGE_VALF;
    shapeAnimation_10.duration = ShapeAnimationDuration;
    [_ivShape_10.layer addAnimation:shapeAnimation_10 forKey:ShapeAnimationKey];

    CABasicAnimation *shapeAnimation_11 = [CABasicAnimation animationWithKeyPath:TranslationXAnimationKeyPath];
    shapeAnimation_11.autoreverses = YES;
    shapeAnimation_11.fromValue = @(0);
    shapeAnimation_11.toValue = @(-55);
    shapeAnimation_11.repeatCount = HUGE_VALF;
    shapeAnimation_11.duration = ShapeAnimationDuration;
    shapeAnimation_11.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [_ivShape_11.layer addAnimation:shapeAnimation_11 forKey:ShapeAnimationKey];
    
    CABasicAnimation *shapeAnimation_12 = [CABasicAnimation animationWithKeyPath:PositionAnimationKeyPath];
    shapeAnimation_12.autoreverses = YES;
    shapeAnimation_12.fromValue = [NSValue valueWithCGPoint:_ivShape_12.layer.position];
    shapeAnimation_12.toValue = [NSValue valueWithCGPoint:CGPointMake(_ivShape_12.layer.position.x - 30, _ivShape_12.layer.position.y - 25)];
    shapeAnimation_12.repeatCount = HUGE_VALF;
    shapeAnimation_12.duration = ShapeAnimationDuration * 3;
    [_ivShape_12.layer addAnimation:shapeAnimation_12 forKey:ShapeAnimationKey];
        CABasicAnimation *shapeAnimation_13 = [CABasicAnimation animationWithKeyPath:ScaleAnimationKeyPath];
    shapeAnimation_13.autoreverses = YES;
    shapeAnimation_13.fromValue = @(ShapeScaleToValue);
    shapeAnimation_13.toValue = @(1);
    shapeAnimation_13.repeatCount = HUGE_VALF;
    shapeAnimation_13.duration = ShapeAnimationDuration * 2;
    [_ivShape_13.layer addAnimation:shapeAnimation_13 forKey:ShapeAnimationKey];
    
    CABasicAnimation *shapeAnimation_15 = [CABasicAnimation animationWithKeyPath:ScaleAnimationKeyPath];
    shapeAnimation_15.fromValue = @(1);
    shapeAnimation_15.toValue = @(ShapeScaleToValue);
    shapeAnimation_15.autoreverses = YES;
    shapeAnimation_15.repeatCount = HUGE_VALF;
    shapeAnimation_15.duration = ShapeAnimationDuration;
    [_ivShape_15.layer addAnimation:shapeAnimation_15 forKey:ShapeAnimationKey];
    
    CABasicAnimation *shapeAnimation_16 = [CABasicAnimation animationWithKeyPath:RotationAnimationKeyPath];
    shapeAnimation_16.fromValue = @(360);
    shapeAnimation_16.toValue = @(0);
    shapeAnimation_16.repeatCount = HUGE_VALF;
    shapeAnimation_16.duration = ShapeAnimationDuration * 50;
    [_ivShape_16.layer addAnimation:shapeAnimation_16 forKey:ShapeAnimationKey];
    
    
    _ivShape_17.layer.anchorPoint = CGPointMake(0.0, 0.0);
    CAKeyframeAnimation *shapeAnimation_17 = [CAKeyframeAnimation animationWithKeyPath:PositionAnimationKeyPath];
    shapeAnimation_17.duration = ShapeAnimationDuration * 30;
    shapeAnimation_17.repeatCount = HUGE_VALF;
    CGPoint origin = _btnStart.center;
    CGFloat radius = SCREEN_WIDTH * 0.5 * 0.5;
    
    CGMutablePathRef ovalfromarc = CGPathCreateMutable();
    CGAffineTransform t2 = CGAffineTransformConcat(
                                                   CGAffineTransformConcat(
                                                                           CGAffineTransformMakeTranslation(-origin.x, -origin.y),
                                                                           CGAffineTransformMakeScale(1, 1)),
                                                   CGAffineTransformMakeTranslation(origin.x, origin.y));
    CGPathAddArc(ovalfromarc, &t2, origin.x, origin.y, radius, 0, M_PI * 2, YES);
    shapeAnimation_17.path = ovalfromarc;
    CGPathRelease(ovalfromarc);

    [_ivShape_17.layer addAnimation:shapeAnimation_17 forKey:ShapeAnimationKey];
    
    
}


- (void)removeSpecialEffects
{
    for (UIImageView *ivCircle in arrIvCircle) {
        [ivCircle.layer removeAllAnimations];
        ivCircle.hidden = NO;
    }
    
    [_ivShape_1.layer removeAllAnimations];
    [_ivShape_2.layer removeAllAnimations];
    [_ivShape_3.layer removeAllAnimations];
    [_ivShape_4.layer removeAllAnimations];
    [_ivShape_5.layer removeAllAnimations];
    [_ivShape_6.layer removeAllAnimations];
    [_ivShape_7.layer removeAllAnimations];
    [_ivShape_8.layer removeAllAnimations];
    [_ivShape_9.layer removeAllAnimations];
    [_ivShape_10.layer removeAllAnimations];
    [_ivShape_11.layer removeAllAnimations];
    [_ivShape_12.layer removeAllAnimations];
    [_ivShape_13.layer removeAllAnimations];
    [_ivShape_14_1.layer removeAllAnimations];
    [_ivShape_14_2.layer removeAllAnimations];
    [_ivShape_15.layer removeAllAnimations];
    [_ivShape_16.layer removeAllAnimations];
    [_ivShape_17.layer removeAllAnimations];
    
    _ivShape_1.hidden = YES;
    _ivShape_2.hidden = YES;
    _ivShape_3.hidden = YES;
    _ivShape_4.hidden = YES;
    _ivShape_5.hidden = YES;
    _ivShape_6.hidden = YES;
    _ivShape_7.hidden = YES;
    _ivShape_8.hidden = YES;
    _ivShape_9.hidden = YES;
    _ivShape_10.hidden = YES;
    _ivShape_11.hidden = YES;
    _ivShape_12.hidden = YES;
    _ivShape_13.hidden = YES;
    _ivShape_14_1.hidden = YES;
    _ivShape_14_2.hidden = YES;
    _ivShape_15.hidden = YES;
    _ivShape_16.hidden = YES;
    _ivShape_17.hidden = YES;
    
}



#pragma mark - Notification
- (void)takeResignActive
{
    [self removeSpecialEffects];
}


- (void)takeBecomeActive
{
    [self addSpecialEffects];
}




@end
