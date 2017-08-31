//
//  DPPhotoBrowserCollectionViewCell.h
//  DPPhotoListViewDemo
//
//  Created by Andrew on 2017/8/23.
//  Copyright © 2017年 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SingleTapClickBlock)();

typedef void(^LongPressClickBlock)(UIImage *tempSaveImage);

@interface DPPhotoBrowserCollectionViewCell : UICollectionViewCell <UIScrollViewDelegate, UIActionSheetDelegate>

@property (nonatomic, copy) SingleTapClickBlock singleTapClickBlock;

@property (nonatomic, copy) LongPressClickBlock longPressClickBlock;

@property (nonatomic, strong) id photo;

@property (nonatomic, strong, readonly) UIImageView *photoImageView;

@end
