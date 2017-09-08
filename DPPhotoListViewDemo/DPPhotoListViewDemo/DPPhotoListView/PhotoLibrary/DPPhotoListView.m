//
//  DPPhotoListView.m
//  DPPhotoListViewDemo
//
//  Created by Andrew on 2017/8/22.
//  Copyright © 2017年 Andrew. All rights reserved.
//

#import "DPPhotoListView.h"
#import "DPPhotoListCollectionViewCell.h"
#import "DPPhotoBrowser.h"
#import "DPPhotoLibrary.h"
#import "UIScrollView+DPTouchEvent.h"
#import "DPPhotoAlbumsViewController.h"
#import "DPPhotoChooseViewController.h"

#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreLocation/CoreLocation.h>
#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/ALAssetsLibrary.h>
#import <AssetsLibrary/ALAssetsGroup.h>
#import <AssetsLibrary/ALAssetRepresentation.h>

@class UIActionSheetDelegateImpl;
static UIActionSheetDelegateImpl * delegateImpl;

@interface  DPPhotoListView () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, DPPhotoAlbumsDelegate>
{
    NSUInteger                  _lineNumber;            //每行cell个数
    CGFloat                     _lineSpacing;           //列间距
    NSMutableArray              __block *_dataSource;   //数据源
    BOOL                        _isShowingDeleteButton; //是否显示删除按钮
    
    UICollectionView            *_mainCollectionView;
    UICollectionViewFlowLayout  *_flowLayout;
}

@end

@implementation DPPhotoListView

- (instancetype)initWithFrame:(CGRect)frame numberOfCellInRow:(NSUInteger)lineNumber lineSpacing:(CGFloat)lineSpacing dataSource:(NSMutableArray *)dataSource
{
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;
        _lineNumber = lineNumber;
        _lineSpacing = lineSpacing;
        _dataSource = [dataSource mutableCopy];
        
        [self createSubviews];
    }
    return self;
}

- (void)createSubviews
{
    _flowLayout = [[UICollectionViewFlowLayout alloc] init];
    _flowLayout.minimumLineSpacing = _lineSpacing;
    _flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    _flowLayout.itemSize = CGSizeMake((self.bounds.size.width - (_lineNumber + 1) * _lineSpacing) / _lineNumber, (self.bounds.size.width - (_lineNumber + 1) * _lineSpacing) / _lineNumber);
    
    _mainCollectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:_flowLayout];
    _mainCollectionView.backgroundColor = [UIColor whiteColor];
    _mainCollectionView.delegate = self;
    _mainCollectionView.dataSource = self;
    _mainCollectionView.userInteractionEnabled = YES;
    _mainCollectionView.showsVerticalScrollIndicator = NO;
    _mainCollectionView.showsHorizontalScrollIndicator = NO;
    [_mainCollectionView registerClass:[DPPhotoListCollectionViewCell class] forCellWithReuseIdentifier:@"DPPhotoListCollectionViewCell"];
    [self addSubview:_mainCollectionView];
    
#if __has_include(<Masonry/Masonry.h>)
    [_mainCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left).with.offset(_lineSpacing);
        make.top.mas_equalTo(self.mas_top);
        make.width.mas_equalTo(self.mas_width).with.offset(- 2 * _lineSpacing);
        make.height.mas_equalTo(self.mas_height);
    }];
#else
    _mainCollectionView.frame = CGRectMake(_lineSpacing, 0, self.bounds.size.width - 2 * _lineSpacing, self.bounds.size.height);
#endif
}

#pragma mark -  public

- (void)autoEditPhoto
{
    if (_isShowingDeleteButton) {
        _isShowingDeleteButton = NO;
    } else {
        _isShowingDeleteButton = YES;
    }
    [_mainCollectionView reloadData];
}

//开启编辑图片
- (void)startEditPhoto
{
    _isShowingDeleteButton = YES;
    [_mainCollectionView reloadData];
}

//结束编辑
- (void)endEditPhoto
{
    _isShowingDeleteButton = NO;
    [_mainCollectionView reloadData];
}

//设置滚动方式
- (void)setPhotoScrollDirection:(DPPhotoScrollDirection)photoScrollDirection
{
    //水平滚动
    if (photoScrollDirection == DPPhotoScrollDirectionHorizontal) {
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _flowLayout.itemSize = CGSizeMake(self.bounds.size.height, self.bounds.size.height);
        [_mainCollectionView setCollectionViewLayout:_flowLayout];
        
    //竖直滚动
    } else if (photoScrollDirection == DPPhotoScrollDirectionVertical) {
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _flowLayout.itemSize = CGSizeMake((self.bounds.size.width - (_lineNumber + 1) * _lineSpacing) / _lineNumber, (self.bounds.size.width - (_lineNumber + 1) * _lineSpacing) / _lineNumber);
        [_mainCollectionView setCollectionViewLayout:_flowLayout];
    }
}

//显示增加按钮
- (void)setShowAddImagesButton:(BOOL)showAddImagesButton
{
    if (showAddImagesButton) {
        //增加最后一张“添加”图片
        [_dataSource addObject:@"DPPhoto_library_more"];
    }
    _showAddImagesButton = showAddImagesButton;
}

#pragma mark -  UICollectionView Delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DPPhotoListCollectionViewCell";
    DPPhotoListCollectionViewCell __weak *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.photo = [_dataSource objectAtIndex:indexPath.row];
    
    
    if (_isShowingDeleteButton) {
        cell.showDeleteButton = YES;
        if (indexPath.row == _dataSource.count - 1 && _showAddImagesButton) {
            cell.showDeleteButton = NO;
        }
    } else {
        cell.showDeleteButton = NO;
    }

    //长按编辑
    if (_allowLongPressEditPhoto) {
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
        longPress.minimumPressDuration = 1.0;
        [cell addGestureRecognizer:longPress];
    }
    
    //点击删除回调
    cell.deleteButtonClickBlock = ^{
        NSIndexPath *indexPath = [_mainCollectionView indexPathForCell:cell];
        [_dataSource removeObjectAtIndex:indexPath.row];
        [_mainCollectionView deleteItemsAtIndexPaths:@[indexPath]];
        if ([self.delegate respondsToSelector:@selector(deletedPhotoAtIndex:)]) {
            [self.delegate deletedPhotoAtIndex:indexPath.row];
        }
    };
    
    for (id subView in cell.contentView.subviews) {
        [subView removeFromSuperview];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    _isShowingDeleteButton = NO;
    if (indexPath.row == _dataSource.count - 1 && _showAddImagesButton) { //添加照片
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"照片审核\n清晰/美观/本人/生活照\n严禁盗图/涉及色情违规等直接封号" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"拍照" otherButtonTitles:@"相册", nil];
        actionSheet.tag = 0;
        [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];

    } else {
        
        DPPhotoListCollectionViewCell *cell = (DPPhotoListCollectionViewCell *)[_mainCollectionView cellForItemAtIndexPath:indexPath];
        CGRect cellInSuperview = [_mainCollectionView convertRect:cell.frame toView:nil];
        
        DPPhotoBrowser *photoBrowser = [[DPPhotoBrowser alloc]init];
        if (_showAddImagesButton) {
            photoBrowser.dataSource = [[_dataSource subarrayWithRange:NSMakeRange(0, _dataSource.count - 1)] mutableCopy];
        } else {
            photoBrowser.dataSource = _dataSource;
        }
        photoBrowser.zoomViewRect = cellInSuperview;
        if (_photoScrollDirection == DPPhotoScrollDirectionVertical) {
            [photoBrowser shwoPhotoBrowserAtIndex:indexPath.row shadowDirection:DPPhotoShadowDirectionVertical];
        } else {
            [photoBrowser shwoPhotoBrowserAtIndex:indexPath.row shadowDirection:DPPhotoShadowDirectionHorizontal];
        }
    }
    [_mainCollectionView reloadData];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)longPress:(UILongPressGestureRecognizer *)gesture
{
    if (!_isShowingDeleteButton) {
        [self startEditPhoto];
    }
}

#pragma mark -  UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        delegateImpl = nil;
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        actionSheet.delegate = nil;
    });
//    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        switch (buttonIndex) {
            case 0: {
                if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                    [[[UIAlertView alloc] initWithTitle:@"提示" message:@"此设备没有摄像头" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] show];
                } else {
                    UIImagePickerController *imagePickerController = [UIImagePickerController new];
                    imagePickerController.delegate = self;
                    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                    imagePickerController.allowsEditing = YES;
                    imagePickerController.showsCameraControls = YES;
                    imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
                    imagePickerController.mediaTypes = @[(NSString *)kUTTypeImage];
                    
                    [self.viewController presentViewController:imagePickerController animated:YES completion:nil];
                }
            }
                
                break;
            case 1: {//打开相册
                //相册是可以用模拟器打开
                if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                    DPPhotoAlbumsViewController *photoBrowser = [[DPPhotoAlbumsViewController alloc] init];
                    photoBrowser.delegate = self;
                    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:photoBrowser];
                    DPPhotoChooseViewController *tvc = [[DPPhotoChooseViewController alloc]init];
                    tvc.chooseViewDataSource = [[DPPhotoUtils getCameraRollAlbum] mutableCopy];
                    [nav pushViewController:tvc animated:YES];
                    [self.viewController presentViewController:nav animated:YES completion:nil];
                }else{
                    UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"Error" message:@"没有相册" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
                    [alter show];
                }
            }
                break;
                
            default:
                break;
        }
}

- (void)chooseCompleteBackWithModel:(NSArray<DPPhotoBrowserModel *> *)photos
{
    NSLog(@"");
}

- (void)chooseCompleteBackWithImages:(NSArray<UIImage *> *)images
{
    NSLog(@"");
}

- (void)chooseCompleteBackWithBase64String:(NSArray<NSString *> *)strings
{
    NSLog(@"");
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerEditedImage];
    
    [picker dismissViewControllerAnimated:YES completion:^ {
        
    }];
    
    //插入数组
    [_dataSource insertObject:image atIndex:_dataSource.count - 1];
    NSIndexPath *path = [NSIndexPath indexPathForItem:_dataSource.count - 2 inSection:0];
    [_mainCollectionView insertItemsAtIndexPaths:[NSArray arrayWithObject:path]];
    
    NSMutableArray __block *indexPaths = [NSMutableArray array];
    [_dataSource enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection: 0];
        [indexPaths addObject: indexPath];
    }];
    
    [UIView performWithoutAnimation:^{
        [_mainCollectionView reloadItemsAtIndexPaths:indexPaths];
    }];
    
    if ([self.delegate respondsToSelector:@selector(choosePhotoWithPhotoBase64String:)]) {
        [self.delegate choosePhotoWithPhotoBase64String:[DPPhotoUtils processingImages:image]];
    }
}

//点击Cancel按钮后执行方法
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    if ([touch.view isKindOfClass:[UICollectionView class]]) {
        if (_isShowingDeleteButton) {
            [self endEditPhoto];
        }
    }
}

@end
