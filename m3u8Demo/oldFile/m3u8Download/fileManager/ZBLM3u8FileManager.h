//
//  ZBLM3u8FileManager.h
//  M3U8DownLoadTest
//
//  Created by zengbailiang on 10/5/17.
//  Copyright © 2017 controling. All rights reserved.
//

#import <Foundation/Foundation.h>
/*目录创建，目录校验，文件校验，文件写入...*/

typedef void (^ZBLM3u8FileManagerCompletaionHandler)(NSError *error);

@interface ZBLM3u8FileManager : NSObject

+ (instancetype)shareInstance;

- (instancetype)initWithIoQueue:(dispatch_queue_t)ioQueue;

+ (BOOL)tryGreateDir:(NSString *)dir;

+ (BOOL)exitItemWithPath:(NSString*)path;

- (void)saveDate:(NSData*) aData pathUrl:(NSURL*)pathUrl completaionHandler:(ZBLM3u8FileManagerCompletaionHandler)completaionHandler;

- (void)saveDate:(NSData*) aData ToFile:(NSString *)file completaionHandler:(ZBLM3u8FileManagerCompletaionHandler)completaionHandler;

- (void)moveItemAtURL:(NSURL *)srcURL toURL:(NSURL *)dstURL completaionHandler:(ZBLM3u8FileManagerCompletaionHandler)completaionHandler;

- (void)tryCreateDictionaryWithPath:(NSString*)path completaionHandler:(ZBLM3u8FileManagerCompletaionHandler)completaionHandler;

- (void)removeFileWithPath:(NSString *)path;

FOUNDATION_EXPORT NSString * const ZBLM3u8FileManagerWriteErrorDomain;

@end
