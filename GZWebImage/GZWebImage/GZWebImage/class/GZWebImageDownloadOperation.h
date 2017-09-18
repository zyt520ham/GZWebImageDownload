//
//  GZWebImageDownloadOperation.h
//  GZWebImageDownload
//
//  Created by 张彦涛 on 2017/9/15.
//  Copyright © 2017年 张彦涛. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface GZWebImageDownloadOperation : NSOperation
- (instancetype)initWithImageUrl:(NSURL *)vUrl andCompleteBlock:(void (^)(UIImage *downloadImage ,NSError *error))vCompleteBlock;
@end
