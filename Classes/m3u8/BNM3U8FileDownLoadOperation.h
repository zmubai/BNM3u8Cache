//
//  BNM3U8FileDownLoadOperation.h
//  m3u8Demo
//
//  Created by liangzeng on 6/14/19.
//  Copyright © 2019 liangzeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BNM3U8FileDownloadProtocol.h"
#import "AFNetworking.h"

/* 一个 fileOperation 只负责下载一个文件*/
NS_ASSUME_NONNULL_BEGIN
typedef void(^BNM3U8FileDownLoadOperationResultBlock)(NSError * _Nullable error,id _Nullable info);
@interface BNM3U8FileDownLoadOperation : NSOperation
- (instancetype)initWithFileInfo:(NSObject <BNM3U8FileDownloadProtocol> *)fileInfo sessionManager:(AFURLSessionManager*)sessionManager resultBlock:(BNM3U8FileDownLoadOperationResultBlock)resultBlock;
- (void)suspend;
- (void)resume;
@end

NS_ASSUME_NONNULL_END
