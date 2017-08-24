//
//  ViewController.m
//  DPPhotoListViewDemo
//
//  Created by Andrew on 2017/8/23.
//  Copyright © 2017年 Andrew. All rights reserved.
//

#import "ViewController.h"

// step 1
#import "DPPhotoLibrary.h"

@interface ViewController () <DPPhotoListViewDelegate> //step 2
{
    DPPhotoListView *photoListView;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 20, 64, 40);
    button.backgroundColor = [UIColor greenColor];
    [button setTitle:@"编辑" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    //step 3
    //拼接数据源 使用DPPhotoModel进行管理
    NSArray *urlArray = @[@"http://pic1.win4000.com/wallpaper/b/58b6b658bdf15.jpg",
                          @"http://img.pconline.com.cn/images/upload/upc/tx/wallpaper/1207/05/c0/12233333_1341470829710.jpg",
                          @"http://pic1.win4000.com/wallpaper/1/58ae83b9b4538.jpg",
                          @"http://pic1.win4000.com/wallpaper/1/58d86dc4246e8.jpg",
                          @"http://pic1.win4000.com/wallpaper/0/587c355dc3292.jpg",
                          @"http://pic1.win4000.com/wallpaper/1/58d47bfeebebf.jpg",
                          @"http://pic1.win4000.com/wallpaper/7/58b66db8cf6d9.jpg",
                          @"http://pic1.win4000.com/wallpaper/9/58d5e2ccbdce9.jpg",
                          @"http://pic1.win4000.com/wallpaper/d/589ea2dd5870c.jpg",
                          @"localPic"];


    //stpe 4 (竖列表展示方式)
    photoListView = [[DPPhotoListView alloc]initWithFrame:CGRectMake(0, 64 + 20, self.view.bounds.size.width, SCREEN_HEIGHT - 64 - 20) numberOfCellInRow:3 lineSpacing:15 dataSource:[urlArray mutableCopy]];
    photoListView.showAddImagesButton = YES;
    photoListView.delegate = self;
    [self.view addSubview:photoListView];
    
    //step 4 (横列表展示方式)
//    photoListView = [[DPPhotoListView alloc]initWithFrame:CGRectMake(0, 64 + 20, self.view.bounds.size.width, 100) numberOfCellInRow:3 lineSpacing:15 dataSource:[urlArray mutableCopy]];
//    photoListView.showAddImagesButton = YES;
//    photoListView.photoScrollDirection = DPPhotoScrollDirectionHorizontal;
//    photoListView.delegate = self;
//    [self.view addSubview:photoListView];
    
}

- (void)click:(UIButton *)sender
{
    //step 5
    //点击编辑图片按钮
    [photoListView editPhoto];
}

//step 6 代理方法
#pragma mark -  DPPhotoListViewDelegate
- (void)choosePhotoWithPhotoBase64String:(NSString *)base64String
{
    //选择图片后返回base64编码格式数据，便于上传
    NSLog(@"上传图片");
}

- (void)deletedPhotoAtIndex:(NSUInteger)index
{
    NSLog(@"删除了第%ld个图片",index);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
