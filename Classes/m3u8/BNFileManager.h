//
//  ZBLM3u8FileManager.h
//  M3U8DownLoadTest
//
//  Created by zengbailiang on 10/5/17.
//  Copyright © 2017 controling. All rights reserved.
//

#import <Foundation/Foundation.h>
/*目录创建，目录校验，文件校验，文件写入...*/

typedef void (^BNFileManagerCompletaionHandler)(NSError *error);

@interface BNFileManager : NSObject

+ (instancetype)shareInstance;

- (instancetype)initWithIoQueue:(dispatch_queue_t)ioQueue;

+ (BOOL)tryGreateDir:(NSString *)dir;

+ (BOOL)exitItemWithPath:(NSString*)path;

- (void)saveDate:(NSData*) aData pathUrl:(NSURL*)pathUrl completaionHandler:(BNFileManagerCompletaionHandler)completaionHandler;

- (void)saveDate:(NSData*) aData ToFile:(NSString *)file completaionHandler:(BNFileManagerCompletaionHandler)completaionHandler;

- (void)moveItemAtURL:(NSURL *)srcURL toURL:(NSURL *)dstURL completaionHandler:(BNFileManagerCompletaionHandler)completaionHandler;

- (void)tryCreateDictionaryWithPath:(NSString*)path completaionHandler:(BNFileManagerCompletaionHandler)completaionHandler;

- (void)removeFileWithPath:(NSString *)path;

FOUNDATION_EXPORT NSString * const BNM3u8FileManagerWriteErrorDomain;

@end
