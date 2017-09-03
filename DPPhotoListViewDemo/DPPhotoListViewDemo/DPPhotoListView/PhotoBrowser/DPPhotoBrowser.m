//
//  DPPhotoBrowser.m
//  DPPhotoListViewDemo
//
//  Created by Andrew on 2017/8/23.
//  Copyright © 2017年 Andrew. All rights reserved.
//

#import "DPPhotoBrowser.h"
#import "DPPhotoLibrary.h"
#import "DPPhotoBrowserCollectionViewCell.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface DPPhotoBrowser () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIActionSheetDelegate>
{
    UICollectionView *_mainCollectionView;
    UIPageControl *_pageControl;
    NSMutableArray *_dataSource;
    
    UIImage __block *_saveImage;    //保存的图片
    
    CGRect _tempImageZoomRect;      //缩放图片rect
    NSMutableArray *_zoomRectArray; //缩放图片rect数组
}

@end

@implementation DPPhotoBrowser

- (void)viewDidLoad {
    [super viewDidLoad];
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumLineSpacing = 0.0;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.itemSize = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT);
    
    _mainCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    [_mainCollectionView registerClass:[DPPhotoBrowserCollectionViewCell class] forCellWithReuseIdentifier:@"DPPhotoBrowserCollectionViewCell"];
    _mainCollectionView.pagingEnabled = YES;
    _mainCollectionView.backgroundColor = [UIColor clearColor];
    _mainCollectionView.dataSource = self;
    _mainCollectionView.delegate = self;
    _mainCollectionView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:_mainCollectionView];
#if __has_include(<Masonry/Masonry.h>)
    [_mainCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
#else
    _mainCollectionView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
#endif
    
    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
    _pageControl.center = CGPointMake(SCREEN_WIDTH / 2.0, SCREEN_HEIGHT - _pageControl.frame.size.height);
    _pageControl.numberOfPages = _dataSource.count;
    [self.view addSubview:_pageControl];
    
}

#pragma mark -  public
//显示图片浏览器
- (void)shwoPhotoBrowserAtIndex:(NSUInteger)index shadowDirection:(DPPhotoShadowDirection)shadowDirection
{
    _zoomRectArray = [NSMutableArray array];
    if (shadowDirection == DPPhotoShadowDirectionVertical) {
        
        //模拟设置回缩影像位置
        int lineNumber = SCREEN_WIDTH / (_tempImageZoomRect.size.width + 1);//每行多少view
        int lineSpacing = ((int)SCREEN_WIDTH % (int)_tempImageZoomRect.size.width) / (lineNumber + 1);
        CGFloat zoomView_W = _tempImageZoomRect.size.width;//宽
        CGFloat zoomView_H = _tempImageZoomRect.size.width;//高
        CGFloat margin_X = _tempImageZoomRect.origin.x - (index % lineNumber) * (zoomView_W + lineSpacing);//X坐标
        CGFloat margin_Y = _tempImageZoomRect.origin.y - (index / lineNumber) * (zoomView_W + lineSpacing);//Y坐标
        for (int i = 0; i < _dataSource.count; i ++) {
            int row = i / lineNumber;//行号
            int loc = i % lineNumber;//列号
            CGFloat zoomView_X = margin_X + (lineSpacing + zoomView_W) * loc;
            CGFloat zoomView_Y = margin_Y + (lineSpacing + zoomView_H) * row;
            
            [_zoomRectArray addObject:[NSValue valueWithCGRect:CGRectMake(zoomView_X, zoomView_Y, zoomView_W, zoomView_H)]];
        }
    } else {
        //模拟设置回缩影像位置
        int lineNumber = (int)_dataSource.count;//每行多少view
        int lineSpacing = 15;
        CGFloat zoomView_W = _tempImageZoomRect.size.width;//宽
        CGFloat zoomView_H = _tempImageZoomRect.size.width;//高
        CGFloat margin_X = _tempImageZoomRect.origin.x - (index % lineNumber) * (zoomView_W + lineSpacing);//X坐标
        CGFloat margin_Y = _tempImageZoomRect.origin.y;
        for (int i = 0; i < _dataSource.count; i ++) {
            int row = i / lineNumber;//行号
            int loc = i % lineNumber;//列号
            CGFloat zoomView_X = margin_X + (lineSpacing + zoomView_W) * loc;
            CGFloat zoomView_Y = margin_Y + (lineSpacing + zoomView_H) * row;
            
            [_zoomRectArray addObject:[NSValue valueWithCGRect:CGRectMake(zoomView_X, zoomView_Y, zoomView_W, zoomView_H)]];
        }
    }
    
    _pageControl.currentPage = index;
    [self.view layoutIfNeeded];
    [_mainCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    UIViewController *topVC = [self currentViewController];
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [topVC presentViewController:self animated:YES completion:nil];
}

- (void)setDataSource:(NSMutableArray *)dataSource
{
    _dataSource = [dataSource mutableCopy];
}

- (void)setZoomViewRect:(CGRect)zoomViewRect
{
    _tempImageZoomRect = zoomViewRect;
}

#pragma mark -  UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    __weak __typeof(&*self) weakSelf = self;
    static NSString *CellIdentifier = @"DPPhotoBrowserCollectionViewCell";
    DPPhotoBrowserCollectionViewCell __weak *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.photo = [_dataSource objectAtIndex:indexPath.row];
    
    //点击图片后缩放
    cell.singleTapClickBlock = ^{
        
        UIImageView *tempImageView = [[UIImageView alloc] init];
        tempImageView.layer.cornerRadius = 4;
        tempImageView.clipsToBounds = YES;
        tempImageView.frame = CGRectMake(cell.photoImageView.bounds.origin.x, cell.photoImageView.bounds.origin.y, cell.photoImageView.bounds.size.width, cell.photoImageView.bounds.size.height);
        tempImageView.center = CGPointMake(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2);
        tempImageView.image = cell.photoImageView.image;
        [weakSelf.view.window addSubview:tempImageView];
        [weakSelf dismissViewControllerAnimated:NO completion:nil];
        
        [UIView animateWithDuration:0.5f animations:^{
            tempImageView.frame = _tempImageZoomRect;
            tempImageView.alpha = 0;
            
        } completion:^(BOOL finished) {
            [tempImageView removeFromSuperview];
        }];
        
    };
    
    cell.longPressClickBlock = ^(UIImage *tempSaveImage) {
        _saveImage = tempSaveImage;
        UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"保存图片" otherButtonTitles:nil, nil];
        [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
    };
    
    for (id subView in cell.contentView.subviews) {
        [subView removeFromSuperview];
    }
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int index = scrollView.contentOffset.x / scrollView.bounds.size.width;
    _pageControl.currentPage = index;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int index = scrollView.contentOffset.x / scrollView.bounds.size.width;
    _tempImageZoomRect = [[_zoomRectArray objectAtIndex:index] CGRectValue];
}

#pragma mark -  UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self saveImage:_saveImage];
    }
}

#pragma mark 保存图像
- (void)saveImage:(UIImage *)image {
    
    ALAuthorizationStatus authStatus = [ALAssetsLibrary authorizationStatus];
    if (authStatus == ALAuthorizationStatusDenied || authStatus == ALAuthorizationStatusRestricted) {
        // 没有权限
        [self showAlert];
    } else {
        // 已经获取权限
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    }
    
}
//保存图片的回调
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{    
    UILabel *label = [[UILabel alloc] init];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.50f];
    label.layer.cornerRadius = 4;
    label.clipsToBounds = YES;
    label.frame = CGRectMake((SCREEN_WIDTH - 150) / 2, (SCREEN_HEIGHT - 40) / 2, 150, 40);
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:14];
    [self.view addSubview:label];
    if (error) {
        label.text = @"保存失败";
    }   else {
        label.text = @"已保存到系统相册";
    }
    [label performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:1.5];
}

//相册权限
- (void)showAlert
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"相册权限未开启" message:@"请在iPhone的【设置】>【隐私】>【相册】中打开开关,开启相册权限" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"立即开启" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSString *version = [UIDevice currentDevice].systemVersion;
        if (version.doubleValue >= 8.0) {
            // iOS系统版本 >= 8.0 跳入当前App设置界面
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            
        } else {
            //iOS系统版本 < 8.0
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"prefs:General&path=Reset"]];
        }
        
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
}

- (UIViewController *)currentViewController
{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    UIViewController *vc = keyWindow.rootViewController;
    while (vc.presentedViewController) {
        vc = vc.presentedViewController;
        
        if ([vc isKindOfClass:[UINavigationController class]]) {
            vc = [(UINavigationController *)vc visibleViewController];
        } else if ([vc isKindOfClass:[UITabBarController class]]) {
            vc = [(UITabBarController *)vc selectedViewController];
        }
    }
    return vc;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
