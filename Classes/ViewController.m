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
    self.title = @"m3u8Demo";
    NSString *rootPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES) objectAtIndex:0] stringByAppendingPathComponent:@"m3u8files"];
    BNM3U8ManagerConfig *config = BNM3U8ManagerConfig.new;
    /*媒体下载并发数控制*/
    config.videoMaxConcurrenceCount = 5;
    config.downloadDstRootPath = rootPath;
    //    config.netOption = BNM3U8DownloadSupportNetOptionWifi;
    [[BNM3U8Manager shareInstance] fillConfig:config];
    
    BNHttpLocalServer.shareInstance.documentRoot = rootPath;
    BNHttpLocalServer.shareInstance.port = 8080;
    
    self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 100, self.view.bounds.size.width, self.view.bounds.size.height - 100)];
    [self.view addSubview:self.scrollView];
    
    UIButton *suspendBt = [UIButton buttonWithType:UIButtonTypeSystem];
    suspendBt.frame = CGRectMake(15, 50, 60, 40);
    [suspendBt setTitle:@"cannel" forState:UIControlStateNormal];
    [suspendBt addTarget:self action:@selector(cannel) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:suspendBt];
    
    UIButton *resumeBt = [UIButton buttonWithType:UIButtonTypeSystem];
    resumeBt.frame = CGRectMake(80, 50, 60, 40);
    [resumeBt setTitle:@"start" forState:UIControlStateNormal];
    [resumeBt addTarget:self action:@selector(start) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:resumeBt];
    
    UIButton *clearBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    clearBtn.frame = CGRectMake(80 + 65, 50, 120, 40);
    [clearBtn setTitle:@"clearRootPath" forState:UIControlStateNormal];
    [clearBtn addTarget:self action:@selector(clearRootPath) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:clearBtn];
    
    UIButton *suspendBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    suspendBtn.frame = CGRectMake(80 + 65 + 100, 50, 120, 40);
    [suspendBtn setTitle:@"suspend" forState:UIControlStateNormal];
    [suspendBtn addTarget:self action:@selector(suspend) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:suspendBtn];
}
static int avCount = 0;
- (void)start
{
    avCount = 0;
    for (UIView *v  in self.scrollView.subviews) {
        if (v.tag == 555) {
            [v removeFromSuperview];
        }
    }
    /*
     一些免费的m3u8链接【格式可能不兼容，需要分析处理】
     https://bitmovin.com/mpeg-dash-hls-examples-sample-streams/
     */
    [self.progressView removeFromSuperview];
    self.progressView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 90, self.view.bounds.size.width, 40)];
    self.progressView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:self.progressView];
    self.urlArr = @[@"https://bitmovin-a.akamaihd.net/content/playhouse-vr/m3u8s/105560_video_360_1000000.m3u8",
                    @"https://bitmovin-a.akamaihd.net/content/playhouse-vr/m3u8s/105560_video_540_1500000.m3u8",
                    @"https://bitmovin-a.akamaihd.net/content/playhouse-vr/m3u8s/105560_video_720_3000000.m3u8",
                    @"https://bitmovin-a.akamaihd.net/content/playhouse-vr/m3u8s/105560_video_1080_5000000.m3u8"
    ].mutableCopy;
    //    self.urlArr = @[@"https://bitmovin-a.akamaihd.net/content/playhouse-vr/m3u8s/105560_video_360_1000000.m3u8"].mutableCopy;
    
    self.scrollView.contentSize = CGSizeMake(self.view. bounds.size.width, self.view.frame.size.width * 9.0 / 16.0 * self.urlArr.count);
    CGFloat width = 80.0f;
    self.progressView.contentSize = CGSizeMake(10 + width * self.urlArr.count, 0);
    
    for (NSInteger i = 0; i < self.urlArr.count ; i ++) {
        NSString *url = self.urlArr[i];
        __block  UILabel *label = [UILabel new];
        label.frame = CGRectMake(10 + width*i, 5, width, 40);
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
                    [self playWithUrlString:localPlayUrl];
                });
            }
        }];
    }
}

- (void)cannel
{
    //    for (NSInteger i = 0; i < self.urlArr.count ; i ++) {
    //        [BNM3U8Manager.shareInstance  cannel:self.urlArr[i]];
    //    }
    ///or  cancel all
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


- (void)playWithUrlString:(NSString *)urlStr
{
    self.playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:urlStr]];
    self.player = [[AVPlayer alloc] initWithPlayerItem:self.playerItem];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width * 9.0 / 16.0);
    self.playerView = [[UIView alloc] initWithFrame:CGRectMake(0, 20 + avCount * CGRectGetHeight(self.playerLayer.frame), CGRectGetWidth(self.playerLayer.frame), CGRectGetHeight(self.playerLayer.frame))];
    self.playerView.tag = 555;
    self.playerView.backgroundColor = [UIColor blackColor];
    [self.playerView.layer addSublayer:self.playerLayer];
    [self.scrollView addSubview:self.playerView];
    [self.player play];
    avCount ++;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

