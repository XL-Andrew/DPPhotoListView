//
//  DPPhotoBrowserCollectionViewCell.m
//  DPPhotoListViewDemo
//
//  Created by Andrew on 2017/8/23.
//  Copyright © 2017年 Andrew. All rights reserved.
//

#import "DPPhotoBrowserCollectionViewCell.h"
#import "DPPhotoLibrary.h"

@implementation DPPhotoBrowserCollectionViewCell
{
    UIScrollView *photoZoomScrollView;
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
    photoZoomScrollView = [[UIScrollView alloc]init];
    photoZoomScrollView.delegate = self;
    photoZoomScrollView.showsHorizontalScrollIndicator = NO;
    photoZoomScrollView.showsVerticalScrollIndicator = NO;
    photoZoomScrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    photoZoomScrollView.maximumZoomScale = 3.5;
    photoZoomScrollView.minimumZoomScale = 1.0;
    [self addSubview:photoZoomScrollView];
    
    [photoZoomScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
    _photoImageView = [[UIImageView alloc]initWithFrame:CGRectZero];
    _photoImageView.userInteractionEnabled = YES;
    [photoZoomScrollView addSubview:_photoImageView];
    
    //单击手势
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapAction:)];
    [photoZoomScrollView addGestureRecognizer:singleTap];
    
    //双击手势
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapAction:)];
    doubleTap.numberOfTapsRequired = 2;
    [photoZoomScrollView addGestureRecognizer:doubleTap];
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    //长按手势
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    longPress.allowableMovement = 20;
    [photoZoomScrollView addGestureRecognizer:longPress];
}

#pragma mark -  publick
- (void)setBrowserPhotoURL:(NSString *)browserPhotoURL
{
    if ([browserPhotoURL hasPrefix:@"http"]) {
        
        //识别YYWebImageView
        
        if ([self.photoImageView respondsToSelector:@selector(setImageWithURL:placeholder:options:completion:)]) {
            [self.photoImageView performSelector:@selector(setImageWithURL:placeholder:options:completion:) withObjects:@[[NSURL URLWithString:browserPhotoURL], Placeholder_Image, @4096]];
        }
        
        //识别SDWebImageView
        
        else if ([self.photoImageView respondsToSelector:@selector(sd_setImageWithURL:placeholderImage:)]) {
            [self.photoImageView performSelector:@selector(sd_setImageWithURL:placeholderImage:) withObject:[NSURL URLWithString:browserPhotoURL] withObject:Placeholder_Image];
        }
        
        //当不存在YYWebImageView && SDWebImageView 系统默认加载方法，无缓存方案
        
        else {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                //通知主线程刷新
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:browserPhotoURL]];
                    self.photoImageView.image = [UIImage imageWithData:data];
                });
                
            });
        }
    }
    
    //本地图片展示
    
    else if ([UIImage imageNamed:browserPhotoURL]) {
        self.photoImageView.image = [UIImage imageNamed:browserPhotoURL];
    }
    
    //base64编码格式图片
    
    else {
        NSData *data = [[NSData alloc]initWithBase64EncodedString:browserPhotoURL options:0];
        self.photoImageView.image = [UIImage imageWithData:data];
    }
    
    _photoImageView.frame = [self setImageViewFrameWithImage:_photoImageView.image];
}

#pragma mark -  手势事件
//单击
- (void)singleTapAction:(UITapGestureRecognizer *)tap
{    
    //先还原
    [photoZoomScrollView setZoomScale:1.0 animated:YES];
    
    if (self.singleTapClickBlock) {
        self.singleTapClickBlock();
    }
}

//双击
- (void)doubleTapAction:(UITapGestureRecognizer *)tap {
    
    CGPoint touchPoint = [tap locationInView:self];
    if (photoZoomScrollView.zoomScale <= 1.0) {
        
        CGFloat scaleWidth = self.frame.size.width / photoZoomScrollView.maximumZoomScale;
        CGFloat scaleHeight = self.frame.size.height / photoZoomScrollView.maximumZoomScale;
        
        [photoZoomScrollView zoomToRect:CGRectMake(touchPoint.x - scaleWidth / 2, touchPoint.y - scaleHeight / 2, scaleWidth, scaleHeight) animated:YES];
        
    } else {
        //还原
        [photoZoomScrollView setZoomScale:1.0 animated:YES];
    }
}

//长按
- (void)longPressAction:(UILongPressGestureRecognizer *)longPress
{
    if (longPress.state == UIGestureRecognizerStateBegan) {
        if (self.longPressClickBlock) {
            self.longPressClickBlock(_photoImageView.image);
        }
    }
}

#pragma mark -  UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _photoImageView;
}
//以中心点缩放
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    _photoImageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
}

#pragma mark -  工具方法
- (CGRect)setImageViewFrameWithImage:(UIImage *)kimage
{
    if (kimage == nil) return CGRectZero;
    
    CGFloat image_H =   SCREEN_WIDTH / kimage.size.width * kimage.size.height;
    CGFloat image_Y = (SCREEN_HEIGHT - image_H) / 2;
    
    if (image_H >= SCREEN_HEIGHT) {
        image_Y = 0;
    }
    
    photoZoomScrollView.contentSize = CGSizeMake(SCREEN_WIDTH, image_H);
    return CGRectMake(0, image_Y, SCREEN_WIDTH, image_H);
}

@end
