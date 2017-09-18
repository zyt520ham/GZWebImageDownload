//
//  GZWebImageCacheManager.h
//  GZWebImageDownload
//
//  Created by 张彦涛 on 2017/9/15.
//  Copyright © 2017年 张彦涛. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface GZWebImageCacheManager : NSObject
+ (instancetype)shareManager;
- (void)gz_cleanMemoryCache;
- (void)gz_cleanDiskCache;

- (void)gz_webImageSaveCachedWithImageUrl:(NSString *)vImageUrlStr andWithImage:(UIImage *)vImage andWithImageData:(NSData *)vImageData andCompletion:(void (^)(NSString *filePathStr))vCompletedBlock;

- (NSOperation *)gz_webImageSearchCachedOperationForKey:(NSString *)vImageUrlStr andComplete:(void (^)(UIImage *cacheImage))vCompletedBlock;


@end
