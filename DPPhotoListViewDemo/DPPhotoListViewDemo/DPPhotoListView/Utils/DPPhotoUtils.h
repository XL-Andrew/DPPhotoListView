//
//  DPPhotoUtils.h
//  DPPhotoListViewDemo
//
//  Created by Andrew on 2017/8/23.
//  Copyright © 2017年 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "DPPhotoBrowserModel.h"

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

/**
 根据PHAsset获取图片data
 
 @param asset PHAsset
 @param completion 图片data
 */
+ (void)requestOriginalImageDataForAsset:(PHAsset *)asset completion:(void (^)(NSData *data, NSDictionary *info))completion;


/**
 根据PHAsset获取对应图片
 
 @param asset PHAsset
 @param size 缩略图大小
 @param resizeMode 质量
 @param completion block
 */
+ (void)requestImageForAsset:(PHAsset *)asset size:(CGSize)size resizeMode:(PHImageRequestOptionsResizeMode)resizeMode completion:(void (^)(UIImage *image, NSDictionary *info))completion;


/**
 根据PHFetchResult获取图片合集
 
 @param fetchResult PHFetchResult
 @param ascending 排序方式
 @return 图片合集
 */
+ (NSArray<DPPhotoBrowserModel *> *)getAssetsInFetchResult:(PHFetchResult *)fetchResult ascending:(BOOL)ascending;

/**
 获取相机交卷所有照片
 
 @return PHAsset NSArray
 */
+ (NSArray<DPPhotoBrowserModel *> *)getCameraRollAlbum;

/**
 选择按钮动画
 
 @return CAKeyframeAnimation
 */
+ (CAKeyframeAnimation *)getButtonStatusChangedAnimation;

@end
