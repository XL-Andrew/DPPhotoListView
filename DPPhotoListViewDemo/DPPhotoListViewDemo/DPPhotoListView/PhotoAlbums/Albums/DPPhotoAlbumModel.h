//
//  modelllll.h
//  DPPhotoListViewDemo
//
//  Created by Andrew on 2017/9/4.
//  Copyright © 2017年 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@interface DPPhotoAlbumModel : NSObject

@property (nonatomic, copy) NSString *title;

@property (nonatomic, assign) NSUInteger count;

@property (nonatomic, strong) PHFetchResult *result;

@property (nonatomic, strong) PHAsset *headImageAsset;

@end
