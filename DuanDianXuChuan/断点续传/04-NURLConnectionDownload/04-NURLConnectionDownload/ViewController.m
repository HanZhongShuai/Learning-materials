//
//  ViewController.m
//  04-NURLConnectionDownload
//
//  Created by 夏婷 on 16/2/25.
//  Copyright © 2016年 夏婷. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<NSURLConnectionDataDelegate>

@property (weak, nonatomic) IBOutlet UIButton *downloadBtn;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (nonatomic, strong) NSURLConnection *connection;//作为成员变量，避免提前释放
@property (nonatomic, strong) NSFileHandle *filehandle;//文件句柄 可以操作本地文件的数据 （读写操作）
@property (nonatomic, assign) NSInteger totalLength;


@end

@implementation ViewController
-(NSString *)filePtah
{
    
    NSLog(@"%@",NSHomeDirectory());
    NSString * filePath = [NSString stringWithFormat:@"%@/Documents/QQQQ.dmg",NSHomeDirectory()];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:filePath] == NO) {
        //文件不存在要创建一个空的文件
        [fm createFileAtPath:filePath contents:nil attributes:nil];
    }
    return filePath;
}
-(NSFileHandle *)filehandle
{
    if (!_filehandle) {
        
        _filehandle = [NSFileHandle fileHandleForUpdatingAtPath:[self filePtah]];
        //绑定句柄的文件路径
        
        //从文件末端开始更新
        [_filehandle seekToEndOfFile];
    }
    return _filehandle;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.totalLength = [[NSUserDefaults standardUserDefaults] integerForKey:@"totalLength"];
    //修正下载的进度
    if(self.totalLength != 0)//第一次总长度为0  出现 0/0
    {
        self.progressView.progress = [self tempLenth] * 1.0 /self.totalLength;
    }
    
}
//下载
- (IBAction)download:(id)sender {
    NSString *url = @"http://dldir1.qq.com/qqfile/QQforMac/QQ_V4.0.2.dmg";
    //创建请求对象
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    NSString *length = [NSString stringWithFormat:@"bytes=%ld-",[self tempLenth]];
    //设置下载的起始位置
    [request setValue:length forHTTPHeaderField:@"RANGE"];
    
    self.connection = nil;
    //创建并启动下载
    self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
    self.downloadBtn.enabled = NO;
    
}

-(NSInteger)tempLenth//返回已下载的长度
{
    //通过文件manager  获取某个文件的详细信息
   NSDictionary *filedic = [[NSFileManager defaultManager] fileAttributesAtPath:[self filePtah] traverseLink:YES];
    NSInteger length = [filedic[NSFileSize] integerValue];
    return length;
}

//暂停
- (IBAction)pause:(id)sender {
    
    // 暂定下载任务
    [self.connection cancel];
    //暂停以后 应该能够重新开始下载
    self.downloadBtn.enabled = YES;
    
}
//接收到服务器端的响应时调用这个方法
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    //强转为针对Http请求的响应类型
    NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
    //取出将要下载文件的长度
    NSInteger lenth = [[res.allHeaderFields objectForKey:@"Content-Length"] integerValue];//文件的总长度 - 已经下载的长度
    
    //可以计算出文件的总长度 = 本地已经下载的长度 + 将要下载的长度
    self.totalLength = [self tempLenth] + lenth;
    
    
    [[NSUserDefaults standardUserDefaults] setInteger:self.totalLength forKey:@"totalLength"];
    //同步数据  保证数据真正被写入本地
    [[NSUserDefaults standardUserDefaults] synchronize];
}


//接收到服务器端的数据
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    //通过文件句柄将新下载的数据写到本地
    [self.filehandle  writeData:data];
    // 写入对应的路径
    //更新了已经下载的数据 应该更新进度  进度 = 已下载的数据长度 ÷ 总长度
    self.progressView.progress = [self tempLenth] * 1.0/self.totalLength;
}

//下载结束时调用的方法
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"下载结束");
    self.downloadBtn.enabled = YES;
    
}
//下载失败
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"下载失败");
    self.downloadBtn.enabled = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
