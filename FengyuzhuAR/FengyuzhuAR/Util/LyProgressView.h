//
//  LyProgressView.h
//  FengyuzhuAR
//
//  Created by wJunes on 2017/5/25.
//  Copyright © 2017年 Junes. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    LyProgressViewMode_LoopDiagram,  // 环形
    LyProgressViewMode_PieDiagram,   // 饼形
} LyProgressViewMode;



const CGFloat LyProgressViewItemMargin = 10;
const CGFloat LyProgressViewLineWidth = 3;

#define LyProgressViewBackgroundColor        [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7]

@interface LyProgressView : UIView

@property (assign, nonatomic) float progress;
@property (assign, nonatomic) LyProgressViewMode mode;

@end
