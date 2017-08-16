//
//  RCRequestTask.h
//  InstagramPlayer
//
//  Created by RC on 17/1/23.
//  Copyright © 2017年 RC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCFileHandle.h"

#define RequestTimeout 10.0

@class RCRequestTask;
@protocol RCRequestTaskDelegate <NSObject>

@required
- (void)requestTaskDidUpdateCache; //更新缓冲进度代理方法

@optional
- (void)requestTaskDidReceiveResponse;
- (void)requestTaskDidFinishLoadingWithCache:(BOOL)cache;
- (void)requestTaskDidFailWithError:(NSError *)error;

@end

@interface RCRequestTask : NSObject

@property (nonatomic, weak) id<RCRequestTaskDelegate> delegate;
@property (nonatomic, strong) NSURL * requestURL; //请求网址
@property (nonatomic, assign) NSUInteger requestOffset; //请求起始位置
@property (nonatomic, assign) NSUInteger fileLength; //文件长度
@property (nonatomic, assign) NSUInteger cacheLength; //缓冲长度
@property (nonatomic, assign) BOOL cache; //是否缓存文件
@property (nonatomic, assign) BOOL cancel; //是否取消请求

/**
 *  开始请求
 */
- (void)start;

@end
