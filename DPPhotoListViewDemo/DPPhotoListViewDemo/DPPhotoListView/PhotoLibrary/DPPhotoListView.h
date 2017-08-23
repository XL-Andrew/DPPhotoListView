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
 初始化方法

 @param frame frame
 @param lineNumber 一行展示几个cell
 @param lineSpacing cell上下左右间距
 @param dataSource 图片数据源
 @return self
 */
- (instancetype)initWithFrame:(CGRect)frame numberOfCellInRow:(NSUInteger)lineNumber lineSpacing:(CGFloat)lineSpacing dataSource:(NSMutableArray *)dataSource;

/**
 编辑删除
 */
- (void)editPhoto;

@end
