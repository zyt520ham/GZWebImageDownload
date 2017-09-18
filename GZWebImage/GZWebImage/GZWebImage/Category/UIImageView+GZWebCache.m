//
//  UIImageView+GZWebCache.m
//  GZWebImageDownload
//
//  Created by 张彦涛 on 2017/9/15.
//  Copyright © 2017年 张彦涛. All rights reserved.
//

#import "UIImageView+GZWebCache.h"
#import <objc/runtime.h>
#import "GZWebImageDownloadManager.h"
#import "GZWebImageConfig.h"
#import "GZWebImageLoger.h"
static char urlKey;

@implementation UIImageView (GZWebCache)
// 获取urlkey
- (NSString *)getURLKey
{
    return objc_getAssociatedObject(self, &urlKey);
}

// 设置urlkey
- (void)setURLKey:(NSString *)urlStr
{
    objc_setAssociatedObject(self, &urlKey, urlStr, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (void)removeURLKey{
    objc_removeAssociatedObjects(self);
}

- (void)gz_baseDownImageWithUrl:(NSURL *)vUrl andPlaceholderImage:(UIImage *)vPlaceholderImage andWithCompletedBlock:(GZImageDownloadCompletedBlock)vBlock{
    GZWebImageLog(@"图片下载链接 \n%@",vUrl);
    if (vPlaceholderImage ) {
        self.image = vPlaceholderImage;
    }
    NSString *lastKey = [self getURLKey];
    if (lastKey && lastKey.length > 0) {
        [[GZWebImageDownloadManager shareManager] gz_cancleOpeartionWithURL:[NSURL URLWithString:lastKey]];
    }
    [self setURLKey:vUrl.absoluteString];
    __weak typeof(self ) wself = self;
    [[GZWebImageDownloadManager shareManager] gz_webImageDownloadOperationWithUrl:vUrl andWithCompletedBlock:^(UIImage *downloadImage, NSError *error, NSURL *imageUrl) {
        if (error) {
            if (vBlock) {
                vBlock(nil,error,imageUrl);
            }
        }else{
            if (downloadImage) {
                __strong typeof(wself)strongSelf = wself;
                strongSelf.image = downloadImage;
                [strongSelf removeURLKey];
                if (vBlock) {
                    vBlock(downloadImage,nil,imageUrl);
                }
                return ;
            }
            GZWebImageLog(@"返回的图片为空 ");
            NSError *error =[NSError errorWithDomain:@"没有拿到图片" code:0 userInfo:nil];
            if (vBlock) {
                vBlock(nil,error,imageUrl);
            }
        }
    }];
    
}

#pragma mark -
#pragma mark interface -----------------------------------------

- (void)gz_setImageWithURLString:(NSString *)vUrlString{
    [self setImageWithURLString:vUrlString placeholderImage:nil andCompletedBlock:nil];
}
- (void)gz_setImageWithURLString:(NSString *)vUrlString placeholderImage:(UIImage *)placeholderImage{
     [self setImageWithURLString:vUrlString placeholderImage:placeholderImage andCompletedBlock:nil];
}
- (void)setImageWithURLString:(NSString *)vUrlString placeholderImage:(UIImage *)placeholderImage andCompletedBlock:(GZImageDownloadCompletedBlock)completedBlock{
    if (vUrlString == nil || vUrlString.length <1) {
        NSString *errorString = [NSString stringWithFormat:@"图片下载地址url不合法 url:%@",vUrlString];
        GZWebImageLog(@"%@",errorString);
        NSAssert(NO, errorString);
        if (completedBlock) {
            NSError *error = [NSError errorWithDomain:errorString code:0 userInfo:nil];
            completedBlock(nil,error,nil);
        }
        return ;
    }
    NSURL *imageUrl = [NSURL URLWithString:vUrlString];
    [self setImageWithURL:imageUrl placeholderImage:placeholderImage andCompletedBlock:completedBlock];
}



- (void)gz_setImageWithURL:(NSURL *)url{
    [self setImageWithURL:url placeholderImage:nil andCompletedBlock:nil];
}

- (void)gz_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage{
    [self setImageWithURL:url placeholderImage:placeholderImage andCompletedBlock:nil];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage andCompletedBlock:(GZImageDownloadCompletedBlock)completedBlock{
    if (url == nil || NO == [url isKindOfClass:[NSURL class]]) {
        NSString *errorString = [NSString stringWithFormat:@"图片下载地址url不合法 url:%@",url];
        GZWebImageLog(@"%@",errorString);
        NSAssert(NO, errorString);
        if (completedBlock) {
            NSError *error = [NSError errorWithDomain:errorString code:0 userInfo:nil];
            completedBlock(nil,error,url);
        }
        return;
    }
    [self gz_baseDownImageWithUrl:url andPlaceholderImage:placeholderImage andWithCompletedBlock:completedBlock];
    
}

@end
