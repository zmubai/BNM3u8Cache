//
//  BNM3U8FileDownLoadOperation.m
//  m3u8Demo
//
//  Created by Bennie on 6/14/19.
//  Copyright © 2019 Bennie. All rights reserved.
//

#import "BNM3U8FileDownLoadOperation.h"


@interface BNM3U8FileDownLoadOperation ()
@property (nonatomic, assign) NSInteger maxConcurrentCount;
@property (nonatomic, strong) BNM3U8PlistInfo *plistInfo;
@property (nonatomic, strong) BNM3U8FileDownLoadOperationResultBlock resultBlock;
@property (assign, nonatomic, getter = isExecuting) BOOL executing;
@property (assign, nonatomic, getter = isFinished) BOOL finished;
@end

@implementation BNM3U8FileDownLoadOperation

@synthesize executing = _executing;
@synthesize finished = _finished;

- (instancetype)initWithPlistInfo:(BNM3U8PlistInfo *)plistInfo maxConcurrentCount:(NSInteger)maxConcurrentCount resultBlock:(BNM3U8FileDownLoadOperationResultBlock)resultBlock{
    NSParameterAssert(plistInfo);
    self = [super init];
    if (self) {
        self.plistInfo = plistInfo;
        self.maxConcurrentCount = maxConcurrentCount;
        self.resultBlock = resultBlock;
    }
    return self;
}

#pragma mark -
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
