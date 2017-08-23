//
//  DPPhotoUtils.h
//  DPPhotoListViewDemo
//
//  Created by Andrew on 2017/8/23.
//  Copyright © 2017年 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DPPhotoUtils : NSObject


/**
 上传图片格式化以及转换Base64格式

 @param image 相册选择图片
 @return 格式化后的图片Base64字符串
 */
+ (NSString *)processingImages:(UIImage *)image;


/**
 当前控制器
 
 @return UIViewController
 */
+ (UIViewController *)currentViewController;

@end
