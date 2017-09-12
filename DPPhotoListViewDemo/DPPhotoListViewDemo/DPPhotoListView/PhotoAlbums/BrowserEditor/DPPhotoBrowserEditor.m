//
//  DPPhotoBorwserEditor.m
//  DPPhotoListViewDemo
//
//  Created by Andrew on 2017/9/6.
//  Copyright © 2017年 Andrew. All rights reserved.
//

#import "DPPhotoBrowserEditor.h"
#import "DPPhotoBrowserEditorCollectionViewCell.h"
#import "DPPhotoAlbumsViewController.h"
#import "DPPhotoChooseToolBar.h"
#import "DPPhotoLibrary.h"
#import "UIViewController+BackButtonHandler.h"
#import "DPPhotoChooseViewController.h"

@interface DPPhotoBrowserEditor () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UINavigationBarDelegate>
{
    UICollectionView *_mainCollectionView;
    UIButton *selectButton;
    DPPhotoChooseToolBar *toolBar;
}

@property (nonatomic, strong) NSMutableArray <DPPhotoBrowserModel *> __block *tempArray;//临时数据源

@property (nonatomic, assign) NSUInteger __block selectNum;//选择图片个数

@property (nonatomic, assign) NSUInteger index;//当前滚动位数

@property (nonatomic, assign) BOOL __block isShowMenu;//是否显示菜单栏

@end

@implementation DPPhotoBrowserEditor

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initialize];
    [self createSubviews];
}

- (void)viewDidAppear:(BOOL)animated
{
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    [super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.translucent = YES;
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
}

- (void)initialize
{
    _tempArray = [NSMutableArray array];
    if (_browseImageType == DPBrowseImageTypePreview) {
        [self.browserDataSource enumerateObjectsUsingBlock:^(DPPhotoBrowserModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.isSelected) {
                [_tempArray addObject:obj];
            }
        }];
    } else {
        _tempArray = [_browserDataSource mutableCopy];
    }
    
    if (_index > _tempArray.count) {
        _index = _tempArray.count - 1;
    }
    
    self.selectNum = 0;
    [self addObserver:self forKeyPath:@"selectNum" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor blackColor];
    self.title = [NSString stringWithFormat:@"%ld/%ld",_index + 1,_tempArray.count];
    
    selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    selectButton.frame = CGRectMake(0, 0, 60, 44);
    selectButton.backgroundColor = [UIColor clearColor];
    [selectButton setImage:[UIImage imageNamed:@"DPPhoto_choose_unSelect"] forState:UIControlStateNormal];
    [selectButton setImage:[UIImage imageNamed:@"DPPhoto_choose_select"] forState:UIControlStateSelected];
    [selectButton setImageEdgeInsets:UIEdgeInsetsMake(12, 40, 12, 0)];
    [selectButton addTarget:self action:@selector(btnSelectClick:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:selectButton];
    
    
}

- (void)createSubviews
{
    WS(weakSelf)
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumLineSpacing = 0.0f;
    flowLayout.minimumInteritemSpacing = 0.0f;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.itemSize = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT);
    
    _mainCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    [_mainCollectionView registerClass:[DPPhotoBrowserEditorCollectionViewCell class] forCellWithReuseIdentifier:@"DPPhotoBrowserEditorCollectionViewCell"];
    _mainCollectionView.pagingEnabled = YES;
    _mainCollectionView.backgroundColor = [UIColor clearColor];
    _mainCollectionView.dataSource = self;
    _mainCollectionView.delegate = self;
    _mainCollectionView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:_mainCollectionView];
    
    toolBar = [[DPPhotoChooseToolBar alloc]init];
    toolBar.toolBarStyle = DPPhotoToolBarStyleDark;
    toolBar.ConfirmButtonClick = ^{
        [[weakSelf.navigationController viewControllers] enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull mainStop) {
            if ([obj isKindOfClass:[DPPhotoAlbumsViewController class]]) {
                DPPhotoAlbumsViewController *vc = obj;
                if ([vc.delegate respondsToSelector:@selector(chooseCompleteBackWithModel:)]) {
                    NSMutableArray __block *karr = [NSMutableArray array];
                    [weakSelf.tempArray enumerateObjectsUsingBlock:^(DPPhotoBrowserModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if (obj.isSelected) {
                            [karr addObject:obj];
                        }
                    }];
                    [vc.delegate chooseCompleteBackWithModel:karr];
                }
                if ([vc.delegate respondsToSelector:@selector(chooseCompleteBackWithImages:)]) {
                    NSMutableArray __block *karr = [NSMutableArray array];
                    [weakSelf.tempArray enumerateObjectsUsingBlock:^(DPPhotoBrowserModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if (obj.isSelected) {
                            [DPPhotoUtils requestImageForAsset:obj.photo size:CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT) resizeMode:PHImageRequestOptionsResizeModeNone completion:^(UIImage *image, NSDictionary *info) {
                                [karr addObject:image];
                            }];
                        }
                    }];
                    [vc.delegate chooseCompleteBackWithImages:karr];
                }
                if ([vc.delegate respondsToSelector:@selector(chooseCompleteBackWithBase64String:)]) {
                    NSMutableArray __block *karr = [NSMutableArray array];
                    [weakSelf.tempArray enumerateObjectsUsingBlock:^(DPPhotoBrowserModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if (obj.isSelected) {
                            [DPPhotoUtils requestImageForAsset:obj.photo size:CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT) resizeMode:PHImageRequestOptionsResizeModeNone completion:^(UIImage *image, NSDictionary *info) {
                                [karr addObject:[DPPhotoUtils processingImages:image]];
                            }];
                        }
                    }];
                    [vc.delegate chooseCompleteBackWithBase64String:karr];
                }
                *mainStop = YES;
                [vc dismissViewControllerAnimated:YES completion:nil];
            }
        }];
        
    };
    [self.view addSubview:toolBar];
    
    
#if __has_include(<Masonry/Masonry.h>)
    [_mainCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    
    [toolBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.bottom.mas_equalTo(self.view.mas_bottom);
        make.width.mas_equalTo(self.view.mas_width);
        make.height.mas_equalTo(44);
    }];
    
    [self.view layoutIfNeeded];
    
#else
    _mainCollectionView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    toolBar.frame = CGRectMake(0, SCREEN_HEIGHT - 44, SCREEN_WIDTH, 44);
#endif
    
    [_mainCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_index inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    [_tempArray enumerateObjectsUsingBlock:^(DPPhotoBrowserModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (_index == idx) {
            selectButton.selected = obj.isSelected;
        }
        if (obj.isSelected) {
            weakSelf.selectNum ++;
        }
    }];
    
}

#pragma mark -  UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _tempArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DPPhotoBrowserModel *model = [_tempArray objectAtIndex:indexPath.row];
    WS(weakSelf);
    static NSString *CellIdentifier = @"DPPhotoBrowserEditorCollectionViewCell";
    DPPhotoBrowserEditorCollectionViewCell __weak *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.browserPhoto = model.photo;
    cell.singleTapClickBlock = ^{//单击屏幕隐藏菜单栏
        if (weakSelf.isShowMenu) {
            [weakSelf showNavBarAndTabbar];
            weakSelf.isShowMenu = NO;
        } else {
            [weakSelf hiddenNavBarAndTabbar];
            weakSelf.isShowMenu = YES;
        }
    };
    
    for (id subView in cell.contentView.subviews) {
        [subView removeFromSuperview];
    }
    return cell;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _index = scrollView.contentOffset.x / scrollView.bounds.size.width;
    self.title = [NSString stringWithFormat:@"%ld/%ld",_index + 1,_tempArray.count];
    DPPhotoBrowserModel *model = [_tempArray objectAtIndex:_index];
    selectButton.selected = model.isSelected;
}

#pragma mark -  点击事件
- (void)btnSelectClick:(UIButton *)sender
{
    if (!sender.selected && self.selectNum >= self.maxSelectCount) {
        [[[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"最多只能选择%ld张",self.maxSelectCount] delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil] show];
        return;
    }
    if (selectButton.selected) {
        self.selectNum --;
    }
    
    if (self.selectNum < self.maxSelectCount && !selectButton.selected) {
        [selectButton.imageView.layer addAnimation:[DPPhotoUtils getButtonStatusChangedAnimation] forKey:nil];
        self.selectNum ++;
    }
    selectButton.selected = !selectButton.selected;
    DPPhotoBrowserModel *model = [_tempArray objectAtIndex:_index];
    model.isSelected = selectButton.selected;
    [_tempArray replaceObjectAtIndex:_index withObject:model];
}

#pragma mark -  private

- (void)setShowIndex:(NSUInteger)showIndex
{
    _index = showIndex;
}

- (void)showNavBarAndTabbar
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
#if __has_include(<Masonry/Masonry.h>)
    
    [toolBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.view.mas_bottom);
    }];
    
    [UIView animateWithDuration:0.2 animations:^{
        [toolBar.superview layoutIfNeeded];
    }];
#else
    [UIView animateWithDuration:0.2 animations:^{
        toolBar.frame = CGRectMake(0, SCREEN_HEIGHT - 44, SCREEN_WIDTH, 44);
    }];
#endif
}

- (void)hiddenNavBarAndTabbar
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
#if __has_include(<Masonry/Masonry.h>)
    
    [toolBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.view.mas_bottom).with.offset(64);
    }];
    
    [UIView animateWithDuration:0.2 animations:^{
        [toolBar.superview layoutIfNeeded];
    }];
#else
    [UIView animateWithDuration:0.2 animations:^{
        toolBar.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 44);
    }];
#endif
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    toolBar.confirmNumber = [[change objectForKey:@"new"] integerValue];
}

- (BOOL)navigationShouldPopOnBackButton
{
    WS(weakSelf)
    [[self.navigationController viewControllers] enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[DPPhotoChooseViewController class]]) {
            DPPhotoChooseViewController *vc = obj;
            if (_browserDataSource.count != _tempArray.count) {
                [_browserDataSource enumerateObjectsUsingBlock:^(DPPhotoBrowserModel * _Nonnull browseModel, NSUInteger idxBrowse, BOOL * _Nonnull stop) {
                    [_tempArray enumerateObjectsUsingBlock:^(DPPhotoBrowserModel * _Nonnull tempModel, NSUInteger idxTemp, BOOL * _Nonnull stop) {
                        if (tempModel.photo == browseModel.photo) {
                            if (tempModel.isSelected != browseModel.isSelected) {
                                [_browserDataSource replaceObjectAtIndex:idxBrowse withObject:tempModel];
                            }
                            *stop = YES;
                        }
                    }];
                }];
            }
            vc.chooseViewDataSource = weakSelf.browserDataSource;
        }
    }];
    return YES;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"selectNum" context:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
