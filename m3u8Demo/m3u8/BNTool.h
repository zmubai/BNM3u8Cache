//
//  BNTool.h
//  m3u8Demo
//
//  Created by zengbailiang on 2019/8/17.
//  Copyright © 2019 Bennie. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BNTool : NSObject
#pragma mark - dir/fileName
//+ (NSString *)commonDirPrefix;
//+ (NSString *)m3u8InfoFileName;
//+ (NSString *)oriM3u8InfoFileName;
//+ (NSString *)keyFileName;
+ (NSString *)uuidWithUrl:(NSString *)Url;
+ (NSString *)fullCommonDirPrefixWithUrl:(NSString *)url;
+ (NSString *)tsFileWithIdentify:(NSString *)identify;
@end

NS_ASSUME_NONNULL_END
