//
//  DPPhotoAlbumsViewController.h
//  DPPhotoListViewDemo
//
//  Created by Andrew on 2017/9/4.
//  Copyright © 2017年 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DPPhotoBrowserEditor.h"

@class DPPhotoBrowserModel;

@protocol DPPhotoAlbumsDelegate <NSObject>

@optional

/**
 返回选择图片组

 @param models DPPhotoBrowserModel Array
 */
- (void)chooseCompleteBackWithModel:(NSArray<DPPhotoBrowserModel *>*)models;

/**
 返回选择图片组

 @param images UIImage Array
 */
- (void)chooseCompleteBackWithImages:(NSArray<UIImage *> *)images;

/**
 返回选择图片组

 @param strings Base64String Array
 */
- (void)chooseCompleteBackWithBase64String:(NSArray<NSString *> *)strings;

@end

@interface DPPhotoAlbumsViewController : UIViewController


@property (nonatomic, weak) id <DPPhotoAlbumsDelegate> delegate;

/**
 最大选择张数
 default is 9
 */
@property (nonatomic, assign) NSUInteger maxSelectCount;

/**
 弹出相册浏览器
 */
- (void)showPhotoAlbumsController;

@end
