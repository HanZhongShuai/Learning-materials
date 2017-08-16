//
//  RCPlayerView.h
//  InstagramPlayer
//
//  Created by RC on 17/1/23.
//  Copyright © 2017年 RC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCResourceLoader.h"

typedef NS_ENUM(NSInteger, RCPlayerState) {
    RCPlayerStateWaiting,
    RCPlayerStatePlaying,
    RCPlayerStatePaused,
    RCPlayerStateStopped,
    RCPlayerStateBuffering,
    RCPlayerStateError
};


@interface RCPlayerView : UIView<RCLoaderDelegate>

@property (nonatomic, assign) RCPlayerState state;
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, assign) CGFloat duration;
@property (nonatomic, assign) CGFloat cacheProgress;

/**视频url*/
@property (nonatomic,strong) NSURL *url;
/**重复播放，默认No*/
@property (nonatomic,assign) BOOL repeatPlay;


/**
 *  播放
 */
- (void)play;

/**
 *  暂停
 */
- (void)pause;

/**
 *  停止
 */
- (void)stop;

/**
 *  跳到某个时间进度
 */
- (void)seekToTime:(CGFloat)seconds;

/**
 *  当前缓存情况 YES：已缓存  NO：未缓存（seek过的都不会缓存）
 */
- (BOOL)currentItemCacheState;

/**
 *  当前缓存文件完整路径
 */
- (NSString *)currentItemCacheFilePath;

/**
 *  清除缓存
 */
+ (BOOL)clearCache;

@end
