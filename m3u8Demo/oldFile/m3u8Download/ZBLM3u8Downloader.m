//
//  ZBLM3u8Downloader.m
//  M3U8DownLoadTest
//
//  Created by zengbailiang on 10/4/17.
//  Copyright © 2017 controling. All rights reserved.
//

#import "ZBLM3u8Downloader.h"
#import "AFNetworking.h"
#import "ZBLM3u8FileDownloadInfo.h"
#import "ZBLM3u8FileManager.h"

@interface ZBLM3u8Downloader ()
@property (nonatomic, strong) dispatch_queue_t downloadQueue;
@property (nonatomic, strong) AFURLSessionManager *sessionManager;
@property (nonatomic, strong) NSMutableArray <ZBLM3u8FileDownloadInfo*> *fileDownloadInfos;
@property (nonatomic, copy) ZBLM3u8DownloaderCompletaionHandler completaionHandler;
@property (nonatomic, strong) dispatch_semaphore_t lock;
@property (nonatomic, assign,getter=isCannel) BOOL cannel;
@end

NSString * const ZBLM3u8DownloaderErrorDomain = @"error.m3u8.downloader";

@implementation ZBLM3u8Downloader
- (instancetype)initWithfileDownloadInfos:(NSMutableArray <ZBLM3u8FileDownloadInfo*> *) fileDownloadInfos completaionHandler:(ZBLM3u8DownloaderCompletaionHandler) completaionHandler downloadQueue:(dispatch_queue_t) downloadQueue
{
    self = [super init];
    if (self) {
        _fileDownloadInfos = fileDownloadInfos;
        _completaionHandler = completaionHandler ;
        _lock = dispatch_semaphore_create(1);
        _cannel = NO;
        if (downloadQueue) {
            _downloadQueue = downloadQueue;
        }
        else
        {
            _downloadQueue = dispatch_queue_create("m3u8.download.queue", DISPATCH_QUEUE_CONCURRENT);
        }
    }
    return self;
}

- (void)dealloc{
    
}

- (void)_lock{
    dispatch_semaphore_wait(self.lock, DISPATCH_TIME_FOREVER);
}

- (void)_unlock{
    dispatch_semaphore_signal(self.lock);
}

- (void)start
{
    @synchronized (self) {
        self.cannel = NO;
    }
    dispatch_async(self.downloadQueue, ^{
        if (!self.fileDownloadInfos.count) {
            self.completaionHandler(nil);
            return;
        }
        if (self.isCannel == YES) return;
        NSLog(@"downloadInfoCount:%ld",(long)self.fileDownloadInfos.count);
        [self.fileDownloadInfos enumerateObjectsUsingBlock:^(ZBLM3u8FileDownloadInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (self.isCannel == YES) return;
            [self _lock];
            if ([ZBLM3u8FileManager exitItemWithPath:obj.filePath]) {
                obj.success = YES;
                [self verifyDownloadCountAndCallbackByDownloadSuccess:YES];
            }
            else
            {
                [self createDownloadTaskWithDownloadInfo:obj];
            }
            [self _unlock];
        }];

    });
}

- (void)createDownloadTaskWithDownloadInfo:(ZBLM3u8FileDownloadInfo*)downloadInfo
{
    if (self.isCannel == YES) return;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:downloadInfo.downloadUrl]];
    __block NSData *data = nil;
    downloadInfo.downloadTask = [self.sessionManager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        NSLog(@"%@:%0.2lf%%\n",downloadInfo.downloadUrl, (float)downloadProgress.completedUnitCount / (float)downloadProgress.totalUnitCount * 100);
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        data = [NSData dataWithContentsOfURL:targetPath];
        return nil;
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (!error) {
            [self downloadSuccessTosaveData:data downloadInfo:downloadInfo];
        }
        else
        {
            NSLog(@"\n\nfile download failed:%@ \n\nerror:%@\n\n",downloadInfo.filePath,error);
            [self _lock];
            downloadInfo.failed = YES;
            [self verifyDownloadCountAndCallbackByDownloadSuccess:NO];
            [self _unlock];
        }
        
    }];
    [downloadInfo.downloadTask resume];
}

- (void)downloadSuccessTosaveData:(NSData *)data downloadInfo:(ZBLM3u8FileDownloadInfo *) downloadInfo
{
    [[ZBLM3u8FileManager shareInstance] saveDate:data ToFile:downloadInfo.filePath completaionHandler:^(NSError *error) {
        if (!error) {
            [self _lock];
            downloadInfo.success = YES;
            [self verifyDownloadCountAndCallbackByDownloadSuccess:YES];
            [self _unlock];
        }
        else
        {
            NSLog(@"save downloadFail failed:%@ \nerror:%@",downloadInfo.filePath,error);
            [self _lock];
            downloadInfo.failed = YES;
            [self verifyDownloadCountAndCallbackByDownloadSuccess:NO];
            [self _unlock];
        }
    }];
}

- (void)verifyDownloadCountAndCallbackByDownloadSuccess:(BOOL) isSuccess
{
    if (self.isCannel == YES) return;
    NSInteger successCount = 0;
    NSInteger failCount = 0;
    for (ZBLM3u8FileDownloadInfo *di in _fileDownloadInfos) {
        if (di.success == YES) {
            successCount ++;
        }
        else if(di.failed == YES)
        {
            failCount ++;
        }
    }
    if (isSuccess) {
        if (_downloadProgressHandler) {
            _downloadProgressHandler(successCount / (float)_fileDownloadInfos.count);
        }
        if (successCount == _fileDownloadInfos.count) {
            _completaionHandler(nil);
            [_sessionManager invalidateSessionCancelingTasks:YES];
            _sessionManager = nil;
            return;
        }
    }
    if (failCount > 0 && successCount + failCount == _fileDownloadInfos.count) {
        NSError *error = [[NSError alloc]initWithDomain:ZBLM3u8DownloaderErrorDomain code:NSURLErrorUnknown userInfo:nil];
        _completaionHandler(error);
    }
}

- (void)cannel
{
    @synchronized (self) {
        self.cannel = YES;
        [_sessionManager invalidateSessionCancelingTasks:YES];
        _sessionManager = nil;
    }
}

#pragma mark -
- (AFURLSessionManager *)sessionManager
{
    if (!_sessionManager) {
        @synchronized (self) {
            if (_cannel == NO) {
                _sessionManager = [[AFURLSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
                _sessionManager.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
            }
            else
            {
                _sessionManager = nil;
            }
        }
    }
    return _sessionManager;
}

@end
