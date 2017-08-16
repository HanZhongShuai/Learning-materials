//
//  RCResourceLoader.h
//  InstagramPlayer
//
//  Created by RC on 17/1/23.
//  Copyright © 2017年 RC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "RCRequestTask.h"

#define MimeType @"video/mp4"

@class RCResourceLoader;
@protocol RCLoaderDelegate <NSObject>

@required
- (void)loader:(RCResourceLoader *)loader cacheProgress:(CGFloat)progress;

@optional
- (void)loader:(RCResourceLoader *)loader finishLoadingWithCacheFinished:(BOOL)cacheFinished;
- (void)loader:(RCResourceLoader *)loader failLoadingWithError:(NSError *)error;

@end

@interface RCResourceLoader : NSObject<AVAssetResourceLoaderDelegate,RCRequestTaskDelegate>

@property (nonatomic, weak) id<RCLoaderDelegate> delegate;
@property (atomic, assign) BOOL seekRequired; //Seek标识
@property (nonatomic, assign) BOOL cacheFinished;

- (void)stopLoading;

@end
