//
//  UIViewController+BackButtonHandler.h
//  DPPhotoListViewDemo
//
//  Created by Andrew on 2017/9/8.
//  Copyright © 2017年 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BackButtonHandlerProtocol <NSObject>
@optional

- (BOOL)navigationShouldPopOnBackButton;

@end

@interface UIViewController (BackButtonHandler) <BackButtonHandlerProtocol>

@end
