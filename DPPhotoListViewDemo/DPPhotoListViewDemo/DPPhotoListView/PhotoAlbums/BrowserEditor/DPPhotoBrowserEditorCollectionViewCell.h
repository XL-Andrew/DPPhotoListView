//
//  DPPhotoBrowserEditorCollectionViewCell.h
//  DPPhotoListViewDemo
//
//  Created by Andrew on 2017/9/6.
//  Copyright © 2017年 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SingleTapClickBlock)();

@interface DPPhotoBrowserEditorCollectionViewCell : UICollectionViewCell <UIScrollViewDelegate>

@property (nonatomic, copy) SingleTapClickBlock singleTapClickBlock;

@property (nonatomic, strong) id browserPhoto;

@property (nonatomic, strong, readonly) UIImageView *photoImageView;

@end
