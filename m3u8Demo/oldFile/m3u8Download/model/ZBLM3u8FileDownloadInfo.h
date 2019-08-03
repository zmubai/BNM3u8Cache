//
//  ZBLM3u8FileDownloadInfo.h
//  M3U8DownLoadTest
//
//  Created by zengbailiang on 10/5/17.
//  Copyright © 2017 controling. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZBLM3u8FileDownloadInfo : NSObject
@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, copy) NSString *downloadUrl;
@property (nonatomic, assign) BOOL success;
@property (nonatomic, assign) BOOL failed;
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;
@end
