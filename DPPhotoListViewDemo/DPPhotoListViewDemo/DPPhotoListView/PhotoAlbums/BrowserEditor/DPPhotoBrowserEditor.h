//
//  DPPhotoBorwserEditor.h
//  DPPhotoListViewDemo
//
//  Created by Andrew on 2017/9/6.
//  Copyright © 2017年 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "DPPhotoBrowserModel.h"

typedef enum : NSUInteger {
    DPBrowseImageTypeNormal,    //默认查看全部
    DPBrowseImageTypePreview,   //预览选中图片模式
} DPBrowseImageType;

@interface DPPhotoBrowserEditor : UIViewController
/**
 图片数据源
 */
@property (nonatomic, strong) NSMutableArray <DPPhotoBrowserModel *>*browserDataSource;

@property (nonatomic, assign) NSUInteger showIndex;

/**
 预览全部图片 || 选中图片
 */
@property (nonatomic, assign) DPBrowseImageType browseImageType;

/**
 最大选择张数
 */
@property (nonatomic, assign) NSUInteger maxSelectCount;

@end
