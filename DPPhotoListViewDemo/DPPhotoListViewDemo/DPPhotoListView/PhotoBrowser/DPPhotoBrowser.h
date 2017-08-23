//
//  DPPhotoBrowser.h
//  DPPhotoListViewDemo
//
//  Created by Andrew on 2017/8/23.
//  Copyright © 2017年 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

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
 显示图片浏览器

 @param index 显示位置
 */
- (void)shwoPhotoBrowserAtIndex:(NSUInteger)index;

@end
