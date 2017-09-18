//
//  GZWebImageDownloadManager.m
//  GZWebImageDownload
//
//  Created by 张彦涛 on 2017/9/15.
//  Copyright © 2017年 张彦涛. All rights reserved.
//

#import "GZWebImageDownloadManager.h"
#import "GZWebImageCacheManager.h"
#import "GZWebImageDownloadOperation.h"
#import "GZWebImageConfig.h"


@interface GZWebImageCombinedOperation : NSObject <GZWebImageOperationProtocol>
@property (atomic,assign,getter=isCancelled) BOOL cancelled;
@property (nonatomic, strong) NSOperation *cacheOperation;
@property (nonatomic, strong) GZWebImageDownloadOperation *downloadOperation;
@end

@implementation GZWebImageCombinedOperation
- (void)dealloc{
    
}
- (void)cancel{
    self.cancelled = YES;
    if (self.cacheOperation) {
        [self.cacheOperation cancel];
        self.cacheOperation = nil;
    }
    if (self.downloadOperation) {
        [self.downloadOperation cancel];
        self.downloadOperation = nil;
    }
}
@end

@interface GZWebImageDownloadManager ()
@property (nonatomic,strong) NSOperationQueue *downloadQueue;
@property (nonatomic,strong) NSMutableDictionary *operationsDic;
@end
@implementation GZWebImageDownloadManager
- (void)dealloc{
    
}
- (instancetype)init{
    self = [super init];
    if (self) {
        self.operationsDic = [NSMutableDictionary dictionary];
        self.downloadQueue = [[NSOperationQueue alloc]init];
        self.downloadQueue.maxConcurrentOperationCount = kDownloadImageQueueMaxCount;
    }
    return self ;
}

#pragma mark -
#pragma mark interface -----------------------------------------
+ (instancetype)shareManager{
    static GZWebImageDownloadManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[GZWebImageDownloadManager alloc]init];
    });
    return manager;
}
- (void)gz_webImageDownloadOperationWithUrl:(NSURL *)vUrl andWithCompletedBlock:(GZImageDownloadCompletedBlock )vBlock{
    __block GZWebImageCombinedOperation *operation = [[GZWebImageCombinedOperation alloc]init];
    [self.operationsDic setObject:operation forKey:vUrl.absoluteString];
    if (NO ==operation.isCancelled ) {

        NSOperation *cacheOperation = [[GZWebImageCacheManager shareManager] gz_webImageSearchCachedOperationForKey:vUrl.absoluteString andComplete:^(UIImage *cacheImage) {
            if (cacheImage) {
                if (vBlock) {
                    vBlock(cacheImage,nil,vUrl);
                }
                [self.operationsDic removeObjectForKey:vUrl.absoluteString];
                return ;
            }
            if (NO == operation.isCancelled) {
                GZWebImageDownloadOperation *downloadOperation = [[GZWebImageDownloadOperation alloc]initWithImageUrl:vUrl andCompleteBlock:^(UIImage *downloadImage,NSError *error) {
                    if (downloadImage) {
                        if (vBlock) {
                            vBlock(downloadImage,nil,vUrl);
                        }
                        [self.operationsDic removeObjectForKey:vUrl.absoluteString];
                    }
                }];
                operation.downloadOperation = downloadOperation;
                [self.downloadQueue addOperation:downloadOperation];
            }
        }];
        operation.cacheOperation = cacheOperation;
    }
}


// 取消操作
- (void)gz_cancleOpeartionWithURL:(NSURL *)url
{
    GZWebImageCombinedOperation *operation = self.operationsDic[url.absoluteString];
    if (operation && [operation respondsToSelector:@selector(cancel)]) {
        [operation cancel];
        [self.operationsDic removeObjectForKey:url.absoluteString];
    }
}


@end
