//
//  DPPhotoChooseToolBar.h
//  DPPhotoListViewDemo
//
//  Created by Andrew on 2017/9/5.
//  Copyright © 2017年 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    DPPhotoToolBarStyleLight,
    DPPhotoToolBarStyleDark
} DPPhototToolBarStyle;

@interface DPPhotoChooseToolBar : UIView

/**
 确认点击
 */
@property (nonatomic, copy) void (^ConfirmButtonClick)();

/**
 预览点击
 */
@property (nonatomic, copy) void (^PreviewButtonClick)();

/**
 ToolBar状态
 */
@property (nonatomic, assign) DPPhototToolBarStyle toolBarStyle;

/**
 选择图片数量
 */
@property (nonatomic, assign) NSUInteger confirmNumber;

/**
 是否显示确认按钮 
 default is YES
 */
@property (nonatomic, assign) BOOL showConfirmButton;

/**
 是否显示预览按钮
 default is NO
 */
@property (nonatomic, assign) BOOL showPreviewButton;

@end
