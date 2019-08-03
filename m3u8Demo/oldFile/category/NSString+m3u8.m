//
//  NSString+m3u8.m
//  M3U8DownLoadTest
//
//  Created by zengbailiang on 10/5/17.
//  Copyright © 2017 controling. All rights reserved.
//

#import "NSString+m3u8.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (m3u8)
- (NSString *)subStringFrom:(NSString *)startString to:(NSString *)endString
{
    NSRange startRange = [self rangeOfString:startString];
    if (startRange.location == NSNotFound) {
        return nil;
    }
    NSString *newStr = [self substringWithRange:NSMakeRange(startRange.location + startRange.length, self.length - startRange.location - startRange.length)];
    
    NSRange kEndRange = [newStr rangeOfString:endString];
    if (kEndRange.location == NSNotFound) {
        return nil;
    }
    NSRange endRange = NSMakeRange(kEndRange.location + startRange.location + startRange.length, kEndRange.length);
    
    NSRange range = NSMakeRange(startRange.location + startRange.length, endRange.location - startRange.location - startRange.length);
    return [self substringWithRange:range];
}

- (NSString *)subStringForm:(NSString *)string offset:(NSInteger) offset
{
    NSRange startRange = [self rangeOfString:string];
    if (startRange.location != NSNotFound) {
        return [self substringFromIndex:startRange.location + offset];
    }
    return nil;
}

- (NSString *)subStringTo:(NSString *)string
{
    NSRange startRange = [self rangeOfString:string];
    return [self substringWithRange:NSMakeRange(0, startRange.location)];
}

- (NSString *)removeSpaceAndNewline
{
    NSString *temp = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *text = [temp stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet ]];
    return text;
}

#define CC_MD5_DIGEST_LENGTH 16
+ (NSString*)getmd5WithString:(NSString *)string
{
    const char* original_str=[string UTF8String];
    unsigned char digist[CC_MD5_DIGEST_LENGTH];
    CC_MD5(original_str, (uint)strlen(original_str), digist);
    NSMutableString* outPutStr = [NSMutableString stringWithCapacity:10];
    for(int  i =0; i<CC_MD5_DIGEST_LENGTH;i++){
        [outPutStr appendFormat:@"%02x", digist[i]];
    }
    return [outPutStr lowercaseString];
}

- (NSString*)md5
{
    return [NSString getmd5WithString:self];
}

@end
