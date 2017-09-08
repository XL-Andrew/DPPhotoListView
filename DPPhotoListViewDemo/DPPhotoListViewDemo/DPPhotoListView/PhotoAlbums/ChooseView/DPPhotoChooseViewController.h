//
//  DPPhotoChooseViewController.h
//  DPPhotoListViewDemo
//
//  Created by Andrew on 2017/9/5.
//  Copyright © 2017年 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DPPhotoAlbumModel.h"

@interface DPPhotoChooseViewController : UIViewController

@property (nonatomic, strong) NSMutableArray *chooseViewDataSource;

/**
 最大选择张数
 */
@property (nonatomic, assign) NSUInteger maxSelectCount;

@end
