//
//  DPPhotoLibrary.h
//  DPPhotoListViewDemo
//
//  Created by Andrew on 2017/8/22.
//  Copyright © 2017年 Andrew. All rights reserved.
//

#ifndef DPPhotoLibrary_h
#define DPPhotoLibrary_h

#import "DPPhotoListView.h"

#import "NSObject+DPPerformSEL.h"

#import "UIView+DPCategory.h"

#import "DPPhotoUtils.h"

//占位图
#define Placeholder_Image [UIImage imageNamed:@"DPPhoto_library_holdImage"]

//屏幕宽高
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000

#define SCREEN_WIDTH ([[UIScreen mainScreen] respondsToSelector:@selector(nativeBounds)]?[UIScreen mainScreen].nativeBounds.size.width/[UIScreen mainScreen].nativeScale:[UIScreen mainScreen].bounds.size.width)

#define SCREEN_HEIGHT ([[UIScreen mainScreen] respondsToSelector:@selector(nativeBounds)]?[UIScreen mainScreen].nativeBounds.size.height/[UIScreen mainScreen].nativeScale:[UIScreen mainScreen].bounds.size.height)

#else

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#endif

#define RGB_COLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

#endif /* DPPhotoLibrary_h */
