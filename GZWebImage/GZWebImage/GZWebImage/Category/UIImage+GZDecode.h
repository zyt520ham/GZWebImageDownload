//
//  UIImage+GZDecode.h
//  GZWebImageDownload
//
//  Created by 张彦涛 on 2017/9/15.
//  Copyright © 2017年 张彦涛. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (GZDecode)
/**
 编码图片
 
 @param image 需要编码的图片
 */
+ (UIImage *)gz_imageDecodeWithImage:(UIImage *)image;
@end
