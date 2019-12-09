
# M3U8DemoByOperation

使用operation的方式实现m3u8本地缓存和播放。可控制媒体并发数，单个媒体文件下载并发数；支持任务挂起恢复、支持任务取消。


#### 使用方式
```Objective-C
    // 1.全局配置BNM3U8Manager
    NSString *rootPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES) objectAtIndex:0] stringByAppendingPathComponent:@"m3u8files"];
    BNM3U8ManagerConfig *config = BNM3U8ManagerConfig.new;
    /*媒体下载并发数控制*/
    config.videoMaxConcurrenceCount = 5;
    config.downloadDstRootPath = rootPath;
    [[BNM3U8Manager shareInstance] fillConfig:config];

    // 2. 发起下载
    BNM3U8DownloadConfig *dlConfig = BNM3U8DownloadConfig.new;
    dlConfig.url = @"https://bitmovin-a.akamaihd.net/content/playhouse-vr/m3u8s/105560_video_360_1000000.m3u8";
    /*单个媒体ts文件并发数控制*/
    dlConfig.maxConcurrenceCount = 5;
    dlConfig.localhost = @"http://127.0.0.1:8080/";
    [BNM3U8Manager.shareInstance downloadVideoWithConfig:dlConfig progressBlock:^(CGFloat progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //显示下载进度
            label.text = [NSString stringWithFormat:@"%.00f%%",progress * 100];
        });
    }resultBlock:^(NSError * _Nullable error, NSString * _Nullable localPlayUrl) {
        if(localPlayUrl)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                // 3. 配置本地服务，开启并播放
                BNHttpLocalServer.shareInstance.documentRoot = rootPath;
                BNHttpLocalServer.shareInstance.port = 8080;
                [BNHttpLocalServer.shareInstance tryStart];
                [self playWithUrlString:localPlayUrl];
            });
        }
    }];

```

#### 关于并发数的设置
根据苹果官方文档关于电耗的说明，网络模块的长时间低效运行，会大大的增加动态成本，导致电耗变大。而合理的使用并发，把网络请求集中快速的处理，虽然会增大固定成本，但长期来说，动态成本会大大降低，减少了电耗。从这个角度来说不应该采用单并发下载，应该尽量的采取多并发。请考虑发热和效率，合理的设置并发数（建议>=2）。

#### 二级界面进度的无法回调
由于是使用单例来下载，回调block也是与一个下载任务绑定的。当界面退出了，如果没有保存当前这个回调函数，那么就再也获取不到回调。需要把任务全部取消，重新发起，这样就能重新赋值所有回调。因为是多个小文件的下载，重复文件不会重复下载，所以全部取消，重新发起，对流量的浪费使用并不会增大很多。

#### 索引文件解析失败
m3u8格式形式比较多，没有兼容到。只能慢慢兼容，更新，做到兼容大部分格式（主流/常用-》非主流/不常用）。


#### 更新list
1. 添加相对路的索引文件解析
2. 本地服务 CocoaHTTPServer(年久失修) 切换到 GCDWebServer(持续更新)。2019-12-09

## 欢迎issues和指正。
