//
//  DPPhotoChooseViewCell.h
//  DPPhotoListViewDemo
//
//  Created by Andrew on 2017/9/5.
//  Copyright © 2017年 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

typedef void(^SelectedBlock)(BOOL hasSelected);

@interface DPPhotoChooseViewCell : UICollectionViewCell

@property (nonatomic, copy) SelectedBlock selectedBlock;

@property (nonatomic, assign) PHAsset *thumbnailPhoto;

@property (nonatomic, assign) BOOL isButtonSelected;

@end
