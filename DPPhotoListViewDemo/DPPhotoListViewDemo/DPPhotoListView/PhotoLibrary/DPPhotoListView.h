//
//  DPPhotoListView.h
//  DPPhotoListViewDemo
//
//  Created by Andrew on 2017/8/22.
//  Copyright © 2017年 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DPPhotoModel;

typedef enum : NSUInteger {
    DPPhotoScrollDirectionVertical,
    DPPhotoScrollDirectionHorizontal
} DPPhotoScrollDirection;

@protocol DPPhotoListViewDelegate <NSObject>

@optional


/**
 当前上传的图片

 @param base64String 返回Base64编码，可直接上传服务器
 */
- (void)choosePhotoWithPhotoBase64String:(NSString *)base64String;


/**
 删除某个图片

 @param index 删除的位置
 */
- (void)deletedPhotoAtIndex:(NSUInteger)index;


/**
 删除某个图片

 @param index 删除位置
 @param dataSource 删除之前的数据源
 */
- (void)deletedPhotoAtIndex:(NSUInteger)index withCurrentDataSource:(NSMutableArray *)dataSource;

@end

@interface DPPhotoListView : UIView <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) id <DPPhotoListViewDelegate> delegate;


/**
 设置滚动方向
 
 default is DPPhotoScrollDirectionVertical
 */
@property (nonatomic, assign) DPPhotoScrollDirection photoScrollDirection;


/**
 显示添加图片按钮
 
 default is NO
 */
@property (nonatomic, assign) BOOL showAddImagesButton;


/**
 是否允许长按编辑图片
 
 default is NO
 */
@property (nonatomic, assign) BOOL allowLongPressEditPhoto;

/**
 初始化方法

 @param frame frame
 @param lineNumber 一行展示几个cell
 @param lineSpacing cell上下左右间距
 @param dataSource 图片数据源（可以是本地图片，可以是网络图片，也可是图片data）
 @return self
 */
- (instancetype)initWithFrame:(CGRect)frame numberOfCellInRow:(NSUInteger)lineNumber lineSpacing:(CGFloat)lineSpacing dataSource:(NSMutableArray *)dataSource;


/**
 自动判断当前编辑状态,如果是未编辑就开启编辑,如果已开启编辑就结束编辑
 */
- (void)autoEditPhoto;

/**
 开始编辑
 */
- (void)startEditPhoto;


/**
 结束编辑
 */
- (void)endEditPhoto;

@end
