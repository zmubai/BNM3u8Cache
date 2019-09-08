//
//  BNTool.m
//  m3u8Demo
//
//  Created by zengbailiang on 2019/8/17.
//  Copyright © 2019 Bennie. All rights reserved.
//

#import "BNTool.h"
#import "NSString+m3u8.h"

@implementation BNTool
+ (NSString *)uuidWithUrl:(NSString *)Url
{
    return [Url md5];
}

@end
