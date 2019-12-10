//
//  BNM3U8PlistInfo.h
//  m3u8Demo
//
//  Created by Bennie on 6/14/19.
//  Copyright © 2019 Bennie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BNM3U8fileInfo.h"
NS_ASSUME_NONNULL_BEGIN

@interface BNM3U8PlistInfo : NSObject
@property (nonatomic, copy) NSString *targetduration;
@property (nonatomic, copy) NSString *version;
@property (nonatomic, copy) NSString *mediaSequence;

///key
@property (nonatomic, copy) NSString *keyMethod;
@property (nonatomic, copy) NSString *keyUri;
@property (nonatomic, copy) NSString *keyLocalUri;/// 废弃
@property (nonatomic, copy) NSString *keyIv;
///contain the key file info if exit key.
@property (nonatomic, strong) NSMutableArray <BNM3U8fileInfo*> *fileInfos;
@end

NS_ASSUME_NONNULL_END
