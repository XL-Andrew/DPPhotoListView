//
//  DPPhotoChooseViewCell.m
//  DPPhotoListViewDemo
//
//  Created by Andrew on 2017/9/5.
//  Copyright © 2017年 Andrew. All rights reserved.
//

#import "DPPhotoChooseViewCell.h"
#import "DPPhotoLibrary.h"

@implementation DPPhotoChooseViewCell
{
    UIImageView *thumbnailImageView;
    UIButton *selectButton;
    UIView *maskView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self createSubviews];
    }
    return self;
}

- (void)createSubviews
{
    thumbnailImageView = [[UIImageView alloc]init];
    thumbnailImageView.contentMode = UIViewContentModeScaleAspectFill;
    thumbnailImageView.clipsToBounds = YES;
    [self addSubview:thumbnailImageView];
    
    maskView = [[UIView alloc]init];
    maskView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    maskView.userInteractionEnabled = YES;
    maskView.hidden = YES;
    [self addSubview:maskView];
    
    selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    selectButton.backgroundColor = [UIColor clearColor];
    [selectButton setImage:[UIImage imageNamed:@"DPPhoto_choose_unSelect"] forState:UIControlStateNormal];
    [selectButton setImage:[UIImage imageNamed:@"DPPhoto_choose_select"] forState:UIControlStateSelected];
    [selectButton setImageEdgeInsets:UIEdgeInsetsMake(4, 8, 8, 4)];
    [selectButton addTarget:self action:@selector(btnSelectClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:selectButton];
    
#if __has_include(<Masonry/Masonry.h>)
    [thumbnailImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
    [maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
    [selectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.mas_equalTo(0);
        make.width.height.mas_equalTo(self.mas_width).multipliedBy(0.3);
    }];
#else
    selectButton.frame = CGRectMake(self.bounds.size.width / 3 * 2, 0, self.bounds.size.width / 3, self.bounds.size.width / 3);
    maskView.frame = self.frame;
    thumbnailImageView.frame = self.frame;
#endif
    
}

- (void)setThumbnailPhoto:(PHAsset *)thumbnailPhoto
{
    [DPPhotoUtils requestImageForAsset:thumbnailPhoto size:CGSizeMake(self.bounds.size.width * 1.7, self.bounds.size.width * 1.7) resizeMode:PHImageRequestOptionsResizeModeFast completion:^(UIImage *image, NSDictionary *info) {
       dispatch_async(dispatch_get_main_queue(), ^{
           thumbnailImageView.image = image;
       });
    }];
}

- (void)setIsButtonSelected:(BOOL)isButtonSelected
{
    if (isButtonSelected) {
        maskView.hidden = NO;
    } else {
        maskView.hidden = YES;
    }
    selectButton.selected = isButtonSelected;
}

#pragma mark -  点击事件

- (void)btnSelectClick:(UIButton *)sender
{
    if (self.selectedBlock) {
        if (self.selectedBlock(selectButton.selected)) {
            selectButton.selected = !selectButton.selected;
            if (selectButton.selected) {
                [selectButton.imageView.layer addAnimation:[DPPhotoUtils getButtonStatusChangedAnimation] forKey:nil];
                maskView.hidden = NO;
            } else {
                maskView.hidden = YES;
            }
        }
    }
}



@end
