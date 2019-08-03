//
//  ZBLM3u8Downloader.h
//  M3U8DownLoadTest
//
//  Created by zengbailiang on 10/4/17.
//  Copyright © 2017 controling. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZBLM3u8FileDownloadInfo;

typedef void (^ZBLM3u8DownloaderCompletaionHandler)(NSError *error);
typedef void (^ZBLM3u8DownloaderProgressHandler)(float progress);

@interface ZBLM3u8Downloader : NSObject
@property (nonatomic, strong) ZBLM3u8DownloaderProgressHandler downloadProgressHandler;

- (instancetype)initWithfileDownloadInfos:(NSMutableArray <ZBLM3u8FileDownloadInfo*> *) fileDownloadInfos completaionHandler:(ZBLM3u8DownloaderCompletaionHandler) completaionHandler downloadQueue:(dispatch_queue_t) downloadQueue;

- (void)start;

- (void)cannel;

FOUNDATION_EXPORT NSString * const ZBLM3u8DownloaderErrorDomain;

@end
