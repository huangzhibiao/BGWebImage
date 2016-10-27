//
//  UIImage+GIF.h
//  LBGIFImage
//
//  Created by Laurin Brandner on 06.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (GIF)

+ (UIImage *)sd_animatedGIFNamed:(NSString *)name;

+ (UIImage *)sd_animatedGIFWithData:(NSData *)data;

+(void)sd_animatedGIFWithData:(NSData *)data block:(void (^)(UIImage *))complete;

- (UIImage *)sd_animatedImageByScalingAndCroppingToSize:(CGSize)size;

@end
