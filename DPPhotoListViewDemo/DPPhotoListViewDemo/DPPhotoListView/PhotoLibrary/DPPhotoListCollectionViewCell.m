//
//  DPPhotoListCollectionViewCell.m
//  DPPhotoListViewDemo
//
//  Created by Andrew on 2017/8/22.
//  Copyright © 2017年 Andrew. All rights reserved.
//

#import "DPPhotoListCollectionViewCell.h"
#import "DPPhotoLibrary.h"

@implementation DPPhotoListCollectionViewCell
{
    UIButton *deleteButton;
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
    self.photoImageView = [[UIImageView alloc]init];
    self.photoImageView.backgroundColor = [UIColor whiteColor];
    self.photoImageView.layer.cornerRadius = 4;
    self.photoImageView.clipsToBounds = YES;
    self.photoImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:self.photoImageView];
    
    [self.photoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(0);
        make.width.mas_equalTo(self.mas_width);
        make.height.mas_equalTo(self.mas_height);
    }];
    
    deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteButton.backgroundColor = [UIColor clearColor];
    deleteButton.enabled = NO;
    deleteButton.hidden = YES;
    [deleteButton setImage:[UIImage imageNamed:@"DPPhoto_library_delete"] forState:UIControlStateNormal];
    [deleteButton setImageEdgeInsets:UIEdgeInsetsMake(0, self.bounds.size.width / 6, self.bounds.size.width / 6, 0)];
    [deleteButton addTarget:self action:@selector(deleteClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:deleteButton];
    
    [deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mas_right).with.offset(- 5);
        make.top.mas_equalTo(self.mas_top).with.offset(5);
        make.width.height.mas_equalTo(self.mas_width).multipliedBy(0.3);
    }];
    
}

- (void)deleteClick
{
    if (self.deleteButtonClickBlock) {
        self.deleteButtonClickBlock();
    }
}

- (void)setShowDeleteButton:(BOOL)showDeleteButton
{
    if (showDeleteButton) {
        deleteButton.enabled = YES;
        deleteButton.hidden = NO;
    } else {
        deleteButton.enabled = NO;
        deleteButton.hidden = YES;
    }
}

- (void)setPhotoURL:(NSString *)photoURL
{
    
    if ([photoURL hasPrefix:@"http"]) {
        
        //识别YYWebImageView
        
        if ([self.photoImageView respondsToSelector:@selector(setImageWithURL:placeholder:options:completion:)]) {
            [self.photoImageView performSelector:@selector(setImageWithURL:placeholder:options:completion:) withObjects:@[[NSURL URLWithString:photoURL], Placeholder_Image, @4096]];
        }
        
        //识别SDWebImageView
        
        else if ([self.photoImageView respondsToSelector:@selector(sd_setImageWithURL:placeholderImage:)]) {
            [self.photoImageView performSelector:@selector(sd_setImageWithURL:placeholderImage:) withObject:[NSURL URLWithString:photoURL] withObject:Placeholder_Image];
        }
        
        //当不存在YYWebImageView && SDWebImageView 系统默认加载方法，无缓存方案
        
        else {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                //通知主线程刷新
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:photoURL]];
                    self.photoImageView.image = [UIImage imageWithData:data];
                });
                
            });
        }
    }
    
    //本地图片展示
        
    else if ([UIImage imageNamed:photoURL]) {
        self.photoImageView.image = [UIImage imageNamed:photoURL];
    }
    
    //base64编码格式图片
    
    else {
        NSData *data = [[NSData alloc]initWithBase64EncodedString:photoURL options:0];
        self.photoImageView.image = [UIImage imageWithData:data];
    }
}

@end
