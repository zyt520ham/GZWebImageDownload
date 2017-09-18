//
//  GZWebImageCacheManager.m
//  GZWebImageDownload
//
//  Created by 张彦涛 on 2017/9/15.
//  Copyright © 2017年 张彦涛. All rights reserved.
//

#import "GZWebImageCacheManager.h"
#import "UIImage+GZDecode.h"
#import "GZWebImageConfig.h"
#import "GZWebImageLoger.h"
@interface GZUtility : NSObject

@end

@implementation GZUtility
//判断文件夹目录是否存在
+ (BOOL)gz_isExistDirectoryForPath:(NSString *)strDirPath {
    
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    BOOL bDir = NO;
    BOOL bExist = [fileMgr fileExistsAtPath:strDirPath isDirectory:&bDir];
    if (bDir && bExist) {
        return YES;
    }
    return NO;
}

//创建文件夹目录
+ (BOOL)gz_createDirectoryForPath:(NSString *)strDirPath {
    
    if (nil == strDirPath) {
        return NO;
    }
    if ([GZUtility gz_isExistDirectoryForPath:strDirPath]) {
        return YES;
    }
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    BOOL bResult = [fileMgr createDirectoryAtPath:strDirPath withIntermediateDirectories:YES attributes:nil error:nil];
    NSAssert(bResult, @"缓存路径创建失败");
    return bResult;
}


@end

@interface GZWebImageCacheManager(){
    id notify_memoryWarning;
    id notify_enterBackground;
}
@property (nonatomic, strong) NSCache *imageCache;
@property (nonatomic, strong) dispatch_queue_t ioQueue;
@end

@implementation GZWebImageCacheManager
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:notify_memoryWarning];
    [[NSNotificationCenter defaultCenter] removeObserver:notify_enterBackground];
}
- (instancetype)init{
    self = [super init];
    if (self) {
        self.imageCache = [[NSCache alloc] init];
        self.imageCache.totalCostLimit = kCacheTotalCostLimit;
        self.imageCache.evictsObjectsWithDiscardedContent = YES;
        self.ioQueue = dispatch_queue_create("com.elex-tech.GZWebImage.GZImageCache", DISPATCH_QUEUE_SERIAL);
        [GZUtility gz_createDirectoryForPath:[self gz_getCacheDirPath]];
        GZWebImageLog(@"缓存图片路径 :\n%@",[self gz_getCacheDirPath]);
        
    }
    return self ;
}

- (NSString *)gz_getCacheDirPath{
    NSString *cacheDirPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] ;
    cacheDirPath = [cacheDirPath stringByAppendingPathComponent:kCachePath];
    return cacheDirPath;
}
// 获得图片保存的路径
- (NSString *)gz_getFilePathWithImageURLStr:(NSString *)vUrlStr
{
    NSString *filePath = [[self gz_getCacheDirPath] stringByAppendingPathComponent:[vUrlStr lastPathComponent]];
    return filePath;
}

- (UIImage *)gz_imageFromDiskWithImageKeyPath:(NSString *)vImageKeyPathStr{
    NSData *data = [NSData dataWithContentsOfFile:vImageKeyPathStr];
    if (data) {
        UIImage *image = [UIImage imageWithData:data];
        image = [UIImage gz_imageDecodeWithImage:image];
        return image;
    } else {
        return nil;
    }
}
- (UIImage *)gz_imageFromMemoryCacheWithImageUrl:(NSString *)vImageUrlString{
    if (vImageUrlString == nil || vImageUrlString.length == 0 ) {
        NSAssert(NO, @"获取内存图片的url地址不合法");
    }
    UIImage * returnImage = nil;
        returnImage = [self.imageCache objectForKey:vImageUrlString];
    return returnImage;
}

- (void)gz_addNotify{
    __weak typeof(self) wself = self ;
      notify_memoryWarning = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
          [wself gz_cleanMemoryCache];
    }];
      notify_enterBackground = [[NSNotificationCenter defaultCenter ] addObserverForName:UIApplicationDidEnterBackgroundNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
          [wself gz_cleanMemoryCache];
    }];
}
#pragma mark -
#pragma mark interface -----------------------------------------
+ (instancetype)shareManager{
    static GZWebImageCacheManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[GZWebImageCacheManager alloc] init];
    });
    return manager;
}
- (void)gz_cleanMemoryCache{
    dispatch_async(dispatch_get_main_queue(), ^{
         [self.imageCache removeAllObjects];
    });
    
}
- (void)gz_cleanDiskCache{
    GZWebImageLog(@"清除磁盘缓存");
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:[self gz_getCacheDirPath] error:nil];
    [GZUtility gz_createDirectoryForPath:[self gz_getCacheDirPath]];
}
- (void)gz_webImageSaveCachedWithImageUrl:(NSString *)vImageUrlStr andWithImage:(UIImage *)vImage andWithImageData:(NSData *)vImageData andCompletion:(void (^)(NSString *filePathStr))vCompletedBlock {
    if (vImageUrlStr == nil ) {
        NSLog(@"error:vImageUrlStr 为 nil");
        if (vCompletedBlock) {
            vCompletedBlock(nil);
        }
    }
    if (vImage == nil || vImageData == nil) {
        NSLog(@"error:image 为nil  或者 imagedata 为 nil");
        if (vCompletedBlock) {
            vCompletedBlock(nil);
        }
    }
    // 缓存
    [self.imageCache setObject:vImage forKey:vImageUrlStr];
    NSString *filePath = [self gz_getFilePathWithImageURLStr:vImageUrlStr];
    dispatch_async(self.ioQueue, ^{
        @autoreleasepool {
            if (nil == [self gz_imageFromDiskWithImageKeyPath:filePath]) {
                [vImageData writeToFile:filePath atomically:YES];
            }
        }
        if (vCompletedBlock) {
            vCompletedBlock(filePath);
        }
    });
}

- (NSOperation *)gz_webImageSearchCachedOperationForKey:(NSString *)vImageUrlStr andComplete:(void (^)(UIImage *cacheImage))vCompletedBlock{
    if (vImageUrlStr == nil || vImageUrlStr.length == 0) {
        NSLog(@"imageUrl不合法");
        if (vCompletedBlock) {
            vCompletedBlock(nil);
        }
        return nil;
    }
    //缓存获取
    UIImage *image = [self gz_imageFromMemoryCacheWithImageUrl:vImageUrlStr];
    if (image) {
        if (vCompletedBlock) {
            vCompletedBlock(image);
        }
        return nil;
    }
    //内存没有，异步去磁盘读取
    
    NSOperation *operation = [[NSOperation alloc]init];
    dispatch_async(self.ioQueue, ^{
        if (operation.isCancelled) {
            return ;
        }
        @autoreleasepool {
            UIImage *diskImage = [self gz_imageFromDiskWithImageKeyPath:[self gz_getFilePathWithImageURLStr:vImageUrlStr]];
            if (diskImage) {
                @synchronized (self.imageCache) {
                    [self.imageCache setObject:diskImage forKey:vImageUrlStr];
                }
            }
            if (vCompletedBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    vCompletedBlock(diskImage);
                });
            }
        }
    });
    return operation;
}

@end
