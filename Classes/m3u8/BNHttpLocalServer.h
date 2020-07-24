//
//  BNHttpLocalServer.h
//  m3u8DownloadSimpleDemo
//
//  Created by liangzeng on 2019/4/29.
//  Copyright © 2019年 liangzeng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BNHttpLocalServer : NSObject
@property (strong, nonatomic) NSString *documentRoot;
@property (assign, nonatomic) NSInteger port;
+ (instancetype)shareInstance;
- (void)tryStart;
- (void)tryStop;
@end

NS_ASSUME_NONNULL_END
