//
//  BNM3U8DownloadCofig.h
//  m3u8Demo
//
//  Created by zengbailiang on 2019/7/20.
//  Copyright © 2019 Bennie. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface BNM3U8DownloadConfig : NSObject
@property (nonatomic, copy) NSString *url;
@property (nonatomic, assign) NSInteger maxConcurrenceCount;
@end

NS_ASSUME_NONNULL_END
