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
    NSMutableArray *_dataSource;
    UIPageControl *_pageControl;
    UIImage __block *_saveImage;
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
    
    [_mainCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    
    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
    _pageControl.center = CGPointMake(SCREEN_WIDTH / 2.0, SCREEN_HEIGHT - _pageControl.frame.size.height);
    _pageControl.numberOfPages = _dataSource.count;
    [self.view addSubview:_pageControl];
}

#pragma mark -  public
//显示图片浏览器
- (void)shwoPhotoBrowserAtIndex:(NSUInteger)index
{
    _pageControl.currentPage = index;
    [self.view layoutIfNeeded];
    [_mainCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    UIViewController *topVC = [DPPhotoUtils currentViewController];
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [topVC presentViewController:self animated:YES completion:nil];
}

- (void)setDataSource:(NSMutableArray *)dataSource
{
    _dataSource = dataSource;
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
    cell.browserPhotoURL = [_dataSource objectAtIndex:indexPath.row];
    cell.singleTapClickBlock = ^{
        
        UIImageView *tempImageView = [[UIImageView alloc] init];
        tempImageView.layer.cornerRadius = 4;
        tempImageView.clipsToBounds = YES;
        tempImageView.frame = CGRectMake(cell.photoImageView.bounds.origin.x, cell.photoImageView.bounds.origin.y, cell.photoImageView.bounds.size.width, cell.photoImageView.bounds.size.width);
        tempImageView.image = cell.photoImageView.image;
        [self.view.window addSubview:tempImageView];
        
        [self dismissViewControllerAnimated:NO completion:nil];
        
        [UIView animateWithDuration:0.3 animations:^{
            
            tempImageView.frame = self.zoomViewRect;
            tempImageView.alpha = 0;
            
        } completion:^(BOOL finished) {
            
            [tempImageView removeFromSuperview];
        }];
        
        [weakSelf dismissViewControllerAnimated:NO completion:nil];
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
    label.layer.cornerRadius = 5;
    label.clipsToBounds = YES;
    label.frame = CGRectMake((SCREEN_WIDTH - 100) / 2, (SCREEN_HEIGHT - 40) / 2, 100, 40);
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:14];
    [self.view addSubview:label];
    if (error) {
        label.text = @"保存失败";
    }   else {
        label.text = @"保存成功";
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
            // iOS系统版本 >= 8.0 跳入当前App设置界面,
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
