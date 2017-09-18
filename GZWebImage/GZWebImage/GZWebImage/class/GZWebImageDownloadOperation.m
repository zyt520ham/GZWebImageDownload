//
//  GZWebImageDownloadOperation.m
//  GZWebImageDownload
//
//  Created by 张彦涛 on 2017/9/15.
//  Copyright © 2017年 张彦涛. All rights reserved.
//

#import "GZWebImageDownloadOperation.h"
#import "GZWebImageCacheManager.h"
#import "UIImage+GZDecode.h"
#import "GZWebImageLoger.h"
typedef void(^DownloadCompleteBlock)(UIImage *image,NSError *error);
@interface GZWebImageDownloadOperation ()
@property (nonatomic,copy)NSURL *url;
@property (nonatomic,copy) DownloadCompleteBlock downloadCompleteBlock;
@property (nonatomic,copy) NSURLSessionTask *dataTask;
@end
@implementation GZWebImageDownloadOperation
- (void)dealloc{
    
}

- (instancetype)initWithImageUrl:(NSURL *)vUrl andCompleteBlock:(void (^)(UIImage *downloadImage ,NSError *error))vCompleteBlock{
    if (self = [super init]) {
        self.url = vUrl;
        if (vCompleteBlock) {
            self.downloadCompleteBlock = vCompleteBlock;
        }
    }
    return self;
}
- (void)main{
    if (self.url == nil) {
        return ;
    }
    if (self.isCancelled) {
        return ;
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:self.url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:
                                      ^(NSData *data, NSURLResponse *response, NSError *error) {
                                          if (error == nil) {
                                              UIImage *image = [UIImage imageWithData:data];
                                              image = [UIImage gz_imageDecodeWithImage:image];
                                              // 保存下来
                                              [[GZWebImageCacheManager shareManager]gz_webImageSaveCachedWithImageUrl:self.url.absoluteString andWithImage:image andWithImageData:data andCompletion:^(NSString *filePathStr) {
                                                  GZWebImageLog(@"文件路径:\n%@",filePathStr)
                                              }];
                                              
                                              if (self.isCancelled) {
                                                  return;
                                              }
                                              [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                                  self.downloadCompleteBlock(image,nil);
                                              }];
                                              
                                          }else{
                                              GZWebImageLog(@"下载任务失败 error :%@",error);
                                              [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                                  self.downloadCompleteBlock(nil,error);
                                              }];
                                          }
                                      }];
    [dataTask resume];
    _dataTask = dataTask;
}
- (void)cancel{
    GZWebImageLog(@"downloadImage cannel url:(%@)",_url.absoluteString);
    [_dataTask cancel];
}

@end
