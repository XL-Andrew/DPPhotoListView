//
//  DPPhotoListCollectionViewCell.h
//  DPPhotoListViewDemo
//
//  Created by Andrew on 2017/8/22.
//  Copyright © 2017年 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^DeleteButtonClickBlock)();

@interface DPPhotoListCollectionViewCell : UICollectionViewCell

@property (nonatomic, copy) DeleteButtonClickBlock deleteButtonClickBlock;

@property (nonatomic, strong) UIImageView *photoImageView;

@property (nonatomic, assign) BOOL showDeleteButton;

@property (nonatomic, strong) id photo;

@end
