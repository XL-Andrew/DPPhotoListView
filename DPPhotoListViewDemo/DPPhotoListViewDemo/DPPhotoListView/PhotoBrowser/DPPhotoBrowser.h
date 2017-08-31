//
//  DPPhotoBrowser.h
//  DPPhotoListViewDemo
//
//  Created by Andrew on 2017/8/23.
//  Copyright © 2017年 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    DPPhotoShadowDirectionVertical,
    DPPhotoShadowDirectionHorizontal
} DPPhotoShadowDirection;

@interface DPPhotoBrowser : UIViewController

/**
 图片数据源
 */
@property (nonatomic, strong) NSMutableArray *dataSource;

/**
 缩放图片位置
 */
@property (nonatomic, assign) CGRect zoomViewRect;

/**
 缩放动画(用于处理横屏滚动时,回缩动画错位)
 */
@property (nonatomic, assign) BOOL showZoomAnimation;

/**
 显示图片浏览器

 @param index 显示位置
 @param shadowDirection 回缩影子展示方向
 */
- (void)shwoPhotoBrowserAtIndex:(NSUInteger)index shadowDirection:(DPPhotoShadowDirection)shadowDirection;

@end
