//
//  BNM3U8Manager.m
//  m3u8Demo
//
//  Created by Bennie on 6/14/19.
//  Copyright © 2019 Bennie. All rights reserved.
//

#import "BNM3U8Manager.h"

#define LOCK(lock) dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
#define UNLOCK(lock) dispatch_semaphore_signal(lock);

@implementation BNM3U8ManagerConfig
@end

@interface BNM3U8Manager()
@property (nonatomic,strong) BNM3U8ManagerConfig *config;
@property (nonatomic,strong) dispatch_semaphore_t moviceSemaphore;
@property (nonatomic,strong) dispatch_semaphore_t operationSemaphore;
@property (nonatomic,strong) NSOperationQueue *downloadQueue;
@end

@implementation BNM3U8Manager

+ (instancetype)shareInstanceWithConfig:(BNM3U8ManagerConfig*)config
{
    static BNM3U8Manager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = BNM3U8Manager.new;
        manager.config = config;
        manager.moviceSemaphore = dispatch_semaphore_create(manager.config.videoMaxConcurrenceCount);
        manager.operationSemaphore = dispatch_semaphore_create(1);
        manager.downloadQueue = [[NSOperationQueue alloc]init];
    });
    return manager;
}



@end
