//
//  DPPhotoAlbumsViewController.m
//  DPPhotoListViewDemo
//
//  Created by Andrew on 2017/9/4.
//  Copyright © 2017年 Andrew. All rights reserved.
//

#import "DPPhotoAlbumsViewController.h"
#import <Photos/Photos.h>
#import "DPPhotoAlbumsTableViewCell.h"
#import "DPPhotoAlbumModel.h"
#import "DPPhotoLibrary.h"
#import "DPPhotoChooseViewController.h"

@interface DPPhotoAlbumsViewController () <UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray *dataSource;
}

@end

@implementation DPPhotoAlbumsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"照片";
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 60, 44);
    btn.titleLabel.font = [UIFont systemFontOfSize:16];
    [btn setTitle:@"取消" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(popView) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    UITableView *tableview = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableview.delegate = self;
    tableview.dataSource = self;
    [self.view addSubview:tableview];
    
    [tableview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    
    
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    
    //获取所有智能相册
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    PHFetchResult *streamAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumMyPhotoStream options:nil];
    PHFetchResult *userAlbums = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    PHFetchResult *syncedAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumSyncedAlbum options:nil];
    PHFetchResult *sharedAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumCloudShared options:nil];
    NSArray *arrAllAlbums = @[smartAlbums, streamAlbums, userAlbums, syncedAlbums, sharedAlbums];
    /**
     PHAssetCollectionSubtypeAlbumRegular         = 2,///
     PHAssetCollectionSubtypeAlbumSyncedEvent     = 3,////
     PHAssetCollectionSubtypeAlbumSyncedFaces     = 4,////面孔
     PHAssetCollectionSubtypeAlbumSyncedAlbum     = 5,////
     PHAssetCollectionSubtypeAlbumImported        = 6,////
     
     // PHAssetCollectionTypeAlbum shared subtypes
     PHAssetCollectionSubtypeAlbumMyPhotoStream   = 100,///
     PHAssetCollectionSubtypeAlbumCloudShared     = 101,///
     
     // PHAssetCollectionTypeSmartAlbum subtypes        //// collection.localizedTitle
     PHAssetCollectionSubtypeSmartAlbumGeneric    = 200,///
     PHAssetCollectionSubtypeSmartAlbumPanoramas  = 201,///全景照片
     PHAssetCollectionSubtypeSmartAlbumVideos     = 202,///视频
     PHAssetCollectionSubtypeSmartAlbumFavorites  = 203,///个人收藏
     PHAssetCollectionSubtypeSmartAlbumTimelapses = 204,///延时摄影
     PHAssetCollectionSubtypeSmartAlbumAllHidden  = 205,/// 已隐藏
     PHAssetCollectionSubtypeSmartAlbumRecentlyAdded = 206,///最近添加
     PHAssetCollectionSubtypeSmartAlbumBursts     = 207,///连拍快照
     PHAssetCollectionSubtypeSmartAlbumSlomoVideos = 208,///慢动作
     PHAssetCollectionSubtypeSmartAlbumUserLibrary = 209,///所有照片
     PHAssetCollectionSubtypeSmartAlbumSelfPortraits NS_AVAILABLE_IOS(9_0) = 210,///自拍
     PHAssetCollectionSubtypeSmartAlbumScreenshots NS_AVAILABLE_IOS(9_0) = 211,///屏幕快照
     = 1000000201///最近删除知道值为（1000000201）但没找到对应的TypedefName
     // Used for fetching, if you don't care about the exact subtype
     PHAssetCollectionSubtypeAny = NSIntegerMax /////所有类型
     */
    NSMutableArray *arrAlbum = [NSMutableArray array];
    for (PHFetchResult<PHAssetCollection *> *album in arrAllAlbums) {
        [album enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull collection, NSUInteger idx, BOOL *stop) {
            //过滤PHCollectionList对象
            if (![collection isKindOfClass:PHAssetCollection.class]) return;
            //过滤最近删除
            if (collection.assetCollectionSubtype > 213) return;
            //获取相册内asset result
            PHFetchResult<PHAsset *> *result = [PHAsset fetchAssetsInAssetCollection:collection options:option];
            if (!result.count) return;
            
            DPPhotoAlbumModel *model = [[DPPhotoAlbumModel alloc]init];
            model.title = collection.localizedTitle;
            model.result = result;
            model.count = result.count;
            model.headImageAsset = result.lastObject;
            
            if (collection.assetCollectionSubtype == 209) {
                [arrAlbum insertObject:model atIndex:0];
            } else {
                [arrAlbum addObject:model];
            }
        }];
    }
    
    dataSource = arrAlbum;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DPPhotoAlbumsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DPPhotoAlbumsTableViewCell"];
    
    if (!cell) {
        cell = [[DPPhotoAlbumsTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DPPhotoAlbumsTableViewCell"];
    }
    cell.model = [dataSource objectAtIndex:indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ChooseListView_Cell_Height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DPPhotoAlbumModel *model = [dataSource objectAtIndex:indexPath.row];
    DPPhotoChooseViewController *vc = [[DPPhotoChooseViewController alloc]init];
    vc.chooseViewDataSource = [[DPPhotoUtils getAssetsInFetchResult:model.result ascending:NO] mutableCopy];
    vc.maxSelectCount = self.maxSelectCount;
    vc.title = model.title;
    [self.navigationController pushViewController:vc animated:YES];
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
