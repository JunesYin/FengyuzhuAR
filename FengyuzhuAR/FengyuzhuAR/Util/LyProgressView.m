//
//  LyProgressView.m
//  FengyuzhuAR
//
//  Created by wJunes on 2017/5/25.
//  Copyright © 2017年 Junes. All rights reserved.
//

#import "LyProgressView.h"

@interface LyProgressView ()
{
    UILabel *lbText;
}

@end


@implementation LyProgressView


- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor clearColor];
        self.layer.cornerRadius = 5;
        self.clipsToBounds = YES;
        
        lbText = [[UILabel alloc] initWithFrame:self.bounds];
        lbText.textColor = [UIColor whiteColor];
        lbText.backgroundColor = [UIColor clearColor];
        lbText.textAlignment = NSTextAlignmentCenter;
        lbText.font = [UIFont systemFontOfSize:14];
        [self addSubview:lbText];
    }
    
    return self;
}


- (void)setProgress:(float)progress
{
    _progress = progress;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setNeedsDisplay];
        [lbText setText:[[NSString alloc] initWithFormat:@"%.0f%%", progress * 100]];
//        [lbText setText:@"100%"];
        
        if (progress >= 0.999)
        {
            [self removeFromSuperview];
        }
    });
}


- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGFloat centerX = rect.size.width * 0.5;
    CGFloat centerY = rect.size.width * 0.5;
    
    [[UIColor whiteColor] set];
    
    switch (_mode) {
        case LyProgressViewMode_PieDiagram: {
            CGFloat radius = MIN(centerX, centerY) - LyProgressViewItemMargin;
            
            CGFloat w = radius * 2 + LyProgressViewItemMargin;
            CGFloat h = w;
            CGFloat x = (rect.size.width - w) * 0.5;
            CGFloat y = (rect.size.height - h) * 0.5;
            
            CGContextAddEllipseInRect(ctx, CGRectMake(x, y, w, h));
            CGContextFillPath(ctx);
            
            [LyProgressViewBackgroundColor set];
            CGContextMoveToPoint(ctx, centerX, centerY);
            CGContextAddLineToPoint(ctx, centerX, 0);
            CGFloat to = - M_PI * 0.5 + _progress * M_PI * 2 + 0.001;    // 初始值
            CGContextAddArc(ctx, centerX, centerY, radius, - M_PI * 0.5, to, 1);
            CGContextClosePath(ctx);
            
            CGContextFillPath(ctx);
            
            break;
        }
        default: {
            CGContextSetLineWidth(ctx, LyProgressViewLineWidth);
            CGContextSetLineCap(ctx, kCGLineCapRound);
            
            CGFloat radius = MIN(rect.size.width, rect.size.height) * 0.5 - LyProgressViewItemMargin;
            
            [[[UIColor alloc] initWithRed:1 green:1 blue:1 alpha:0.1] set];
            CGContextAddArc(ctx, centerX, centerY, radius, - M_PI * 0.5, - M_PI * 0.5 + M_PI * 2, 0);
            CGContextStrokePath(ctx);
            
            [[UIColor whiteColor] set];
            CGFloat to = - M_PI * 0.5 + _progress * M_PI * 2 + 0.05;    // 初始值
//            CGFloat to = _progress * M_PI * 2;  //初始值
            CGContextAddArc(ctx, centerX, centerY, radius, - M_PI * 0.5, to, 0);
//            CGContextAddArc(ctx, centerX, centerY, radius, 0, to, 0);
            CGContextStrokePath(ctx);
            break;
        }
    }
    
}

@end
