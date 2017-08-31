//
//  UIScrollView+DPTouchEvent.m
//  DPPhotoListViewDemo
//
//  Created by Andrew on 2017/8/31.
//  Copyright © 2017年 Andrew. All rights reserved.
//

#import "UIScrollView+DPTouchEvent.h"

@implementation UIScrollView (DPTouchEvent)

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[self nextResponder] touchesBegan:touches withEvent:event];
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[self nextResponder] touchesMoved:touches withEvent:event];
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[self nextResponder] touchesEnded:touches withEvent:event];
    [super touchesEnded:touches withEvent:event];
}

@end
