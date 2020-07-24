//
//  BNM3U8DownloadOperation.m
//  m3u8Demo
//
//  Created by liangzeng on 6/14/19.
//  Copyright © 2019 liangzeng. All rights reserved.
//

#import "BNM3U8DownloadOperation.h"
#import "BNM3U8AnalysisService.h"
#import "BNM3U8PlistInfo.h"
#import "BNM3U8FileDownLoadOperation.h"
#import "BNFileManager.h"
#import "NSString+m3u8.h"

#define LOCK(lock) dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
#define UNLOCK(lock) dispatch_semaphore_signal(lock);

@interface BNM3U8DownloadOperation ()
@property (assign, nonatomic, getter = isCancelled) BOOL cancelled;
@property (assign, nonatomic, getter = isExecuting) BOOL executing;
@property (assign, nonatomic, getter = isFinished) BOOL finished;
@property (assign, nonatomic, getter = isSuspend) BOOL suspend;// suspend 和 resume 方法所影响
@property (nonatomic, strong) BNM3U8DownloadConfig *config;
@property (nonatomic, copy) NSString *downloadDstRootPath;
@property (nonatomic, copy) BNM3U8DownloadOperationResultBlock resultBlock;
@property (nonatomic, copy) BNM3U8DownloadOperationProgressBlock progressBlock;
@property (nonatomic, strong) NSMutableDictionary <NSString*,BNM3U8FileDownLoadOperation*> *downloadOperationsMap;
@property (nonatomic, strong) BNM3U8PlistInfo *plistInfo;
@property (nonatomic, strong) dispatch_semaphore_t operationSemaphore;
@property (nonatomic, strong) NSOperationQueue *downloadQueue;
@property (nonatomic, strong) dispatch_semaphore_t downloadResultCountSemaphore;
@property (nonatomic, assign) NSInteger downloadSuccessCount;
@property (nonatomic, assign) NSInteger downloadFailCount;
@property (nonatomic, strong) AFURLSessionManager *sessionManager;
@end

@implementation BNM3U8DownloadOperation

@synthesize cancelled = _cancelled;
@synthesize executing = _executing;
@synthesize finished = _finished;
@synthesize suspend = _suspend;

- (instancetype)initWithConfig:(BNM3U8DownloadConfig *)config downloadDstRootPath:(NSString *)path sessionManager:(AFURLSessionManager *)sessionManager progressBlock:(BNM3U8DownloadOperationProgressBlock)progressBlock resultBlock:(BNM3U8DownloadOperationResultBlock)resultBlock{
    NSParameterAssert(config);
    NSParameterAssert(path);
    self = [super init];
    if (self) {
        _config = config;
        _downloadDstRootPath = path;
        _resultBlock = resultBlock;
        _progressBlock = progressBlock;
        _executing = NO;
        _finished = NO;
        _suspend = NO;
        _cancelled = NO;
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
    @synchronized (self) {
        if (self.isCancelled) {
            self.finished = YES;
            [self reset];
            return;
        }
        if(self.suspend) {
            return;
        }
        
        __weak __typeof(self) weakSelf = self;
        
        if (![self tryCreateRootDir]) {
            NSError *error = [NSError errorWithDomain:@"创建文件目录失败" code:100 userInfo:nil];
            self.resultBlock(error, nil);
            [self done];
            return;
        }
        
        void (^subOperationlock)(void) = ^(void) {
            [self.plistInfo.fileInfos enumerateObjectsUsingBlock:^(BNM3U8fileInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSParameterAssert(obj.downloadUrl);
                BNM3U8FileDownLoadOperation *operation = [[BNM3U8FileDownLoadOperation alloc]initWithFileInfo:obj sessionManager:self.sessionManager resultBlock:^(NSError * _Nullable error, id _Nullable info) {
                    
                    LOCK(self.operationSemaphore);
                    [self removeOperationFormMapWithUrl:obj.downloadUrl];
                    UNLOCK(self.operationSemaphore);
                    
                    LOCK(self.downloadResultCountSemaphore);
                    [self acceptFileDownloadResult:!error];
                    UNLOCK(self.downloadResultCountSemaphore);
                    
                    [self tryCallBack];
                }];
                [weakSelf.downloadQueue addOperation:operation];
                LOCK(weakSelf.operationSemaphore);
                [self.downloadOperationsMap setValue:operation forKey:obj.downloadUrl];
                UNLOCK(weakSelf.operationSemaphore);
            }];
            self.executing = YES;
        };
        
        if (self.plistInfo) {
            subOperationlock();
        } else {
            [BNM3U8AnalysisService analysisWithURL:_config.url rootPath:_downloadDstRootPath resultBlock:^(NSError * _Nullable error, BNM3U8PlistInfo * _Nullable plistInfo) {
                @synchronized (self) {
                    if (self.isCancelled) {
                        self.finished = YES;
                        [self reset];
                        return;
                    }
                    if (error) {
                        self.resultBlock(error, nil);
                        [self done];
                        return;
                    }
                    self.plistInfo = plistInfo;
                    if (self.suspend) {
                        return;
                    }
                    subOperationlock();
                }
            }];
        }
    }
}

- (void)cancel{
    @synchronized (self) {
        self.cancelled = YES;
        if(self.finished) return;
        [super cancel];
        LOCK(self.operationSemaphore);
        for (BNM3U8fileInfo *obj in self.plistInfo.fileInfos) {
            NSParameterAssert(obj.downloadUrl);
            BNM3U8FileDownLoadOperation *operation = [self.downloadOperationsMap valueForKey:obj.downloadUrl];
            [operation cancel];
            [self removeOperationFormMapWithUrl:obj.downloadUrl];
        }
        UNLOCK(self.operationSemaphore);
        [self tryCallBack];
        if(self.executing) self.executing = NO;
        if(!self.finished) self.finished = YES;
        [self reset];
    }
}
#pragma mark -
- (void)suspend {
    @synchronized (self) {
        if (self.executing) {
            _downloadQueue.suspended = YES;
            LOCK(self.operationSemaphore);
            for (NSString *key in self.downloadOperationsMap.allKeys) {
                BNM3U8FileDownLoadOperation *op = self.downloadOperationsMap[key];
                [op suspend];
            }
            UNLOCK(self.operationSemaphore);
            self.suspend = YES;
            self.executing = NO;
        }
    }
}

- (void)resume {
    @synchronized (self) {
        if (!self.suspend) return;
        _downloadQueue.suspended = NO;
        if(!self.plistInfo) {
            self.suspend = NO;
            [self start];
        } else {
            LOCK(self.operationSemaphore);
            for (NSString *key in self.downloadOperationsMap.allKeys) {
                BNM3U8FileDownLoadOperation *op = self.downloadOperationsMap[key];
                [op resume];
            }
            UNLOCK(self.operationSemaphore);
            self.suspend = NO;
            self.executing = YES;
        }
    }
}

#pragma mark -
- (void)done {
    self.finished = YES;
    self.executing = NO;
    [self reset];
}

- (void)reset {
    LOCK(self.operationSemaphore);
    [self.downloadOperationsMap removeAllObjects];
    UNLOCK(self.operationSemaphore);
    
    LOCK(self.downloadResultCountSemaphore);
    self.downloadSuccessCount = 0;
    self.downloadFailCount = 0;
    UNLOCK(self.downloadResultCountSemaphore);
}

- (void)removeOperationFormMapWithUrl:(NSString *)url
{
    if([self.downloadOperationsMap valueForKey:url]){
        [self.downloadOperationsMap removeObjectForKey:url];
    }
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
    BOOL finish = _downloadSuccessCount + _downloadFailCount == _plistInfo.fileInfos.count;
    BOOL failed = _downloadFailCount > 0;
    NSInteger failedCount = _downloadFailCount;
    if(_progressBlock) _progressBlock(_downloadSuccessCount/(_plistInfo.fileInfos.count * 1.0));
    UNLOCK(_downloadResultCountSemaphore);
    if (finish) {
        if (failed) {
            ///存在文件下载失败
            NSError *error = [NSError errorWithDomain:[NSString stringWithFormat:@"failed download count is %ld",failedCount] code:(NSInteger)100 userInfo:@{@"info":_plistInfo}];
            if(_resultBlock) _resultBlock(error,nil);
            [self done];
        }
        else{
            NSString *m3u8String = [BNM3U8AnalysisService synthesisLocalM3u8Withm3u8Info:_plistInfo withLocaHost:self.config.localhost];
            NSString *dstPath = [[_downloadDstRootPath stringByAppendingPathComponent:[_config.url md5]]stringByAppendingPathComponent:@"dst.m3u8"];
            [[BNFileManager shareInstance]saveDate:[m3u8String dataUsingEncoding:NSUTF8StringEncoding] ToFile:dstPath completaionHandler:^(NSError *error) {
                if (!error) {
                    if(self.resultBlock) self.resultBlock(nil,[[self.config.localhost stringByAppendingString:[self.config.url md5]]stringByAppendingString:@"/dst.m3u8"]);
                }
                else{
                    if(self.resultBlock) self.resultBlock(error,nil);
                }
                [self done];
            }];
        }
    }
}

- (BOOL)tryCreateRootDir
{
    return  [BNFileManager tryGreateDir:[self.downloadDstRootPath stringByAppendingPathComponent:[self.config.url md5]]];
}

#pragma mark - setter / getter
- (void)setCancelled:(BOOL)cancelled {
    [self willChangeValueForKey:@"isCancelled"];
    _cancelled = cancelled;
    [self didChangeValueForKey:@"isCancelled"];
}
- (void)setSuspend:(BOOL)suspend {
    [self willChangeValueForKey:@"isSuspend"];
    _suspend = suspend;
    [self didChangeValueForKey:@"isSuspend"];
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
@end
