//
//  BNM3U8DownloadOperation.h
//  m3u8Demo
//
//  Created by Bennie on 6/14/19.
//  Copyright © 2019 Bennie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BNM3U8DownloadConfig.h"
#import "AFNetworking.h"
NS_ASSUME_NONNULL_BEGIN


typedef void(^BNM3U8DownloadOperationResultBlock)( NSError * _Nullable error, NSString * _Nullable relativeUrl);
typedef void(^BNM3U8DownloadOperationProgressBlock)(CGFloat progress);
/*
 继承 NSOperation 需实相关方法，包括状态控制
 
 上层使用NSOperationQueue去控制并发，全局控制
 */
@interface BNM3U8DownloadOperation : NSOperation
@property (nonatomic, assign) BOOL suspend;
- (instancetype)initWithConfig:(BNM3U8DownloadConfig *)config downloadDstRootPath:(NSString *)path sessionManager:(AFURLSessionManager *)sessionManager progressBlock:(BNM3U8DownloadOperationProgressBlock)progressBlock resultBlock:(BNM3U8DownloadOperationResultBlock)resultBlock;
@end

NS_ASSUME_NONNULL_END
