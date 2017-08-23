//
//  NSObject+PerformSEL.h
//  DPPhotoListViewDemo
//
//  Created by Andrew on 2017/8/22.
//  Copyright © 2017年 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (DPPerformSEL)

- (id)performSelector:(SEL)aSelector withObjects:(NSArray *)objects;

@end
