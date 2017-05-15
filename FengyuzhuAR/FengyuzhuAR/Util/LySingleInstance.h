//
//  LySingleInstance.h
//  LySingleViewApp
//
//  Created by utgame_mini2 on 16/1/18.
//  Copyright © 2016年 Ly_test. All rights reserved.
//  用于单例模式
//

#ifndef LySingleInstance_h
#define LySingleInstance_h


#pragma mark 接口.h中的定义
//由于宏定义里有需要替换的内容所以定义一个变量className
//##用于分割、连接字符
#define     lySingle_interface      +(nonnull instancetype)sharedInstance;


#pragma mark 实现.m
//\在代码中用于连接宏定义,以实现多行定义
#define     lySingle_implementation(className)      \
static className *instance = nil;                   \
+ (nonnull instancetype)sharedInstance                      \
{                                                   \
    static dispatch_once_t onceToken;               \
    dispatch_once(&onceToken, ^{                    \
        instance = [[className alloc] init];        \
    });                                             \
                                                    \
    return instance;                                \
}                                                   \
+ (instancetype)allocWithZone:(struct _NSZone *)zone\
{                                                   \
    static dispatch_once_t onceToken;               \
    dispatch_once(&onceToken, ^{                    \
        instance=[super allocWithZone:zone];        \
    });                                             \
    return instance;                                \
}



#endif /* LySingleInstance_h */
