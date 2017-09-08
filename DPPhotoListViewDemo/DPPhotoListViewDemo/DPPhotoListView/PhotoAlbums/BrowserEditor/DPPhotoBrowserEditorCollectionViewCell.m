//
//  DPPhotoBrowserEditorCollectionViewCell.m
//  DPPhotoListViewDemo
//
//  Created by Andrew on 2017/9/6.
//  Copyright © 2017年 Andrew. All rights reserved.
//

#import "DPPhotoBrowserEditorCollectionViewCell.h"
#import "DPPhotoLibrary.h"
#import "DPPhotoBrowserModel.h"

@implementation DPPhotoBrowserEditorCollectionViewCell
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
    
#if __has_include(<Masonry/Masonry.h>)
    [photoZoomScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
#else
    photoZoomScrollView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
#endif
    
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
    
}

#pragma mark -  publick

- (void)setBrowserPhoto:(id)browserPhoto
{
    __weak __typeof(&*self) weakSelf = self;
    if ([browserPhoto isKindOfClass:[NSString class]]) {
        
        //网络图片
        if ([browserPhoto hasPrefix:@"http"]) {
            
            //识别SDWebImageView
#if __has_include(<SDWebImage/UIImageView+WebCache.h>)
            [self.photoImageView sd_setImageWithURL:[NSURL URLWithString:browserPhoto] placeholderImage:Placeholder_Image  completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                [weakSelf setphotoImageFrameWithImage:image];
            }];
#else
            
            //识别YYWebImageView
#if __has_include(<YYKit/UIImageView+YYWebImage.h>)
            [_photoImageView setImageWithURL:[NSURL URLWithString:browserPhoto] placeholder:Placeholder_Image options:YYWebImageOptionSetImageWithFadeAnimation completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                [weakSelf setphotoImageFrameWithImage:image];
            }];
#else
            //当不存在YYWebImageView && SDWebImageView 系统默认加载方法，无缓存方案
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                //通知主线程刷新
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:browserPhoto]];
                    [weakSelf setphotoImageFrameWithImage:[UIImage imageWithData:data]];
                });
                
            });
#endif
#endif
        }
        //base64编码格式图片
        else if ([browserPhoto hasPrefix:@"data:image"]) {
            NSData *imageData = [NSData dataWithBase64String:browserPhoto];
            [weakSelf setphotoImageFrameWithImage:[UIImage imageWithData:imageData]];
        }
        //本地图片
        else if ([UIImage imageNamed:browserPhoto]) {
            [weakSelf setphotoImageFrameWithImage:[UIImage imageNamed:browserPhoto]];
        }
        //data字符串
        else if ([browserPhoto dataUsingEncoding:NSUTF8StringEncoding]) {
             [weakSelf setphotoImageFrameWithImage:[[UIImage alloc]initWithData:[browserPhoto dataUsingEncoding:NSUTF8StringEncoding]]];
        } else {
            [weakSelf setphotoImageFrameWithImage:Placeholder_Image];
        }
    }
    //UIImage 类型
    else if ([browserPhoto isKindOfClass:[UIImage class]]) {
        [weakSelf setphotoImageFrameWithImage:browserPhoto];
    }
    //NSData 类型
    else if ([browserPhoto isKindOfClass:[NSData class]]) {
        [weakSelf setphotoImageFrameWithImage:[[UIImage alloc]initWithData:browserPhoto]];
    }
    //PHAsset 类型
    else if ([browserPhoto isKindOfClass:[PHAsset class]]) {
        [DPPhotoUtils requestImageForAsset:browserPhoto size:CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT) resizeMode:PHImageRequestOptionsResizeModeFast completion:^(UIImage *image, NSDictionary *info) {
            [weakSelf setphotoImageFrameWithImage:image];
        }];
    }
    //unknown
    else {
        [weakSelf setphotoImageFrameWithImage:Placeholder_Image];
    }
    
}

//设置图片frame
- (void)setphotoImageFrameWithImage:(UIImage *)kimage
{
    if (kimage == nil) {
        _photoImageView.frame = CGRectZero;
    }
    self.photoImageView.image = kimage;
    CGFloat image_H =   SCREEN_WIDTH / kimage.size.width * kimage.size.height;
    CGFloat image_Y = (SCREEN_HEIGHT - image_H) / 2;
    
    if (image_H >= SCREEN_HEIGHT) {
        image_Y = 0;
    }
    
    photoZoomScrollView.contentSize = CGSizeMake(SCREEN_WIDTH, image_H);
    _photoImageView.frame = CGRectMake(0, image_Y, SCREEN_WIDTH, image_H);
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

@end
