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
#import "ZBLM3u8FileManager.h"
#import "BNTool.h"

#define LOCK(lock) dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
#define UNLOCK(lock) dispatch_semaphore_signal(lock);

@interface BNM3U8DownloadOperation ()
@property (assign, nonatomic, getter = isExecuting) BOOL executing;
@property (assign, nonatomic, getter = isFinished) BOOL finished;
@property (nonatomic, strong) BNM3U8DownloadConfig *config;
@property (nonatomic, copy) NSString *downloadDstRootPath;
@property (nonatomic, copy) BNM3U8DownloadOperationResultBlock resultBlock;
///不存在 cannel 单个文件 故不需要数组容器存储.但需要用来计算BNM3U8DownloadOperation 是否完成。或许用不上
@property (nonatomic, strong) NSMutableDictionary <NSString*,BNM3U8FileDownLoadOperation*> *downloadOperationsMap;
@property (nonatomic, strong) BNM3U8PlistInfo *plistInfo;
@property (nonatomic, strong) dispatch_semaphore_t operationSemaphore;
@property (nonatomic, strong) NSOperationQueue *downloadQueue;
///需要考虑 cannel 的情况
@property (nonatomic, strong) dispatch_semaphore_t downloadResultCountSemaphore;
@property (nonatomic, assign) NSInteger downloadSuccessCount;
@property (nonatomic, assign) NSInteger downloadFailCount;
@property (nonatomic, strong) AFURLSessionManager *sessionManager;
@end

@implementation BNM3U8DownloadOperation
///告诉编译器合成get set
@synthesize executing = _executing;
@synthesize finished = _finished;

- (instancetype)initWithConfig:(BNM3U8DownloadConfig *)config downloadDstRootPath:(NSString *)path sessionManager:(AFURLSessionManager *)sessionManager resultBlock:(BNM3U8DownloadOperationResultBlock)resultBlock{
    NSParameterAssert(config);
    NSParameterAssert(path);
    self = [super init];
    if (self) {
        _config = config;
        _downloadDstRootPath = path;
        _resultBlock = resultBlock;
        _operationSemaphore = dispatch_semaphore_create(1);
        _downloadResultCountSemaphore = dispatch_semaphore_create(1);
        _downloadQueue = [[NSOperationQueue alloc]init];
        _downloadQueue.maxConcurrentOperationCount = self.config.maxConcurrenceCount;
        _downloadOperationsMap = NSMutableDictionary.new;
        _sessionManager = sessionManager;
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
        
        __weak __typeof(self) weakSelf = self;
        
        //获取文本文件，发起下一级下载
        [BNM3U8AnalysisService analysisWithURL:_config.url  rootPath:_downloadDstRootPath  resultBlock:^(NSError * _Nullable error, BNM3U8PlistInfo * _Nullable plistInfo) {
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
                BNM3U8FileDownLoadOperation *operation = [[BNM3U8FileDownLoadOperation alloc]initWithFileInfo:obj sessionManager:self.sessionManager resultBlock:^(NSError * _Nullable error, id _Nullable info) {
                    /// remove from map
                    LOCK(weakSelf.operationSemaphore);
                    [weakSelf removeOperationFormMapWithUrl:obj.downloadUrl];
                    UNLOCK(weakSelf.operationSemaphore);
                    ///async ？？？
                    LOCK(weakSelf.downloadResultCountSemaphore);
                    if (error) {
                        ///record download result count
                        [weakSelf acceptFileDownloadResult:NO];
                    }
                    else{
                        [weakSelf acceptFileDownloadResult:YES];
                    }
                    UNLOCK(weakSelf.downloadResultCountSemaphore);
                    [weakSelf tryCallBack];
                }];
                [weakSelf.downloadQueue addOperation:operation];
                LOCK(weakSelf.operationSemaphore);
                [self.downloadOperationsMap setValue:operation forKey:obj.downloadUrl];
                UNLOCK(weakSelf.operationSemaphore);
            }];
        }];
    }
    /// 目前没有重新发起的功能， 所以只会在这里设置execut
    self.executing = YES;
}

- (void)cancel{
    ///@synchronized (self) 内部是用递归锁实现的，可以嵌套使用
    @synchronized (self) {
        if(self.finished) return;
        [super cancel];
        LOCK(_operationSemaphore);
        [self.plistInfo.fileInfos enumerateObjectsUsingBlock:^(BNM3U8fileInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSParameterAssert(obj.downloadUrl);
            BNM3U8FileDownLoadOperation *operation = [self.downloadOperationsMap valueForKey:obj.downloadUrl];
            [operation cancel];
            //need to remove from map
            [self removeOperationFormMapWithUrl:obj.downloadUrl];
        }];
        UNLOCK(_operationSemaphore);
        [self tryCallBack];
        if(self.executing) self.executing = NO;
        if(!self.finished) self.finished = YES;
        [self reset];
    }
}

- (void)done {
    self.finished = YES;
    self.executing = NO;
    [self reset];
}

- (void)reset {
    LOCK(self.operationSemaphore);
    [self.downloadOperationsMap removeAllObjects];
    UNLOCK(self.operationSemaphore);
    
    @synchronized (self) {
        self.downloadSuccessCount = 0;
        self.downloadFailCount = 0;
        //        if (self.ownedSession) {
        //            [self.ownedSession invalidateAndCancel];
        //            self.ownedSession =
        //            nil;
    }
}

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
    LOCK(_operationSemaphore);
    [self.downloadOperationsMap removeObjectForKey:url];
    //    [self checkFinish];
    UNLOCK(_operationSemaphore);
}

- (void)acceptFileDownloadResult:(BOOL)success {
    if (success) {
        self.downloadSuccessCount += 1;
    }
    else{
        self.downloadFailCount += 1;
    }
}

- (void)tryCallBack
{
    LOCK(_downloadResultCountSemaphore);
    BOOL finish = _downloadFailCount + _downloadFailCount == _plistInfo.fileInfos.count;
    BOOL failed = _downloadFailCount > 0;
    NSInteger failedCount = _downloadFailCount;
    UNLOCK(_downloadResultCountSemaphore);
    if (finish) {
        [self done];
        if (failed) {
            ///存在文件下载失败
            NSError *error = [NSError errorWithDomain:[NSString stringWithFormat:@"file download count is %ld",failedCount] code:100 userInfo:@{@"info":_plistInfo}];
            if(_resultBlock) _resultBlock(error,nil);
        }
        else{
            NSString *m3u8String = [BNM3U8AnalysisService synthesisLocalM3u8Withm3u8Info:_plistInfo withLocaHost:self.config.localhost];
            NSString *dstPath = [[_downloadDstRootPath stringByAppendingString:[BNTool uuidWithUrl:_config.url]]stringByAppendingPathComponent:@"local.m3u8"];
            [[ZBLM3u8FileManager shareInstance]saveDate:[m3u8String dataUsingEncoding:NSUTF8StringEncoding] ToFile:dstPath completaionHandler:^(NSError *error) {
                if (!error) {
                    if(self.resultBlock) self.resultBlock(nil,[[self.config.localhost stringByAppendingString:[BNTool uuidWithUrl:self.config.url]]stringByAppendingPathComponent:@"local.m3u8"]);
                }
                else{
                    if(self.resultBlock) self.resultBlock(error,nil);
                }
            }];
        }
    }
    UNLOCK(_downloadResultCountSemaphore);
}
@end