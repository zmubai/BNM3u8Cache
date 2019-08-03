//
//  ZBLM3u8Info.h
//  M3U8DownLoadTest
//
//  Created by zengbailiang on 10/5/17.
//  Copyright © 2017 controling. All rights reserved.
//

#import <Foundation/Foundation.h>
/*
 
 #EXTM3U
 #EXT-X-TARGETDURATION:12
 #EXT-X-VERSION:3
 #EXTINF:3.68,
 http://183.6.223.103/6977C40889D3672BED0F02895/030008010059D427BB9B9B15BC5F099040AD33-AD8F-1D70-F875-80422863C610.mp4.ts?ccode=02010101&duration=80&expire=18000&psid=a0faa0167404dbd00c46f4143f88c3f2&ups_client_netip=14.127.249.226&ups_ts=1507122203&ups_userid=&utid=WByvE10ZfJcDAJDjRNep1SWR&vid=XMzA2NDA2MTQ4OA%3D%3D&vkey=A3156fbad00f464c571d7ecaeda8d221b&ts_start=0.0&ts_end=3.58&ts_seg_no=0&ts_keyframe=1
 #EXTINF:4.2,
 http://183.6.223.103/6977C40889D3672BED0F02895/030008010059D427BB9B9B15BC5F099040AD33-AD8F-1D70-F875-80422863C610.mp4.ts?ccode=02010101&duration=80&expire=18000&psid=a0faa0167404dbd00c46f4143f88c3f2&ups_client_netip=14.127.249.226&ups_ts=1507122203&ups_userid=&utid=WByvE10ZfJcDAJDjRNep1SWR&vid=XMzA2NDA2MTQ4OA%3D%3D&vkey=A3156fbad00f464c571d7ecaeda8d221b&ts_start=3.58&ts_end=7.78&ts_seg_no=1&ts_keyframe=1
 #EXT-X-ENDLIST
 
 */
@class ZBLM3u8TsInfo;

@interface ZBLM3u8Info : NSObject
@property (nonatomic, copy) NSString *targetduration;
@property (nonatomic, copy) NSString *version;
@property (nonatomic, copy) NSString *mediaSequence;

///key
@property (nonatomic, copy) NSString *keyMethod;
@property (nonatomic, copy) NSString *keyUri;
@property (nonatomic, copy) NSString *keyLocalUri;
@property (nonatomic, copy) NSString *keyIv;
@property (nonatomic, strong) NSMutableArray <ZBLM3u8TsInfo*> *tsInfos;
@end
@interface ZBLM3u8TsInfo : NSObject
@property (nonatomic, copy) NSString *duration;
@property (nonatomic, copy) NSString *oriUrlString;
@property (nonatomic, copy) NSString *localUrlString;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign,getter = isHasDiscontiunity) BOOL hasDiscontiunity;
@end

