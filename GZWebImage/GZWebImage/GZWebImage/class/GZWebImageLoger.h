//
//  GZWebImageLoger.h
//  GZWebImageDownload
//
//  Created by 张彦涛 on 2017/9/15.
//  Copyright © 2017年 张彦涛. All rights reserved.
//

#if __has_include(<Foundation/Foundation.h>)
#import <Foundation/Foundation.h>
#endif
#if __has_include(<UIKit/UIKit.h>)
#import <UIKit/UIKit.h>
#endif

@interface GZWebImageLoger : NSObject

#define GZWebImageLogBaseLog(FORMAT, ...) fprintf(stderr,"%s\n",[[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);

#ifdef DEBUG
#ifndef GZWebImageLog
#define GZWebImageLog(fmt, ...) {\
NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];\
[dateFormatter setDateStyle:NSDateFormatterMediumStyle];\
[dateFormatter setTimeStyle:NSDateFormatterShortStyle];\
[dateFormatter setDateFormat:@"MM-dd HH:mm:ss:SSSSSS"]; \
NSString *timeStr = [dateFormatter stringFromDate:[NSDate date]];\
GZWebImageLogBaseLog((@"【GZWebImageLog】[%s] %s (line:%d) 。。。。。。。。。" fmt),[timeStr UTF8String], __FUNCTION__, __LINE__, ##__VA_ARGS__);\
}

#endif
#else
#ifndef GZWebImageLog
#define GZWebImageLog(...)
#endif
#endif

@end
