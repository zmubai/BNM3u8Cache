//
//  BNHttpLocalServer.m
//  m3u8DownloadSimpleDemo
//
//  Created by Bennie on 2019/4/29.
//  Copyright © 2019年 Bennie. All rights reserved.
//

#import "BNHttpLocalServer.h"
#import "HTTPServer.h"

@interface BNHttpLocalServer ()
@property (strong, nonatomic) HTTPServer *httpServer;
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
        if (!_httpServer) {
            _httpServer=[[HTTPServer alloc]init];
            [_httpServer setType:@"_http._tcp."];
            NSParameterAssert(_port);
            NSParameterAssert(_documentRoot);
            [_httpServer setPort:_port];
            [_httpServer setDocumentRoot:_documentRoot];
            NSError *error;
            if ([_httpServer start:&error]) {
                NSLog(@"开启HTTP服务器 端口:%hu",[_httpServer listeningPort]);
            }
            else{
                NSLog(@"服务器启动失败错误为:%@",error);
            }
        }
        else if(!_httpServer.isRunning)
        {
            [_httpServer start:nil];
        }
    }
}

- (void)tryStop
{
    @synchronized (self) {
        if([_httpServer isRunning])
            [_httpServer stop:YES];
    }
}
@end
