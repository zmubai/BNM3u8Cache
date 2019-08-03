//
//  BNM3U8DownloadOperation.m
//  m3u8Demo
//
//  Created by Bennie on 6/14/19.
//  Copyright © 2019 Bennie. All rights reserved.
//

#import "BNM3U8DownloadOperation.h"

@interface BNM3U8DownloadOperation ()
@property (assign, nonatomic, getter = isExecuting) BOOL executing;
@property (assign, nonatomic, getter = isFinished) BOOL finished;
@end

@implementation BNM3U8DownloadOperation
- (BNM3U8DownloadConfig *)config
{
    if(!_config)
    {
        _config = BNM3U8DownloadConfig.new;
    }
    return _config;
}
@end
