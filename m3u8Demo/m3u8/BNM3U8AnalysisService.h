//
//  BNM3U8AnalysisService.h
//  m3u8Demo
//
//  Created by Bennie on 6/14/19.
//  Copyright © 2019 Bennie. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class BNM3U8PlistInfo;
typedef  void(^BNM3U8AnalysisServiceResultBlock)(NSError * _Nullable error, BNM3U8PlistInfo * _Nullable plistInfo);
@interface BNM3U8AnalysisService : NSObject
///需要传入 rootDstPath
//解析并生成本地地址
+ (void)analysisWithURL:(NSString *)url resultBlock:(BNM3U8AnalysisServiceResultBlock)resultBlock;
@end

NS_ASSUME_NONNULL_END
