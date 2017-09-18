//
//  GZWebImageDownloadManager.h
//  GZWebImageDownload
//
//  Created by 张彦涛 on 2017/9/15.
//  Copyright © 2017年 张彦涛. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
//#import "GZWebImageConfig.h"
typedef  void  (^GZImageDownloadCompletedBlock) (UIImage *downloadImage,NSError *error ,NSURL *imageUrl);
@protocol GZWebImageOperationProtocol <NSObject>

@required
- (void)cancel;

@end

@interface GZWebImageDownloadManager : NSObject
+ (instancetype)shareManager;
- (void)gz_webImageDownloadOperationWithUrl:(NSURL *)vUrl andWithCompletedBlock:(GZImageDownloadCompletedBlock )vBlock;
// 取消操作
- (void)gz_cancleOpeartionWithURL:(NSURL *)url;
@end
