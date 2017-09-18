//
//  ViewController.m
//  GZWebImage
//
//  Created by 张彦涛 on 2017/9/15.
//  Copyright © 2017年 张彦涛. All rights reserved.
//

#import "ViewController.h"
#import "GZWebImage.h"
#import "GZImageListVC.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    NSString *imageUrl1 = @"http://img.pcgames.com.cn/images/upload/upc/tx/gamephotolib/1509/22/c1/13035285_1442915070632.jpg";
//    NSString *imageUrl2 = @"http://img.pcgames.com.cn/images/upload/upc/tx/gamephotolib/1509/22/c1/13035285_1442915010466.jpg";
//    UIImageView *imageView = [[UIImageView alloc]init];
//     UIImageView *imageView1 = [[UIImageView alloc]init];
//    [imageView gz_setImageWithURLString:imageUrl1];
//    [imageView1 gz_setImageWithURLString:imageUrl2];
    // Do any additional setup after loading the view, typically from a nib.
}


- (IBAction)openDownloadImagelistVC:(id)sender {
    GZImageListVC *imageListVC = [[GZImageListVC alloc]init];
    [self.navigationController pushViewController:imageListVC animated:YES];
}


- (IBAction)cleanMemoryCache:(id)sender {
    [[GZWebImageCacheManager shareManager]gz_cleanMemoryCache];
}

- (IBAction)cleanDiskCache:(id)sender {
    [[GZWebImageCacheManager shareManager] gz_cleanDiskCache];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
