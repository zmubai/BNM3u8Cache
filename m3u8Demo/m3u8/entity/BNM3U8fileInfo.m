//
//  BNM3U8fileInfo.m
//  m3u8Demo
//
//  Created by zengbailiang on 2019/8/3.
//  Copyright © 2019 Bennie. All rights reserved.
//

#import "BNM3U8fileInfo.h"

@implementation BNM3U8fileInfo
- (NSString *)downloadUrl{
    return _oriUrlString;
}

- (NSString *)dstFilePath{
    return _diskPath;
}
@end

