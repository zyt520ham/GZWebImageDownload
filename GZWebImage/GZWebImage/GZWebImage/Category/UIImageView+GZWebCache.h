//
//  UIImageView+GZWebCache.h
//  GZWebImageDownload
//
//  Created by 张彦涛 on 2017/9/15.
//  Copyright © 2017年 张彦涛. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GZWebImageDownloadManager.h"
@interface UIImageView (GZWebCache)

/**
 通过url设置图片（来源：网络或本地）
 
 @param url 图片的url
 */
- (void)gz_setImageWithURL:(NSURL *)url;
- (void)gz_setImageWithURLString:(NSString *)vUrlString;
/**
 通过url设置图片（来源：网络或本地）
 
 @param url 图片的url
 @param placeholderImage 占位图片
 */
- (void)gz_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage;
- (void)gz_setImageWithURLString:(NSString *)vUrlString placeholderImage:(UIImage *)placeholderImage;
/**
 通过url设置图片（来源：网络或本地）
 
 @param url 图片的url
 @param placeholderImage 占位图片
 @param completedBlock 完成回调
 */
- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage andCompletedBlock:(GZImageDownloadCompletedBlock)completedBlock;
- (void)setImageWithURLString:(NSString *)vUrlString placeholderImage:(UIImage *)placeholderImage andCompletedBlock:(GZImageDownloadCompletedBlock)completedBlock;
@end
