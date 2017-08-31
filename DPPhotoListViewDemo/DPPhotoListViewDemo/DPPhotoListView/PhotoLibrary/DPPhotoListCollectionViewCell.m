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
    
    deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteButton.backgroundColor = RGB_COLOR(0, 0, 0, 0.5);
    deleteButton.enabled = NO;
    deleteButton.hidden = YES;
    deleteButton.layer.cornerRadius = 4;
    deleteButton.clipsToBounds = YES;
    [deleteButton setImage:[UIImage imageNamed:@"DPPhoto_library_delete"] forState:UIControlStateNormal];
    [deleteButton setImageEdgeInsets:UIEdgeInsetsMake(self.bounds.size.width / 2 - 18, self.bounds.size.width / 2 - 18, self.bounds.size.width / 2 - 18, self.bounds.size.width / 2 - 18)];
    [deleteButton addTarget:self action:@selector(deleteClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:deleteButton];
    
#if __has_include(<Masonry/Masonry.h>)
    [self.photoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(0);
        make.width.mas_equalTo(self.mas_width);
        make.height.mas_equalTo(self.mas_height);
    }];
    
    [deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mas_right);
        make.top.mas_equalTo(self.mas_top);
        make.width.height.mas_equalTo(self.mas_width);
    }];
#else
    self.photoImageView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    deleteButton.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
#endif
    
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

- (void)setPhoto:(id)photo
{
    if ([photo isKindOfClass:[NSString class]]) {
        
        //网络图片
        if ([photo hasPrefix:@"http"]) {

            //识别SDWebImageView
#if __has_include(<SDWebImage/UIImageView+WebCache.h>)
            [self.photoImageView sd_setImageWithURL:[NSURL URLWithString:photo] placeholderImage:Placeholder_Image];
#else

            //识别YYWebImageView
#if __has_include(<YYKit/UIImageView+YYWebImage.h>)
            [self.photoImageView setImageWithURL:[NSURL URLWithString:photo] placeholder:Placeholder_Image options:YYWebImageOptionSetImageWithFadeAnimation completion:nil];
#else
            //当不存在YYWebImageView && SDWebImageView 系统默认加载方法，无缓存方案
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                //通知主线程刷新
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:photo]];
                    self.photoImageView.image = [UIImage imageWithData:data];
                });
                
            });
#endif
#endif
        }
        //base64编码格式图片
        else if ([photo hasPrefix:@"data:image/jpg;base64,"]) {
            NSData *data = [[NSData alloc]initWithBase64EncodedString:[photo stringByReplacingOccurrencesOfString:@"data:image/jpg;base64," withString:@""] options:0];
            self.photoImageView.image = [[UIImage alloc]initWithData:data];
        }
        //本地图片
        else if ([UIImage imageNamed:photo]) {
            self.photoImageView.image = [UIImage imageNamed:photo];
        }
        //data字符串
        else if ([photo dataUsingEncoding:NSUTF8StringEncoding]) {
            self.photoImageView.image = [[UIImage alloc]initWithData:[photo dataUsingEncoding:NSUTF8StringEncoding]];
        } else {
            self.photoImageView.image = Placeholder_Image;
        }
    }
    //UIImage 类型
    else if ([photo isKindOfClass:[UIImage class]]) {
        self.photoImageView.image = photo;
    }
    //NSData 类型
    else if ([photo isKindOfClass:[NSData class]]) {
        self.photoImageView.image = [[UIImage alloc]initWithData:photo];
    }
    //unknown
    else {
        self.photoImageView.image = Placeholder_Image;
    }
}

@end
