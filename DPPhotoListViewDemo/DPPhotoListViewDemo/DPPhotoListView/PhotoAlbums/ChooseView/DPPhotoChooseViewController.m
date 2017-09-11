//
//  DPPhotoChooseViewController.m
//  DPPhotoListViewDemo
//
//  Created by Andrew on 2017/9/5.
//  Copyright © 2017年 Andrew. All rights reserved.
//

#import "DPPhotoChooseViewController.h"
#import "DPPhotoChooseViewCell.h"
#import "DPPhotoChooseToolBar.h"
#import "DPPhotoLibrary.h"
#import "DPPhotoBrowserEditor.h"
#import "DPPhotoBrowserModel.h"
#import "DPPhotoAlbumsViewController.h"

@interface DPPhotoChooseViewController () <UICollectionViewDelegate, UICollectionViewDataSource>
{
    UICollectionView *mainCollectionView;
}

@property (nonatomic, assign) NSUInteger __block selectNum;//选择图片个数

@property (nonatomic, strong) DPPhotoChooseToolBar *toolBar;

@end

@implementation DPPhotoChooseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initialize];
    [self createSubviews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationController.navigationBar.translucent = YES;
    [self.navigationController.navigationBar setTintColor:[UIColor blackColor]];
}

- (void)initialize
{
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 60, 44);
    btn.titleLabel.font = [UIFont systemFontOfSize:16];
    [btn setTitle:@"取消" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(popView) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    self.selectNum = 0;
    [self addObserver:self forKeyPath:@"selectNum" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}

- (void)createSubviews
{
    WS(weakSelf);
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumLineSpacing = LineSpacing; //上下的间距 可以设置0看下效果
    flowLayout.minimumInteritemSpacing = LineSpacing;
    flowLayout.itemSize = CGSizeMake((self.view.bounds.size.width - 3 * LineSpacing) / 4, (self.view.bounds.size.width - 3 * LineSpacing) / 4);
    flowLayout.footerReferenceSize = CGSizeMake(self.view.bounds.size.width, 30);
    
    mainCollectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    mainCollectionView.backgroundColor = [UIColor whiteColor];
    mainCollectionView.bounces = YES;
    mainCollectionView.delegate = self;
    mainCollectionView.dataSource = self;
    mainCollectionView.showsVerticalScrollIndicator = NO;
    mainCollectionView.showsHorizontalScrollIndicator = NO;
    
    [mainCollectionView registerClass:[DPPhotoChooseViewCell class] forCellWithReuseIdentifier:@"DPPhotoChooseViewCell"];
    [mainCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView"];
    [self.view addSubview:mainCollectionView];
    
    self.toolBar = [[DPPhotoChooseToolBar alloc]init];
    self.toolBar.showPreviewButton = YES;
    //预览
    self.toolBar.PreviewButtonClick = ^{
        DPPhotoBrowserEditor *editor = [[DPPhotoBrowserEditor alloc]init];
        editor.browserDataSource = weakSelf.chooseViewDataSource;
        editor.showIndex = 0;
        editor.maxSelectCount = weakSelf.maxSelectCount;
        [weakSelf.navigationController pushViewController:editor animated:YES];
    };
    //确认
    self.toolBar.ConfirmButtonClick = ^{
        [[weakSelf.navigationController viewControllers] enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[DPPhotoAlbumsViewController class]]) {
                DPPhotoAlbumsViewController *vc = obj;
                if ([vc.delegate respondsToSelector:@selector(chooseCompleteBackWithModel:)]) {
                    NSMutableArray __block *karr = [NSMutableArray array];
                    [weakSelf.chooseViewDataSource enumerateObjectsUsingBlock:^(DPPhotoBrowserModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if (obj.isSelected) {
                            [karr addObject:obj];
                        }
                    }];
                    [vc.delegate chooseCompleteBackWithModel:karr];
                }
                if ([vc.delegate respondsToSelector:@selector(chooseCompleteBackWithImages:)]) {
                    NSMutableArray __block *karr = [NSMutableArray array];
                    [weakSelf.chooseViewDataSource enumerateObjectsUsingBlock:^(DPPhotoBrowserModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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
                    [weakSelf.chooseViewDataSource enumerateObjectsUsingBlock:^(DPPhotoBrowserModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if (obj.isSelected) {
                            [DPPhotoUtils requestImageForAsset:obj.photo size:CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT) resizeMode:PHImageRequestOptionsResizeModeNone completion:^(UIImage *image, NSDictionary *info) {
                                [karr addObject:[DPPhotoUtils processingImages:image]];
                            }];
                        }
                    }];
                    [vc.delegate chooseCompleteBackWithBase64String:karr];
                }
                [vc dismissViewControllerAnimated:YES completion:nil];
            }
        }];
    };
    [self.view addSubview:self.toolBar];
    
    
    
#if __has_include(<Masonry/Masonry.h>)
    [mainCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(LineSpacing);
        make.left.mas_equalTo(0);
        make.width.mas_equalTo(self.view.mas_width);
        make.height.mas_equalTo(self.view.mas_height).with.offset(- 44);
    }];
    
    [self.toolBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(SCREEN_HEIGHT - 44);
        make.width.mas_equalTo(mainCollectionView.mas_width);
        make.height.mas_equalTo(44);
    }];
#else
    mainCollectionView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    self.toolBar.frame = CGRectMake(0, SCREEN_HEIGHT - 44, SCREEN_WIDTH, 44);
#endif
}

#pragma mark -  UICollectionView Delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.chooseViewDataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WS(weakSelf)
    DPPhotoBrowserModel __block *model = [self.chooseViewDataSource objectAtIndex:indexPath.row];
    static NSString *CellIdentifier = @"DPPhotoChooseViewCell";
    DPPhotoChooseViewCell __weak *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.thumbnailPhoto = model.photo;
    cell.isButtonSelected = model.isSelected;
    cell.selectedBlock = ^(BOOL hasSelected) {
        
        if (hasSelected) {
            model.isSelected = NO;
            weakSelf.selectNum --;
            return YES;
        }
        
        if (weakSelf.selectNum < weakSelf.maxSelectCount && !hasSelected) {
            model.isSelected = YES;
            weakSelf.selectNum ++;
            return YES;
        } else {
            [[[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"最多只能选择%ld张",weakSelf.maxSelectCount] delegate:weakSelf cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil] show];
        }
        return NO;
    };
    for (id subView in cell.contentView.subviews) {
        [subView removeFromSuperview];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    DPPhotoBrowserEditor *editor = [[DPPhotoBrowserEditor alloc]init];
    editor.browserDataSource = self.chooseViewDataSource;
    editor.showIndex = indexPath.row;
    editor.maxSelectCount = self.maxSelectCount;
    [self.navigationController pushViewController:editor animated:YES];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
    footerview.backgroundColor = [UIColor whiteColor];
    
    UILabel *footTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 30)];
    footTitle.text = [NSString stringWithFormat:@"共%ld张照片",self.chooseViewDataSource.count];
    footTitle.font = PUB_FONT;
    footTitle.textAlignment = NSTextAlignmentCenter;
    footTitle.textColor = [UIColor grayColor];
    [footerview addSubview:footTitle];
    
    return footerview;
}

- (void)setChooseViewDataSource:(NSMutableArray *)chooseViewDataSource
{
    WS(weakSelf)
    self.selectNum = 0;
    _chooseViewDataSource = [[NSMutableArray alloc]init];
    [chooseViewDataSource enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[DPPhotoBrowserModel class]]) {
            DPPhotoBrowserModel *model = obj;
            if (model.isSelected) {
                weakSelf.selectNum ++;
            }
            [weakSelf.chooseViewDataSource addObject:obj];
            
        } else {
            DPPhotoBrowserModel *model = [[DPPhotoBrowserModel alloc]init];
            model.isSelected = NO;
            model.photo = obj;
            [weakSelf.chooseViewDataSource addObject:model];
        }
    }];
    [mainCollectionView reloadData];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    self.toolBar.confirmNumber = [[change objectForKey:@"new"] integerValue];
}
- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"selectNum" context:nil];
}

- (void)popView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
