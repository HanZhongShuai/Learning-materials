//
//  RCPlayerView.m
//  InstagramPlayer
//
//  Created by RC on 17/1/23.
//  Copyright © 2017年 RC. All rights reserved.
//

#import "RCPlayerView.h"

@interface RCPlayerView ()

/**控件原始Farme*/
@property (nonatomic,assign) CGRect customFarme;

@property (nonatomic, strong) UIProgressView *cacheProgressView;
@property (nonatomic, strong) UIImageView *iconView;

@property (nonatomic, strong) AVPlayer * player;
/**playerLayer*/
@property (nonatomic,strong) AVPlayerLayer           *playerLayer;
@property (nonatomic, strong) AVPlayerItem * currentItem;
@property (nonatomic, strong) RCResourceLoader * resourceLoader;

@property (nonatomic, strong) id timeObserve;

@end

@implementation RCPlayerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _customFarme = frame;
        _repeatPlay = YES;
    }
    return self;
}

- (void)setUrl:(NSURL *)url
{
    _url = url;
    [self reloadCurrentItem];
}

- (void)setRepeatPlay:(BOOL)repeatPlay
{
    _repeatPlay = repeatPlay;
}

#pragma mark - Property Set
- (void)setProgress:(CGFloat)progress {
    _progress = progress;
}

- (void)setState:(RCPlayerState)state {
    _state = state;
    if (state == RCPlayerStateBuffering || state == RCPlayerStatePaused) {
        self.iconView.hidden = NO;
    }
    else {
        self.iconView.hidden = YES;
    }
}

- (void)setCacheProgress:(CGFloat)cacheProgress {
    _cacheProgress = cacheProgress;
    if (self.cacheProgressView) {
        self.cacheProgressView.progress = cacheProgress;
    }
    NSLog(@"共缓冲%.2f",cacheProgress);
}

- (void)setDuration:(CGFloat)duration {
    if (duration != _duration && !isnan(duration)) {
        [self willChangeValueForKey:@"duration"];
        NSLog(@"duration %f",duration);
        _duration = duration;
        [self didChangeValueForKey:@"duration"];
    }
}

#pragma mark - 初始化plyer

- (void)reloadCurrentItem {
    
    [self stop];
    
    //Item
    if ([self.url.absoluteString hasPrefix:@"http"]) {
        //有缓存播放缓存文件
        NSString * cacheFilePath = [RCFileHandle cacheFileExistsWithURL:self.url];
        if (cacheFilePath) {
            NSURL * url = [NSURL fileURLWithPath:cacheFilePath];
            self.currentItem = [AVPlayerItem playerItemWithURL:url];
            self.cacheProgress = 1.0;
            NSLog(@"有缓存，播放缓存文件");
        }else {
            //没有缓存播放网络文件
            self.resourceLoader = [[RCResourceLoader alloc]init];
            self.resourceLoader.delegate = self;
            
            AVURLAsset * asset = [AVURLAsset URLAssetWithURL:[self.url customSchemeURL] options:nil];
            [asset.resourceLoader setDelegate:self.resourceLoader queue:dispatch_get_main_queue()];
            self.currentItem = [AVPlayerItem playerItemWithAsset:asset];
            NSLog(@"无缓存，播放网络文件");
        }
    }
    else if (self.url == nil || [self.url.absoluteString isEqualToString:@""])
    {
        return;
    }
    else {
        self.currentItem = [AVPlayerItem playerItemWithURL:self.url];
        self.cacheProgress = 1.0;
        NSLog(@"播放本地文件");
    }
    //Player
    self.player = [AVPlayer playerWithPlayerItem:self.currentItem];
    //Observer
    [self addObserver];
    
    //State
    self.state = RCPlayerStateWaiting;
    
    //添加AVPlayerLayer
    if (_playerLayer) {
        [_playerLayer setPlayer:_player];
    }
    else {
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
        _playerLayer.frame = CGRectMake(0, 0, _customFarme.size.width, _customFarme.size.height);
        [self.layer addSublayer:_playerLayer];
    }
    //设置静音
    _player.volume = 0;
    _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    
    if (self.cacheProgressView == nil) {
        self.cacheProgressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
        [self.cacheProgressView setFrame:CGRectMake(0, self.frame.size.height - 2, self.frame.size.width, 2)];
        [self.cacheProgressView setProgressTintColor:colorWithHexString(@"#EB9938")];
        [self.cacheProgressView setTrackTintColor:[UIColor clearColor]];
        [self addSubview:self.cacheProgressView];
        self.cacheProgressView.progress = _cacheProgress;
    }
    [self bringSubviewToFront:self.cacheProgressView];
    
    if (self.iconView == nil) {
        CGFloat widith = self.frame.size.width/12.0;
        self.iconView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width - (widith/2.0*3.0), widith/2.0, widith, widith)];
        self.iconView.image = [UIImage imageNamed:@"ins_icon_views"];
        [self addSubview:self.iconView];
    }
    [self bringSubviewToFront:self.iconView];
}

- (void)play {
    if (self.state == RCPlayerStatePaused || self.state == RCPlayerStateWaiting) {
        [self.player play];
    }
}

- (void)pause {
    if (self.state == RCPlayerStatePlaying) {
        [self.player pause];
    }
}

#pragma mark - 重新开始播放
- (void)resetPlay
{
    [_player seekToTime:CMTimeMake(0, 1)];
    [self play];
}

- (void)stop {
    if (self.state == RCPlayerStateStopped) {
        return;
    }
    [self.player pause];
    [self.resourceLoader stopLoading];
    [self removeObserver];
    self.resourceLoader = nil;
    self.currentItem = nil;
    self.player = nil;
    self.progress = 0.0;
    self.duration = 0.0;
    self.cacheProgress = 0.0;
    self.state = RCPlayerStateStopped;
}

- (void)seekToTime:(CGFloat)seconds {
    if (self.state == RCPlayerStatePlaying || self.state == RCPlayerStatePaused) {
        [self.player pause];
        self.resourceLoader.seekRequired = YES;
        [self.player seekToTime:CMTimeMakeWithSeconds(seconds, NSEC_PER_SEC) completionHandler:^(BOOL finished) {
            NSLog(@"seekComplete!!");
            [self.player play];
        }];;
    }
}

#pragma mark - KVO
- (void)addObserver {
    AVPlayerItem * mediaItem = self.currentItem;
    //播放完成
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished) name:AVPlayerItemDidPlayToEndTimeNotification object:mediaItem];
    //播放进度
    __weak typeof(self) weakSelf = self;
    self.timeObserve = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        CGFloat current = CMTimeGetSeconds(time);
        CGFloat total = CMTimeGetSeconds(mediaItem.duration);
        weakSelf.duration = total;
        weakSelf.progress = current / total;
    }];
    [self.player addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionNew context:nil];
    [mediaItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    [mediaItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)removeObserver {
    AVPlayerItem * mediaItem = self.currentItem;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (self.timeObserve) {
        [self.player removeTimeObserver:self.timeObserve];
        self.timeObserve = nil;
    }
    [mediaItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [mediaItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    [self.player removeObserver:self forKeyPath:@"rate"];
    [self.player replaceCurrentItemWithPlayerItem:nil];
}

/**
 *  通过KVO监控播放器状态
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
//    AVPlayerItem * mediaItem = object;
    if ([keyPath isEqualToString:@"rate"]) {
        if (self.player.rate == 0.0) {
            self.state = RCPlayerStatePaused;
        }else if (self.player.rate > 0.0){
            self.state = RCPlayerStatePlaying;
        }
    }
    if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
        if (self.currentItem.playbackBufferEmpty) {
            self.state = RCPlayerStateBuffering;
            NSLog(@"playbackBufferEmpty");
        }
    }
    if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
        if (self.currentItem.playbackLikelyToKeepUp) {
            if (self.player.rate == 0.0) {
                self.state = RCPlayerStatePaused;
            }else if (self.player.rate > 0.0){
                self.state = RCPlayerStatePlaying;
            }
            [self play];
            NSLog(@"playbackLikelyToKeepUp");
        }
    }
}

- (void)playbackFinished {
    NSLog(@"播放完成");
    if (_repeatPlay == NO)
    {
        [self pause];
    }
    else
    {
        [self resetPlay];
    }
}

- (void)applicationEnterBackground:(UIApplication *)application
{
    [self pause];
}

- (void)applicationEnterForeground:(UIApplication *)application
{
    [self play];
}

#pragma mark - RCLoaderDelegate
- (void)loader:(RCResourceLoader *)loader cacheProgress:(CGFloat)progress {
    self.cacheProgress = progress;
}

- (void)loader:(RCResourceLoader *)loader finishLoadingWithCacheFinished:(BOOL)cacheFinished
{
    if (cacheFinished) {
        if (self.cacheProgress < 1) {
            [self reloadCurrentItem];
        }
    }
}

- (void)loader:(RCResourceLoader *)loader failLoadingWithError:(NSError *)error
{
    if (self.state == RCPlayerStateError) {
        return;
    }
    self.state = RCPlayerStateError;
    [self reloadCurrentItem];
}

#pragma mark - CacheFile
- (BOOL)currentItemCacheState {
    if ([self.url.absoluteString hasPrefix:@"http"]) {
        if (self.resourceLoader) {
            return self.resourceLoader.cacheFinished;
        }
        return YES;
    }
    return NO;
}

- (NSString *)currentItemCacheFilePath {
    if (![self currentItemCacheState]) {
        return nil;
    }
    return [NSString stringWithFormat:@"%@/%@", [NSString cacheFolderPath], [NSString fileNameWithURL:self.url]];;
}

#pragma mark - dealloc
- (void)dealloc
{
    [self stop];
}

+ (BOOL)clearCache {
    [RCFileHandle clearCache];
    return YES;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
