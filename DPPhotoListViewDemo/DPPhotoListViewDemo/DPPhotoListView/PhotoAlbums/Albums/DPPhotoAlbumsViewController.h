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

- (void)chooseCompleteBackWithModel:(NSArray<DPPhotoBrowserModel *>*)models;

- (void)chooseCompleteBackWithImages:(NSArray<UIImage *> *)images;

- (void)chooseCompleteBackWithBase64String:(NSArray<NSString *> *)strings;

@end

@interface DPPhotoAlbumsViewController : UIViewController

@property (nonatomic, weak) id <DPPhotoAlbumsDelegate> delegate;


/**
 最大选择张数
 default is 9
 */
@property (nonatomic, assign) NSUInteger maxSelectCount;

@end
