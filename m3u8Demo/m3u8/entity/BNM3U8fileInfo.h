//
//  BNM3U8fileInfo.h
//  m3u8Demo
//
//  Created by zengbailiang on 2019/8/3.
//  Copyright © 2019 Bennie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BNM3U8FileDownloadProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface BNM3U8fileInfo : NSObject <BNM3U8FileDownloadProtocol>
@property (nonatomic, copy) NSString *duration;
@property (nonatomic, copy) NSString *oriUrlString;
@property (nonatomic, copy) NSString *localUrlString;///该字段废弃, 替换为 relativeUrl
@property (nonatomic, copy) NSString *relativeUrl;//相对路径
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, copy) NSString *diskPath;
@property (nonatomic, assign,getter = isHasDiscontiunity) BOOL hasDiscontiunity;
@end

NS_ASSUME_NONNULL_END
