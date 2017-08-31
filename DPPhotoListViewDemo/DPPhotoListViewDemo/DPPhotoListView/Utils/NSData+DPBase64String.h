//
//  NSData+DPBase64String.h
//  DPPhotoListViewDemo
//
//  Created by Andrew on 2017/8/31.
//  Copyright © 2017年 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (DPBase64String)

+ (nullable NSData *)dataWithBase64String:(NSString *_Nullable)base64EncodedString;

@end
