//
//  BNM3U8FileDownLoadOperation.m
//  m3u8Demo
//
//  Created by Bennie on 6/14/19.
//  Copyright © 2019 Bennie. All rights reserved.
//

#import "BNM3U8FileDownLoadOperation.h"
#import "BNFileManager.h"

@interface BNM3U8FileDownLoadOperation ()
@property (nonatomic, strong) NSObject <BNM3U8FileDownloadProtocol> *fileInfo;
@property (nonatomic, strong) BNM3U8FileDownLoadOperationResultBlock resultBlock;
@property (nonatomic, strong) AFURLSessionManager *sessionManager;
@property (assign, nonatomic, getter = isExecuting) BOOL executing;
@property (assign, nonatomic, getter = isFinished) BOOL finished;
@property (nonatomic, strong) NSURLSessionDownloadTask *dataTask;
@end

@implementation BNM3U8FileDownLoadOperation

@synthesize executing = _executing;
@synthesize finished = _finished;

- (instancetype)initWithFileInfo:(NSObject <BNM3U8FileDownloadProtocol> *)fileInfo sessionManager:(AFURLSessionManager*)sessionManager resultBlock:(BNM3U8FileDownLoadOperationResultBlock)resultBlock{
    NSParameterAssert(fileInfo);
    self = [super init];
    if (self) {
        _fileInfo = fileInfo;
        _resultBlock = resultBlock;
        _sessionManager = sessionManager;
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
        ///file already exit
        if([BNFileManager exitItemWithPath:_fileInfo.dstFilePath]){
            _resultBlock(nil,_fileInfo);
            [self done];
            return;
        }
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:_fileInfo.downloadUrl]];
        __block NSData *data = nil;
        __weak __typeof(self) weakSelf = self;
        NSURLSessionDownloadTask *downloadTask = [self.sessionManager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
            NSLog(@"%@:%0.2lf%%\n",weakSelf.fileInfo.downloadUrl, (float)downloadProgress.completedUnitCount / (float)downloadProgress.totalUnitCount * 100);
        } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            data = [NSData dataWithContentsOfURL:targetPath];
            return nil;
        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            @synchronized (self) {
                if (!error) {
                    [weakSelf saveData:data];
                }
                else
                {
                    weakSelf.resultBlock(error,self.fileInfo);
                    [self done];
                }
            }
        }];
        self.dataTask = downloadTask;
        [downloadTask resume];
        self.executing = YES;
    }
}

- (void)saveData:(NSData *)data
{
    [[BNFileManager shareInstance] saveDate:data ToFile:[_fileInfo dstFilePath] completaionHandler:^(NSError *error) {
        @synchronized (self) {
            if (!error) {
                if(self.resultBlock) self.resultBlock(nil,self.fileInfo);
            }
            else
            {
                if(self.resultBlock) self.resultBlock(error, self.fileInfo);
            }
            [self done];
        }
    }];
}

- (void)cancel{
    @synchronized (self) {
        if(self.isFinished) return;
        [super cancel];
        [self.dataTask cancel];
        if (self.isExecuting) self.executing = NO;
        if (!self.isFinished) self.finished = YES;
        [self reset];
    }
}

- (void)done {
    self.finished = YES;
    self.executing = NO;
    [self reset];
}

- (void)reset {
    @synchronized (self) {
        self.dataTask = nil;
    }
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
