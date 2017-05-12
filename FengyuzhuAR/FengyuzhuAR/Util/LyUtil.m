//
//  LyUtil.m
//  LyVuforia
//
//  Created by wJunes on 2017/3/21.
//  Copyright © 2017年 wJunes. All rights reserved.
//

#import "LyUtil.h"

@implementation LyUtil


static NSString *bundlePath = nil;



+ (UIImage *)imageNamed:(NSString *)name
{
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:[LyUtil imagePathWithName:name]];
    
    return image;
}


+ (NSString *)imagePathWithName:(NSString *)name
{
    if (nil == bundlePath)
    {
        bundlePath = [[NSBundle mainBundle] pathForResource:@"Resources" ofType:@"bundle"];
    }
    
    return [bundlePath stringByAppendingFormat:@"/images/%@", name];
}


+ (NSString *)filePathWithName:(NSString *)name
{
    if (nil == bundlePath)
    {
        bundlePath = [[NSBundle mainBundle] pathForResource:@"Resources" ofType:@"bundle"];
    }
    
    
    return [bundlePath stringByAppendingFormat:@"/files/%@", name];
}


@end
