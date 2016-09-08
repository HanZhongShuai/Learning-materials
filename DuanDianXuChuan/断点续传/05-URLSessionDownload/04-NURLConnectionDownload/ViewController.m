//
//  ViewController.m
//  04-NURLConnectionDownload
//
//  Created by 夏婷 on 16/2/25.
//  Copyright © 2016年 夏婷. All rights reserved.
//

#import "ViewController.h"

extern void(^taskComplete)();//引入其他源文件中声明的全局变量


@interface ViewController ()<NSURLSessionDownloadDelegate>//session下载协议

@property (weak, nonatomic) IBOutlet UIButton *downloadBtn;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@property (nonatomic, strong) NSData * resumData;//保存取消正在执行的下载任务时的下载数据
//下载任务
@property (nonatomic, strong) NSURLSessionDownloadTask *task;
@property (nonatomic, strong) NSURLSession *session;

@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.resumData  = [[NSUserDefaults standardUserDefaults] objectForKey:@"data"];
    self.progressView.progress = [[NSUserDefaults standardUserDefaults] floatForKey:@"progress"];
}
//界面已经消失
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    //保存已经下载的数据
    [[NSUserDefaults standardUserDefaults] setObject:self.resumData forKey:@"data"];
    //保存进度
    [[NSUserDefaults standardUserDefaults] setFloat:self.progressView.progress forKey:@"progress"];
    //同步数据
    [[NSUserDefaults standardUserDefaults] synchronize];
}
//下载
- (IBAction)download:(id)sender {
    
    //创建一个后台模式配置
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"downloadTask"];
    //创建session
    _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[[NSOperationQueue alloc]init]];
    if (self.resumData) {
        //如果已经下载过数据,用已经下载的数据得到一个新的任务 继续下载
        self.task = [_session downloadTaskWithResumeData:self.resumData];
    }else
    {
        NSString * url = @"http://dldir1.qq.com/qqfile/QQforMac/QQ_V4.0.2.dmg";
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
       
        self.task = [_session downloadTaskWithRequest:request];
    }
    
    //启动下载任务
    [self.task resume];
}

//暂停
- (IBAction)pause:(id)sender {
    
    //取消正在进行的下载任务 resumeData 包含当前已下载的文件数据 和 完成断点续传所需要的所有内容
    __weak ViewController *weekSelf = self;
    [self.task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        //记录已下载的数据
        weekSelf.resumData = resumeData;
    }];
//    [_session invalidateAndCancel];
    
}
//服务器端向客户端传输一段数据调用一次（更新进度时可以用的函数）
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    //totalBytesExpectedToWrite 期望写入的总长度
    //totalBytesWritten 已经写入的长度
    //bytesWritten  本次要写入的长度
    //进度 = （totalBytesWritten + bytesWritten）/ totalBytesExpectedToWrite
    self.progressView.progress = (totalBytesWritten + bytesWritten) *  1.0/ totalBytesExpectedToWrite;
    //
    NSLog(@"更新进度");
}
//下载数据结束 调用这个方法  程序员根据需求是否要把数据保存到本地
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    //保存到沙盒路径下的Documents文件夹下
    NSString * path = [NSString stringWithFormat:@"%@/Documents/QQQQQ.dmg",NSHomeDirectory()];
    //文件本地URL
    NSURL *fileUrl = [NSURL fileURLWithPath:path];
    NSFileManager *fm = [NSFileManager defaultManager];
    //把文件从location 移动到沙盒中
    [fm moveItemAtURL:location toURL:fileUrl error:nil];
    NSLog(@"下载文件结束");
}
//任务结束
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    NSLog(@"任务结束");
}

// 任务在后台执行结束之后，程序被唤醒后调用的方法
-(void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    NSLog(@"唤醒后调用的协议方法");
    //调用一下 让其他的协议方法能够被执行
    taskComplete();
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
