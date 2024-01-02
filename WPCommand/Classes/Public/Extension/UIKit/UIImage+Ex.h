//
//  UIImage+Ex.h
//  WPCommand
//
//  Created by WenPing on 2021/8/28.
//

#import <Foundation/Foundation.h>

@interface UIImage (Extension)

/// 获取正方向图片
- (UIImage *)wp_fixOrientation;
/// 获取图片类型
- (NSString *)wp_typeStr;

@end


