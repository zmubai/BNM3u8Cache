//
//  BNM3U8DownloadOperation.m
//  m3u8Demo
//
//  Created by Bennie on 6/14/19.
//  Copyright © 2019 Bennie. All rights reserved.
//

#import "BNM3U8DownloadOperation.h"
#import "BNM3U8AnalysisService.h"

@interface BNM3U8DownloadOperation ()
@property (assign, nonatomic, getter = isExecuting) BOOL executing;
@property (assign, nonatomic, getter = isFinished) BOOL finished;
@end

@implementation BNM3U8DownloadOperation

///告诉编译器合成get set
@synthesize executing = _executing;
@synthesize finished = _finished;

- (void)start
{
    ///加入到 operationqueue 中是否 会在异步线程发起？  推测应该是的，待测试后确认
    //实现
    @synchronized (self) {
        if (self.isCancelled) {
            self.finished = YES;
            [self reset];
            return;
        }
        //获取文本文件，发起下一级下载
        [BNM3U8AnalysisService analysisWithURL:self.config.url resultBlock:^(NSError * _Nullable error, BNM3U8PlistInfo * _Nullable plistInfo) {
            if (error) {
            ///failed
                self.resultBlock(error, nil);
                [self done];
                return;
            }
            
            ///to download
        }];
        //发起下一级下载
    }
}

- (void)cancel{
    
}

- (void)done {
    self.finished = YES;
    self.executing = NO;
    [self reset];
}

- (void)reset {
//    LOCK(self.callbacksLock);
//    [self.callbackBlocks removeAllObjects];
//    UNLOCK(self.callbacksLock);
//
//    @synchronized (self) {
//        self.dataTask = nil;
//
//        if (self.ownedSession) {
//            [self.ownedSession invalidateAndCancel];
//            self.ownedSession =
//            nil;
//        }
//
//#if SD_UIKIT
//        if (self.backgroundTaskId != UIBackgroundTaskInvalid) {
//            // If backgroundTaskId != UIBackgroundTaskInvalid, sharedApplication is always exist
//            UIApplication * app = [UIApplication performSelector:@selector(sharedApplication)];
//            [app endBackgroundTask:self.backgroundTaskId];
//            self.backgroundTaskId = UIBackgroundTaskInvalid;
//        }
//#endif
//    }
}

#pragma mark - need to realize kvo
- (void)setFinished:(BOOL)finished {
    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
    [self didChangeValueForKey:@"isFinished"];
}

- (void)setExecuting:(BOOL)executing {
    [self willChangeValueForKey:@"isExecuting"];
    _executing = executing;
    [self didChangeValueForKey:@"isExecuting"];
}

- (BOOL)isConcurrent {
    return YES;
}

@end
