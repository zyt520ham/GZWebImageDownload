//
//  GZWebImage.h
//  GZWebImageDownload
//
//  Created by 张彦涛 on 2017/9/15.
//  Copyright © 2017年 张彦涛. All rights reserved.
//

#ifndef GZWebImage_h
#define GZWebImage_h

#if !__has_feature(objc_arc)
#error GZWebImage is ARC only. Either turn on ARC for the project or use -fobjc-arc flag
#endif

#if __has_include(<UIKit/UIKit.h>)
    #import <UIKit/UIKit.h>
#endif
#if __has_include(<Foundation/Foundation.h>)
    #import <Foundation/Foundation.h>
#endif

#import "UIImageView+GZWebCache.h"
#import "GZWebImageCacheManager.h"
#endif /* GZWebImage_h */
