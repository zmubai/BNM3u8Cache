//
//  ZBLM3u8Analysiser.h
//  M3U8DownLoadTest
//
//  Created by zengbailiang on 10/4/17.
//  Copyright © 2017 controling. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZBLM3u8Info;

typedef void (^ZBLM3u8AnalysiseCompletaionHandler)(ZBLM3u8Info *m3u8Info,NSError *error);

@interface ZBLM3u8Analysiser : NSObject

+ (void)analysisWithUrlString:(NSString*)urlStr completaionHandler:(ZBLM3u8AnalysiseCompletaionHandler)completaionHandler;

+ (NSString*)synthesisLocalM3u8Withm3u8Info:(ZBLM3u8Info *)m3u8Info;

FOUNDATION_EXPORT NSString * const ZBLM3u8AnalysiserResponeErrorDomain;
FOUNDATION_EXPORT NSString * const ZBLM3u8AnalysiserAnalysisErrorDomain;

@end
