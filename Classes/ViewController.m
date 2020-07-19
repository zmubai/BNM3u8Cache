//
//  ViewController.m
//  m3u8DownloadSimpleDemo
//
//  Created by Bennie on 2019/4/4.
//  Copyright © 2019年 Bennie. All rights reserved.
//

#import "ViewController.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import "BNM3u8Cache.h"

@interface ViewController ()
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPlayerItem *playerItem;
@property (strong, nonatomic) AVPlayerLayer *playerLayer;
@property (strong, nonatomic) UIView *playerView;
@property (strong, nonatomic) AVPlayerViewController *playerVC;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIScrollView *progressView;
@property (strong, nonatomic) NSArray *urlArr;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configM3u8];
    [self configUI];
}

- (void)configUI{
    UIButton *clearBtn = [self btnWithTitle:@"清除文件" sel:@selector(clearRootPath)];
    UIButton *startBtn = [self btnWithTitle:@"开始" sel:@selector(start)];
    UIButton *cannelBtn = [self btnWithTitle:@"取消" sel:@selector(cannel)];

    UIButton *suspendBtn = [self btnWithTitle:@"暂停" sel:@selector(suspend)];
    UIButton *resumeBtn = [self btnWithTitle:@"恢复" sel:@selector(resume)];
    CGFloat edge = 30;
    CGFloat gap = 15;
    CGFloat width  = 90;
    CGFloat height = 30;
    clearBtn.frame = CGRectMake(edge, edge * 2, width, height);
    startBtn.frame = CGRectMake(edge + 1 * (width + gap), edge * 2, width, height);
    cannelBtn.frame = CGRectMake(edge + 2 * (width + gap), edge * 2, width, height);
    suspendBtn.frame = CGRectMake(edge + 0 * (width + gap), edge * 2 + 1 *(height + gap), width, height);
    resumeBtn.frame = CGRectMake(edge + 1 * (width + gap), edge * 2 + 1 *(height + gap), width, height);
    
    self.progressView = [[UIScrollView alloc]initWithFrame:CGRectMake(edge, resumeBtn.frame.origin.y + resumeBtn.frame.size.height + gap, self.view.bounds.size.width - 2 * edge, height)];
    self.progressView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:self.progressView];
    
    CGFloat y = self.progressView.frame.origin.y + self.progressView.frame.size.height + gap;
    self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(edge, y, self.view.bounds.size.width - 2 * edge, self.view.bounds.size.height - y)];
    [self.view addSubview:self.scrollView];
}

- (void)resetProgressView {
    CGRect frame = self.progressView.frame;
    [self.progressView removeFromSuperview];
    self.progressView = [[UIScrollView alloc]initWithFrame:frame];
    self.progressView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:self.progressView];
}

- (UIButton *)btnWithTitle:(NSString *)title sel:(SEL)sel{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setTitle:title forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:15];
    [btn setTitleColor:UIColor.blackColor forState:(UIControlStateNormal)];
    [btn addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
    btn.backgroundColor = UIColor.grayColor;
    [self.view addSubview:btn];
    return btn;
}

- (void)configM3u8 {
    NSString *rootPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES) objectAtIndex:0] stringByAppendingPathComponent:@"m3u8files"];
    BNM3U8ManagerConfig *config = BNM3U8ManagerConfig.new;
    /*媒体下载并发数控制*/
    config.videoMaxConcurrenceCount = 5;
    config.downloadDstRootPath = rootPath;
    //    config.netOption = BNM3U8DownloadSupportNetOptionWifi;
    [[BNM3U8Manager shareInstance] fillConfig:config];
    
    BNHttpLocalServer.shareInstance.documentRoot = rootPath;
    NSLog(@"rootPath:%@",rootPath);
    BNHttpLocalServer.shareInstance.port = 8080;
    
    /*
     一些免费的m3u8链接【格式可能不兼容，需要分析处理】
     https://bitmovin.com/mpeg-dash-hls-examples-sample-streams/
     */
    //    self.urlArr = @[@"https://bitmovin-a.akamaihd.net/content/playhouse-vr/m3u8s/105560_video_360_1000000.m3u8",
    //                    @"https://bitmovin-a.akamaihd.net/content/playhouse-vr/m3u8s/105560_video_540_1500000.m3u8",
    //                    @"https://bitmovin-a.akamaihd.net/content/playhouse-vr/m3u8s/105560_video_720_3000000.m3u8",
    //                    @"https://bitmovin-a.akamaihd.net/content/playhouse-vr/m3u8s/105560_video_1080_5000000.m3u8"
    //    ].mutableCopy;
    self.urlArr = @[@"https://bitmovin-a.akamaihd.net/content/playhouse-vr/m3u8s/105560_video_360_1000000.m3u8",
                    @"https://bitmovin-a.akamaihd.net/content/playhouse-vr/m3u8s/105560_video_540_1500000.m3u8"
    ].mutableCopy;
}

- (void)start
{
    for (UIView *v  in self.scrollView.subviews) {
        if (v.tag == 555) {
            [v removeFromSuperview];
        }
    }
    
    [self resetProgressView];
    
    CGFloat edge = 15;
    CGFloat widht = self.view.frame.size.width - 2 * edge;
    CGFloat gap = 15;
    self.scrollView.contentSize = CGSizeMake(widht, (widht * 9.0 / 16.0  + gap) * self.urlArr.count);
    CGFloat width = 75.0f;
    self.progressView.contentSize = CGSizeMake(width * self.urlArr.count, 0);
    
    for (NSInteger i = 0; i < self.urlArr.count ; i ++) {
        NSString *url = self.urlArr[i];
        __block  UILabel *label = [UILabel new];
        label.frame = CGRectMake(width * i, 0, width, self.progressView.frame.size.height);
        label.font = [UIFont systemFontOfSize:15];
        [label setTextAlignment:(NSTextAlignmentCenter)];
        [self.progressView addSubview:label];
        BNM3U8DownloadConfig *dlConfig = BNM3U8DownloadConfig.new;
        dlConfig.url = url;
        /*单个媒体下载的文件并发数控制*/
        dlConfig.maxConcurrenceCount = 5;
        dlConfig.localhost = @"http://127.0.0.1:8080/";
        [BNM3U8Manager.shareInstance downloadVideoWithConfig:dlConfig progressBlock:^(CGFloat progress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                label.text = [NSString stringWithFormat:@"%.00f%%",progress * 100];
            });
        }resultBlock:^(NSError * _Nullable error, NSString * _Nullable localPlayUrl) {
            if(localPlayUrl)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [BNHttpLocalServer.shareInstance tryStart];
                    [self playWithUrlString:localPlayUrl idx:i];
                });
            } else {
                NSLog(@"%@",error);
            }
        }];
    }
}

- (void)cannel
{
    [BNM3U8Manager.shareInstance cancelAll];
}

- (void)clearRootPath
{
    NSString *rootPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES) objectAtIndex:0] stringByAppendingPathComponent:@"m3u8files"];
    [BNFileManager.shareInstance removeFileWithPath:rootPath];
}

- (void)suspend{
    [BNM3U8Manager.shareInstance suspend];
}

- (void)resume{
    [BNM3U8Manager.shareInstance resume];
}

- (void)playWithUrlString:(NSString *)urlStr idx:(NSInteger)idx
{
    self.playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:urlStr]];
    self.player = [[AVPlayer alloc] initWithPlayerItem:self.playerItem];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    CGFloat width = self.scrollView.frame.size.width;
    CGFloat gap = 15;
    self.playerLayer.frame = CGRectMake(0, 0, width, width * 9.0 / 16.0);
    self.playerView = [[UIView alloc] initWithFrame:CGRectMake(0, idx * (gap + CGRectGetHeight(self.playerLayer.frame)) , CGRectGetWidth(self.playerLayer.frame), CGRectGetHeight(self.playerLayer.frame))];
    self.playerView.tag = 555;
    self.playerView.backgroundColor = [UIColor blackColor];
    [self.playerView.layer addSublayer:self.playerLayer];
    [self.scrollView addSubview:self.playerView];
    [self.player play];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

