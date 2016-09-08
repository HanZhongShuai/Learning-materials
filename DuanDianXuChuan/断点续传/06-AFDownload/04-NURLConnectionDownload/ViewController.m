//
//  ViewController.m
//  04-NURLConnectionDownload
//
//  Created by 夏婷 on 16/2/25.
//  Copyright © 2016年 夏婷. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"

extern void(^taskComplete)();//引入其他源文件中声明的全局变量


@interface ViewController ()<NSURLSessionDownloadDelegate>//session下载协议

@property (weak, nonatomic) IBOutlet UIButton *downloadBtn;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@property (nonatomic, strong) NSData * resumData;//保存取消正在执行的下载任务时的下载数据
//下载任务
@property (nonatomic, strong) NSURLSessionDownloadTask *task;
@property (nonatomic,strong) AFHTTPSessionManager *manager;



@end

@implementation ViewController

-(AFHTTPSessionManager *)manager
{
    if (!_manager) {
        _manager = [AFHTTPSessionManager manager];
        _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    return _manager;
}
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
    
    NSString *path = [NSString stringWithFormat:@"%@/Documents/QQQ.dmg",NSHomeDirectory()];
    NSURL *fileUrl = [NSURL fileURLWithPath:path];
    NSProgress *pro = nil;
    
    if (self.resumData) {
        //如果已经下载过数据,用已经下载的数据得到一个新的任务 继续下载
        self.task = [self.manager downloadTaskWithResumeData:self.resumData progress:&pro destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
            
            return fileUrl;
        } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
            
        }];
    }else
    {
        NSString * url = @"http://dldir1.qq.com/qqfile/QQforMac/QQ_V4.0.2.dmg";
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
       self.task =  [self.manager downloadTaskWithRequest:request progress:&pro destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
            
            return  fileUrl;//返回存储数据的路径
            
        } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
            
            
        }];
    }
    
    [pro addObserver:self forKeyPath:@"completedUnitCount" options:NSKeyValueObservingOptionNew context:nil];
    
    //启动下载任务
    [self.task resume];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    NSLog(@"刷新进度 %@",change);
    NSProgress *pro = object;
    self.progressView.progress = pro.completedUnitCount *1.0 /pro.totalUnitCount;
    
}
//暂停
- (IBAction)pause:(id)sender {
    
    //取消正在进行的下载任务 resumeData 包含当前已下载的文件数据 和 完成断点续传所需要的所有内容
    __weak ViewController *weekSelf = self;
    [self.task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        //记录已下载的数据
        weekSelf.resumData = resumeData;
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
