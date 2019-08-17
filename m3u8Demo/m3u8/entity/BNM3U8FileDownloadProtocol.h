//
//  BNM3U8FileDownloadProtocol.h
//  m3u8Demo
//
//  Created by Bennie on 6/14/19.
//  Copyright © 2019 Bennie. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol BNM3U8FileDownloadProtocol <NSObject>
@required
- (NSString *)downloadUrl;
- (NSString *)dstFilePath;
@end

NS_ASSUME_NONNULL_END
