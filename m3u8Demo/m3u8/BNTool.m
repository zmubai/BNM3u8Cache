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

+ (NSString *)fullCommonDirPrefixWithUrl:(NSString *)url rootPath:(NSString *)rootPath
{
    return [rootPath stringByAppendingPathComponent:[self uuidWithUrl:url]];
}

+ (NSString *)tsFileWithIdentify:(NSString *)identify;
{
    return [NSString stringWithFormat:@"%@.ts",identify];
}

@end
