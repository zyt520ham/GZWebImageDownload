//
//  GZDisplayPhotoContainerView.m
//  GZWebImage
//
//  Created by 张彦涛 on 2017/9/18.
//  Copyright © 2017年 张彦涛. All rights reserved.
//

#import "GZDisplayPhotoContainerView.h"
#import "UIImageView+GZWebCache.h"

static const CGFloat kPhotoMargin = 4.0;
static const CGFloat kOnePhotoNormalMaxWidth = 180.0;


#define YQRealWidth(value) ((value)/375.0f*[UIScreen mainScreen].bounds.size.width)

@implementation UIView (GZViewAdd)
- (void)setX:(CGFloat)x
{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)x
{
    return self.frame.origin.x;
}

- (void)setY:(CGFloat)y
{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)y
{
    return self.frame.origin.y;
}

- (void)setWidth:(CGFloat)width
{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)width
{
    return  self.frame.size.width;
}

- (void)setHeight:(CGFloat)height
{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGFloat)height
{
    return  self.frame.size.height;
}
@end


@interface GZSizeCalculator : NSObject
+ (instancetype)shareCalculator;
@end

@implementation GZSizeCalculator
+ (instancetype)shareCalculator
{
    static GZSizeCalculator *cal = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cal = [[GZSizeCalculator alloc] init];
    });
    return cal;
}

// 计算整个视图的高度
- (CGFloat)calculatorTotalHeightWithPhotoArray:(NSArray *)photoArray width:(CGFloat)width
{
    CGFloat height = 0;
    
    if (photoArray.count == 1) {
        GZPhoto *photo = photoArray[0];
        height = [self calculatorHeightWithOnePhoto:photo.bmiddle width:width] + kPhotoMargin * 2;
    } else {
        CGFloat photoWidth = (width - 4 *kPhotoMargin)/3;
        height = ((photoArray.count + 2)/3) * (kPhotoMargin + photoWidth) + kPhotoMargin;
    }
    return height;
}

// 通过给的视图的宽度来确定照片的宽度（用于单张照片）
- (CGFloat)calculatorPhotoWidthWithViewWidth:(CGFloat)width
{
    CGFloat photoWidth = 0;
    if (YQRealWidth(kOnePhotoNormalMaxWidth) < width) { // 如果width设置的比180还大 就用180
        photoWidth = YQRealWidth(kOnePhotoNormalMaxWidth);
    } else { // 如果用的比180小， 用刚设置的width
        photoWidth = width;
    }
    return photoWidth;
}

// 计算一张照片的高度
- (CGFloat)calculatorHeightWithOnePhoto:(GZPhotoMetaData *)metaData width:(CGFloat)width
{
    CGFloat photoWidth = [self calculatorPhotoWidthWithViewWidth:width];
    CGFloat photoHeight = 0;
    
    if (metaData.photoType != GZPhotoType_Long) { // 如果不是长图
        photoHeight = photoWidth * metaData.scale;
    }else {
        photoHeight = photoWidth * 1.3;
    }
    return photoHeight;
}

@end
@implementation GZPhotoMetaData
- (instancetype)initWithPicDic:(NSDictionary *)picDic
{
    self = [super init];
    self.url = picDic[@"url"];
    self.height = [picDic[@"height"] intValue];
    self.width = [picDic[@"width"] intValue];
    self.scale = (CGFloat)self.height / self.width;
    if (self.scale > 2) {
        self.photoType = GZPhotoType_Long; // 长图
    } else if (self.scale < 1) {
        self.photoType = GZPhotoType_Horizontal;
    }
    return self;
}
@end

@implementation GZPhoto
@end

@interface GZDisplayPhotoContainerView ()
@property (nonatomic, strong) NSMutableArray *imageViewArray;
@property (nonatomic, strong) NSMutableArray *imageArray;
@end

@implementation GZDisplayPhotoContainerView
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupView];
    }
    return self;
}

- (void)setupView
{
    CGFloat photoWidth = (self.width - 4 *kPhotoMargin)/3;
    CGFloat photoHeight = photoWidth;
    
    for (int i = 0; i < 9; i++) {
        CGFloat x = kPhotoMargin + (i%3 * (photoWidth + kPhotoMargin));
        CGFloat y = kPhotoMargin + (i/3 * (photoWidth + kPhotoMargin));
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectMake(x, y, photoWidth, photoHeight);
        imageView.hidden = YES;
        [self addSubview:imageView];
        [self.imageViewArray addObject:imageView];
    }
}
- (void)setPhotoArray:(NSArray *)photoArray
{
    _photoArray = photoArray;
    
    NSUInteger count = photoArray.count;
    
    if (!photoArray || count == 0) return;
    
    for (UIImageView *iv in self.imageViewArray) {
        iv.hidden = YES;
    }
    
    if (photoArray.count == 1) { // 一张的时候就放大版排布
        
        GZPhoto *photo = self.photoArray[0];
        
        UIImageView *imageView = self.imageViewArray[0];
        imageView.frame = CGRectMake(kPhotoMargin, kPhotoMargin, [[GZSizeCalculator shareCalculator] calculatorPhotoWidthWithViewWidth:self.width], [[GZSizeCalculator shareCalculator] calculatorHeightWithOnePhoto:photo.bmiddle width:self.width]);
        
        [self setImageView:imageView withPhoto:photo];
        
    } else if (photoArray.count == 4) {
        
        CGFloat photoWidth = (self.width - 4 *kPhotoMargin)/3;
        CGFloat photoHeight = photoWidth;
        
        for (int i = 0; i < 4; i++) {
            
            CGFloat x = (i%2) * (photoWidth + kPhotoMargin) + kPhotoMargin;
            CGFloat y = (i/2) * (photoHeight + kPhotoMargin) + kPhotoMargin;
            
            UIImageView *imageView = self.imageViewArray[i];
            imageView.frame = CGRectMake(x, y, photoWidth, photoHeight);
            
            GZPhoto *photo = self.photoArray[i];
            [self setImageView:imageView withPhoto:photo];
        }
    } else {
        CGFloat photoWidth = (self.width - 4 *kPhotoMargin)/3;
        CGFloat photoHeight = photoWidth;
        
        for (int i = 0; i <photoArray.count ; i++) {
            
            CGFloat x = (i%3) * (photoWidth + kPhotoMargin) + kPhotoMargin;
            CGFloat y = (i/3) * (photoHeight + kPhotoMargin) + kPhotoMargin;
            
            UIImageView *imageView = self.imageViewArray[i];
            imageView.frame = CGRectMake(x, y, photoWidth, photoHeight);
            
            GZPhoto *photo = self.photoArray[i];
            [self setImageView:imageView withPhoto:photo];
        }
    }
}

- (void)setImageView:(UIImageView *)imageView withPhoto:(GZPhoto *)photo
{
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    imageView.hidden = NO;
    [imageView gz_setImageWithURLString:photo.bmiddle.url placeholderImage:[UIImage imageNamed:@"placeholder"]];
   
}

+ (CGFloat)gz_heightForWidth:(CGFloat)width photoArray:(NSArray *)photoArray
{
    CGFloat height = [[GZSizeCalculator shareCalculator] calculatorTotalHeightWithPhotoArray:photoArray width:width];
    return height;
}


#pragma mark - lazy
- (NSMutableArray *)imageViewArray
{
    if (_imageViewArray == nil) {
        _imageViewArray = [NSMutableArray array];
    }
    return _imageViewArray;
}

- (NSMutableArray *)imageArray
{
    if (_imageArray == nil) {
        _imageArray = [NSMutableArray array];
    }
    return _imageArray;
}
@end
