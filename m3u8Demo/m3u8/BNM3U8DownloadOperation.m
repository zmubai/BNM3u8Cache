//
//  BNM3U8DownloadOperation.m
//  m3u8Demo
//
//  Created by Bennie on 6/14/19.
//  Copyright © 2019 Bennie. All rights reserved.
//

#import "BNM3U8DownloadOperation.h"
#import "BNM3U8AnalysisService.h"
#import "BNM3U8PlistInfo.h"
#import "BNM3U8FileDownLoadOperation.h"

@interface BNM3U8DownloadOperation ()
@property (assign, nonatomic, getter = isExecuting) BOOL executing;
@property (assign, nonatomic, getter = isFinished) BOOL finished;
@property (nonatomic, strong) BNM3U8DownloadConfig *config;
@property (nonatomic, copy) NSString *downloadDstRootPath;
@property (nonatomic, copy) BNM3U8DownloadOperationResultBlock resultBlock;
///不存在 cannel 单个文件 故不需要数组容器存储.但需要用来计算BNM3U8DownloadOperation 是否完成。
@property (nonatomic,strong) NSMutableDictionary <NSString*,BNM3U8FileDownLoadOperation*> *downloadOperationsMap;
@property (nonatomic, strong) BNM3U8PlistInfo *plistInfo;
@property (nonatomic,strong) dispatch_semaphore_t operationSemaphore;
@property (nonatomic,strong) NSOperationQueue *downloadQueue;
@end

@implementation BNM3U8DownloadOperation
///告诉编译器合成get set
@synthesize executing = _executing;
@synthesize finished = _finished;

- (instancetype)initWithConfig:(BNM3U8DownloadConfig *)config downloadDstRootPath:(NSString *)path resultBlock:(BNM3U8DownloadOperationResultBlock)resultBlock{
    NSParameterAssert(config);
    NSParameterAssert(path);
    self = [super init];
    if (self) {
        self.config = config;
        self.downloadDstRootPath = path;
        self.resultBlock = resultBlock;
        self.operationSemaphore = dispatch_semaphore_create(1);
        self.downloadQueue = [[NSOperationQueue alloc]init];
        self.downloadQueue.maxConcurrentOperationCount = self.config.maxConcurrenceCount;
        self.downloadOperationsMap = NSMutableDictionary.new;
    }
    return self;
}

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
        
        __unsafe_unretained __typeof(self) unownedSelf = self;
        
        //获取文本文件，发起下一级下载
        [BNM3U8AnalysisService analysisWithURL:self.config.url resultBlock:^(NSError * _Nullable error, BNM3U8PlistInfo * _Nullable plistInfo) {
            if (error) {
            ///failed
                self.resultBlock(error, nil);
                [self done];
                return;
            }
            self.plistInfo = plistInfo;
            ///to download 发起下一级下载
            [plistInfo.fileInfos enumerateObjectsUsingBlock:^(BNM3U8fileInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSParameterAssert(obj.downloadUrl);
                BNM3U8FileDownLoadOperation *operation = [[BNM3U8FileDownLoadOperation alloc]initWithFileInfo:obj resultBlock:^(NSError * _Nullable error, NSString * _Nullable localPlayUrlString) {
                    if(!unownedSelf.resultBlock) return ;
                    if (error) {
                        unownedSelf.resultBlock(error, nil);
                        //if need other process ???
                        [unownedSelf removeOperationFormMapWithUrl:obj.downloadUrl];
                        return;
                    }
                    unownedSelf.resultBlock(nil, localPlayUrlString);
                }];
                [self.downloadQueue addOperation:operation];
                [self.downloadOperationsMap setValue:operation forKey:obj.downloadUrl];
            }];
        }];
    }
}

- (void)cancel{
    @synchronized (self) {
        [self.plistInfo.fileInfos enumerateObjectsUsingBlock:^(BNM3U8fileInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSParameterAssert(obj.downloadUrl);
            BNM3U8FileDownLoadOperation *operation = [self.downloadOperationsMap valueForKey:obj.downloadUrl];
            [operation cancel];
            //need to remove from map
            [self removeOperationFormMapWithUrl:obj.downloadUrl];
        }];
    }
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

#pragma mark -
- (void)removeOperationFormMapWithUrl:(NSString *)url
{
    NSParameterAssert([self.downloadOperationsMap valueForKey:url]);
    [self.downloadOperationsMap removeObjectForKey:url];
    [self checkFinish];
}

- (void)checkFinish
{
    if (self.downloadOperationsMap.count == 0) {
        [self done];
        return;
    }
    BOOL unFinish = YES;
    [self.downloadOperationsMap.allKeys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BNM3U8FileDownLoadOperation *operation = [self.downloadOperationsMap valueForKey:obj];
        /////
        if (operation.isFinished) {
            
        }
    }];
}

@end
