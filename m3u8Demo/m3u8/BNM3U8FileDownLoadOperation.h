//
//  BNM3U8FileDownLoadOperation.h
//  m3u8Demo
//
//  Created by Bennie on 6/14/19.
//  Copyright © 2019 Bennie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BNM3U8PlistInfo.h"

NS_ASSUME_NONNULL_BEGIN
typedef void(^BNM3U8FileDownLoadOperationResultBlock)(NSError * _Nullable error, NSString * _Nullable localPlayUrlString);
@interface BNM3U8FileDownLoadOperation : NSOperation
- (instancetype)initWithPlistInfo:(BNM3U8PlistInfo *)plistInfo maxConcurrentCount:(NSInteger)maxConcurrentCount resultBlock:(BNM3U8FileDownLoadOperationResultBlock)resultBlock;
@end

NS_ASSUME_NONNULL_END
