//
//  NSString+m3u8.h
//  M3U8DownLoadTest
//
//  Created by zengbailiang on 10/5/17.
//  Copyright © 2017 controling. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (m3u8)
- (NSString*)subStringFrom:(NSString *)startString to:(NSString *)endString;
- (NSString*)subStringForm:(NSString *)string offset:(NSInteger) offset;
- (NSString*)subStringTo:(NSString *)string;
- (NSString*)removeSpaceAndNewline;
- (NSString*)md5;
@end
