//
//  ZBLM3u8DownloadContainer.m
//  M3U8DownLoadTest
//
//  Created by zengbailiang on 10/4/17.
//  Copyright © 2017 controling. All rights reserved.
//

#import "ZBLM3u8DownloadContainer.h"
#import "ZBLM3u8Analysiser.h"
#import "ZBLM3u8Downloader.h"
#import "ZBLM3u8Info.h"
#import "ZBLM3u8FileDownloadInfo.h"
#import "ZBLM3u8FileManager.h"
#import "ZBLM3u8Setting.h"

NSString * const ZBLM3u8DownloadContainerGreateRootDirErrorDomain = @"error.m3u8.container.createRootDir";

@interface ZBLM3u8DownloadContainer()
@property (nonatomic, strong) ZBLM3u8Info *m3u8Info;
@property (nonatomic, strong) ZBLM3u8Downloader *downloader;
@property (nonatomic, copy) NSString *m3u8OriUrl;
@property (nonatomic, copy) ZBLM3u8DownloadCompletaionHandler completaionHandler;
@property (nonatomic, assign) BOOL isExitRootDir;
@property (nonatomic, strong) ZBLM3u8DownloadProgressHandler downloadProgressHandler;
@property (nonatomic, assign,getter=isCannel) BOOL cannel;
@end

@implementation ZBLM3u8DownloadContainer
- (instancetype)init
{
    self = [super init];
    if (self) {
        _cannel = NO;
    }
    return self;
}

- (void)dealloc{
    
}

- (void)downloadWithUrlString:(NSString *)urlStr  downloadProgressHandler:(ZBLM3u8DownloadProgressHandler)downloadProgressHandler completaionHandler:(ZBLM3u8DownloadCompletaionHandler)completaionHandler
{
    @synchronized (self) {
        self.cannel = NO;
    }
    _m3u8OriUrl = urlStr;
    _completaionHandler = completaionHandler;
    _downloadProgressHandler = downloadProgressHandler;
    if(![self tryCreateRootDir])
    {
        if(_completaionHandler)
            _completaionHandler(nil,[[NSError alloc]initWithDomain:ZBLM3u8DownloadContainerGreateRootDirErrorDomain code:NSURLErrorCannotCreateFile userInfo:nil]);
        return;
    }
    [ZBLM3u8Analysiser analysisWithUrlString:urlStr completaionHandler:^(ZBLM3u8Info *m3u8Info, NSError *error) {
        if (!error) {
            self.m3u8Info = m3u8Info;
            [self createeDownloaderAndStartDownload];
        }
        else
        {
            if(self.completaionHandler)
            {
                self.completaionHandler(nil,error);
                NSLog(@"error:%@",error.description);
            }
        }
    }];
}

- (void)cannel
{
    @synchronized (self) {
        self.cannel = YES;
        [self.downloader cannel];
    }
}

#pragma mark - create downloader
- (void)createeDownloaderAndStartDownload
{
    __weak __typeof(self) weakself = self;
    _downloader = [[ZBLM3u8Downloader alloc]initWithfileDownloadInfos:[self fileDownloadInfos] completaionHandler:^(NSError *error) {
        if (!error) {
            [weakself saveM3u8File];
        }
        else
        {
            if(weakself.completaionHandler)
                weakself.completaionHandler(nil,error);
        }
    } downloadQueue:nil];
    if (_downloadProgressHandler) {
        [_downloader setDownloadProgressHandler:^(float progress){
            if (weakself.downloadProgressHandler) {
                weakself.downloadProgressHandler(progress);
            }
        }];
    }
    @synchronized (self) {
        if(self.isCannel == NO)
            [_downloader start];
    }
}

#pragma mark - info & file
- (BOOL)tryCreateRootDir
{
    return  [ZBLM3u8FileManager tryGreateDir:[[ZBLM3u8Setting commonDirPrefix]  stringByAppendingPathComponent:[ZBLM3u8Setting uuidWithUrl:_m3u8OriUrl]]];
}

- (NSMutableArray <ZBLM3u8FileDownloadInfo*> *)fileDownloadInfos
{
    NSMutableArray <ZBLM3u8FileDownloadInfo*> *fileDownloadInfos = @[].mutableCopy;
    if (_m3u8Info.keyUri.length > 0) {
        ZBLM3u8FileDownloadInfo *downloadKeyInfo = [ZBLM3u8FileDownloadInfo new];
#warning key  and ts info local path build 
        downloadKeyInfo.downloadUrl = _m3u8Info.keyUri;
        downloadKeyInfo.filePath = [[ZBLM3u8Setting fullCommonDirPrefixWithUrl:_m3u8OriUrl]stringByAppendingPathComponent:[ZBLM3u8Setting keyFileName]];
        [fileDownloadInfos addObject:downloadKeyInfo];
    }
    
    for (ZBLM3u8TsInfo *tsInfo in _m3u8Info.tsInfos) {
        ZBLM3u8FileDownloadInfo *downloadInfo = [ZBLM3u8FileDownloadInfo new];
        downloadInfo.downloadUrl = tsInfo.oriUrlString;
        downloadInfo.filePath = [[ZBLM3u8Setting fullCommonDirPrefixWithUrl:_m3u8OriUrl]stringByAppendingPathComponent:[ZBLM3u8Setting tsFileWithIdentify:@(tsInfo.index).stringValue]];
        [fileDownloadInfos addObject:downloadInfo];
        if (tsInfo.localUrlString == nil) {
            NSLog(@"");
        }
    }
    
    return fileDownloadInfos;
}

- (void)saveM3u8File
{
    __weak __typeof(self) weakself = self;
    NSString *m3u8info = [ZBLM3u8Analysiser synthesisLocalM3u8Withm3u8Info:self.m3u8Info];
    [[ZBLM3u8FileManager shareInstance] saveDate:[m3u8info dataUsingEncoding:NSUTF8StringEncoding] ToFile:[[ZBLM3u8Setting fullCommonDirPrefixWithUrl:_m3u8OriUrl] stringByAppendingPathComponent:[ZBLM3u8Setting m3u8InfoFileName]] completaionHandler:^(NSError *error) {
        if(!weakself.completaionHandler) return;
        if (!error) {
            weakself.completaionHandler([NSString stringWithFormat:@"%@/%@/%@",[ZBLM3u8Setting localHost],[ZBLM3u8Setting uuidWithUrl:self.m3u8OriUrl],[ZBLM3u8Setting m3u8InfoFileName]],nil);
        }
        else
        {
                weakself.completaionHandler(nil,error);
        }
    }];
}
@end
