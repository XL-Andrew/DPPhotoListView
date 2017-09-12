//
//  DPPhotoChooseToolBar.m
//  DPPhotoListViewDemo
//
//  Created by Andrew on 2017/9/5.
//  Copyright © 2017年 Andrew. All rights reserved.
//

#import "DPPhotoChooseToolBar.h"
#import "DPPhotoLibrary.h"

#define BLUE_COLOR RGB_COLOR(0, 165, 224, 1)
#define GRAY_COLOR RGB_COLOR(233, 235, 236, 1)

@implementation DPPhotoChooseToolBar
{
    UIButton *previewButton;
    UIButton *confirmButton;
    UIView *line;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = RGB_COLOR(248, 249, 250, 1.0);
        [self createSubviews];
    }
    return self;
}

- (void)createSubviews
{
    line = [[UIView alloc]init];
    line.backgroundColor = RGB_COLOR(207, 207, 207, 1.0f);
    [self addSubview:line];
    
    
    previewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    previewButton.hidden = YES;
    previewButton.enabled = NO;
    previewButton.backgroundColor = [UIColor clearColor];
    [previewButton setTitle:@"预览" forState:UIControlStateNormal];
    [previewButton setTitleColor:GRAY_COLOR forState:UIControlStateNormal];
    [previewButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [previewButton addTarget:self action:@selector(previewClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:previewButton];
    
    
    confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    confirmButton.backgroundColor = GRAY_COLOR;
    confirmButton.layer.cornerRadius = 2;
    confirmButton.enabled = NO;
    confirmButton.clipsToBounds = YES;
    [confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [confirmButton setTitle:@"确定" forState:UIControlStateNormal];
    [confirmButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [confirmButton addTarget:self action:@selector(confirmClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:confirmButton];
    
    
#if __has_include(<Masonry/Masonry.h>)
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(0);
        make.width.mas_equalTo(self.mas_width);
        make.height.mas_equalTo(0.5);
    }];
    
    [previewButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(0);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(self.mas_height);
    }];
    
    [confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_top).with.offset(8);
        make.bottom.mas_equalTo(self.mas_bottom).with.offset(- 8);
        make.right.mas_equalTo(self.mas_right).with.offset(- 10);
        make.width.mas_equalTo(60);
    }];
#else
   
#endif
    
}

- (void)layoutSubviews
{    
    [super layoutSubviews];
    line.frame = CGRectMake(0, 0, self.frame.size.width, 0.5);
    previewButton.frame = CGRectMake(0, 0, 60, self.frame.size.height);
    confirmButton.frame = CGRectMake(self.frame.size.width - 60 - 10, 8, 60, self.frame.size.height - 16);
}

- (void)previewClick
{
    if (self.PreviewButtonClick) {
        self.PreviewButtonClick();
    }
}

- (void)confirmClick
{
    if (self.ConfirmButtonClick) {
        self.ConfirmButtonClick();
    }
}

#pragma mark -  private

- (void)setToolBarStyle:(DPPhototToolBarStyle)toolBarStyle
{
    if (toolBarStyle == DPPhotoToolBarStyleLight) {
        self.backgroundColor = RGB_COLOR(248, 249, 250, 1.0);
        line.backgroundColor = RGB_COLOR(207, 207, 207, 1.0f);
    } else if (toolBarStyle == DPPhotoToolBarStyleDark) {
        self.backgroundColor = RGB_COLOR(26, 26, 26, 0.8);
        line.backgroundColor = RGB_COLOR(0, 0, 0, 1.0f);
    }
}

- (void)setConfirmNumber:(NSUInteger)confirmNumber
{
    if (confirmNumber == 0) {
        confirmButton.backgroundColor = GRAY_COLOR;
        confirmButton.enabled = NO;
        [confirmButton setTitle:@"确定" forState:UIControlStateNormal];
        
        previewButton.enabled = NO;
        [previewButton setTitleColor:GRAY_COLOR forState:UIControlStateNormal];
    } else {
        confirmButton.backgroundColor = BLUE_COLOR;
        confirmButton.enabled = YES;
        [confirmButton setTitle:[NSString stringWithFormat:@"确定(%ld)",confirmNumber] forState:UIControlStateNormal];
        
        previewButton.enabled = YES;
        [previewButton setTitleColor:BLUE_COLOR forState:UIControlStateNormal];
    }
}

- (void)setShowConfirmButton:(BOOL)showConfirmButton
{
    confirmButton.hidden = showConfirmButton;
}

- (void)setShowPreviewButton:(BOOL)showPreviewButton
{
    previewButton.hidden = !showPreviewButton;
}

@end
