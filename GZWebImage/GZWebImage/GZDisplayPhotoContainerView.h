//
//  GZDisplayPhotoContainerView.h
//  GZWebImage
//
//  Created by 张彦涛 on 2017/9/18.
//  Copyright © 2017年 张彦涛. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, YQPhotoType) {
    GZPhotoType_None = 0,    ///< 正常图片
    GZPhotoType_Horizontal,  ///< 横图
    GZPhotoType_Long,        ///< 长图
};

@interface GZPhotoMetaData : NSObject ///<YQPhoto的数据
@property (nonatomic, copy) NSString *url;
@property (nonatomic, assign) int width;
@property (nonatomic, assign) int height;
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, assign) YQPhotoType photoType;
- (instancetype)initWithPicDic:(NSDictionary *)picDic;
@end

@interface GZPhoto : NSObject   ///<YQPhoto
@property (nonatomic, strong)GZPhotoMetaData *bmiddle;
@property (nonatomic, strong)GZPhotoMetaData *original;
@property (nonatomic, copy) NSString *picID;
@end


@interface GZDisplayPhotoContainerView : UIView
@property (nonatomic, strong) NSArray *photoArray;     ///<YQPhoto类型的数组

/**
 类方法，用来计算该视图的高度 和photoArray的个数 有关
 
 @param width           width.
 @param photoArray      图片数组
 */
+ (CGFloat)gz_heightForWidth:(CGFloat)width photoArray:(NSArray *)photoArray;
@end
