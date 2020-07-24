//
//  BNHttpLocalServer.m
//  m3u8DownloadSimpleDemo
//
//  Created by liangzeng on 2019/4/29.
//  Copyright © 2019年 liangzeng. All rights reserved.
//

#import "BNHttpLocalServer.h"
#import <GCDWebServer.h>

@interface BNHttpLocalServer ()
@property (strong, nonatomic) GCDWebServer *webServer;
@end

@implementation BNHttpLocalServer
+ (instancetype)shareInstance
{
    static BNHttpLocalServer *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}
#pragma mark - service
- (void)tryStart
{
    /*多线程不可重入*/
    @synchronized (self) {
        if(!_webServer){
            _webServer = [[GCDWebServer alloc] init];
            [GCDWebServer setLogLevel:4];
            [_webServer addGETHandlerForBasePath:@"/" directoryPath:[_documentRoot stringByAppendingString:@"/"] indexFilename:nil cacheAge:INT_MAX allowRangeRequests:YES];
            [_webServer startWithPort:8080 bonjourName:nil];
        } else if (![_webServer isRunning]) {
            [_webServer startWithPort:8080 bonjourName:nil];
        }
    }
}

- (void)tryStop
{
    @synchronized (self) {
        [_webServer stop];
    }
}
@end
