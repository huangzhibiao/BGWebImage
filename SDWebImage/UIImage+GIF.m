//
//  UIImage+GIF.m
//  LBGIFImage
//
//  Created by Laurin Brandner on 06.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIImage+GIF.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <ImageIO/ImageIO.h>

@implementation UIImage (GIF)

+ (UIImage *)sd_animatedGIFWithData:(NSData *)data {
    //NSLog(@"来了....");
    if (!data) {
        return nil;
    }

    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);

    size_t count = CGImageSourceGetCount(source);

    UIImage *animatedImage;

    if (count <= 1) {
        animatedImage = [[UIImage alloc] initWithData:data];
    }
    else {
        NSMutableArray *images = [NSMutableArray array];

        NSTimeInterval duration = 0.0f;

        for (size_t i = 0; i < count; i++) {
            CGImageRef image = CGImageSourceCreateImageAtIndex(source, i, NULL);
            if (!image) {
                continue;
            }

            duration += [self sd_frameDurationAtIndex:i source:source];

            [images addObject:[UIImage imageWithCGImage:image scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp]];

            CGImageRelease(image);
        }

        if (!duration) {
            duration = (1.0f / 10.0f) * count;
        }

        animatedImage = [UIImage animatedImageWithImages:images duration:duration];
    }

    CFRelease(source);

    return animatedImage;
}

+(void)sd_animatedGIFWithData:(NSData *)data block:(void (^)(UIImage *))complete{
    if (!data){
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage* getImage = [self sd_animatedGIFWithData:data];
        if (complete) {
            complete(getImage);
        }
    });
}

+ (float)sd_frameDurationAtIndex:(NSUInteger)index source:(CGImageSourceRef)source {
    float frameDuration = 0.1f;
    CFDictionaryRef cfFrameProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil);
    NSDictionary *frameProperties = (__bridge NSDictionary *)cfFrameProperties;
    NSDictionary *gifProperties = frameProperties[(NSString *)kCGImagePropertyGIFDictionary];

    NSNumber *delayTimeUnclampedProp = gifProperties[(NSString *)kCGImagePropertyGIFUnclampedDelayTime];
    if (delayTimeUnclampedProp) {
        frameDuration = [delayTimeUnclampedProp floatValue];
    }
    else {

        NSNumber *delayTimeProp = gifProperties[(NSString *)kCGImagePropertyGIFDelayTime];
        if (delayTimeProp) {
            frameDuration = [delayTimeProp floatValue];
        }
    }

    // Many annoying ads specify a 0 duration to make an image flash as quickly as possible.
    // We follow Firefox's behavior and use a duration of 100 ms for any frames that specify
    // a duration of <= 10 ms. See <rdar://problem/7689300> and <http://webkit.org/b/36082>
    // for more information.

    if (frameDuration < 0.011f) {
        frameDuration = 0.100f;
    }

    CFRelease(cfFrameProperties);
    return frameDuration;
}

+ (UIImage *)sd_animatedGIFNamed:(NSString *)name {
    CGFloat scale = [UIScreen mainScreen].scale;

    if (scale > 1.0f) {
        NSString *retinaPath = [[NSBundle mainBundle] pathForResource:[name stringByAppendingString:@"@2x"] ofType:@"gif"];

        NSData *data = [NSData dataWithContentsOfFile:retinaPath];

        if (data) {
            return [UIImage sd_animatedGIFWithData:data];
        }

        NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"gif"];

        data = [NSData dataWithContentsOfFile:path];

        if (data) {
            return [UIImage sd_animatedGIFWithData:data];
        }

        return [UIImage imageNamed:name];
    }
    else {
        NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"gif"];

        NSData *data = [NSData dataWithContentsOfFile:path];

        if (data) {
            return [UIImage sd_animatedGIFWithData:data];
        }

        return [UIImage imageNamed:name];
    }
}

- (UIImage *)sd_animatedImageByScalingAndCroppingToSize:(CGSize)size {
    if (CGSizeEqualToSize(self.size, size) || CGSizeEqualToSize(size, CGSizeZero)) {
        return self;
    }

    CGSize scaledSize = size;
    CGPoint thumbnailPoint = CGPointZero;

    CGFloat widthFactor = size.width / self.size.width;
    CGFloat heightFactor = size.height / self.size.height;
    CGFloat scaleFactor = (widthFactor > heightFactor) ? widthFactor : heightFactor;
    scaledSize.width = self.size.width * scaleFactor;
    scaledSize.height = self.size.height * scaleFactor;

    if (widthFactor > heightFactor) {
        thumbnailPoint.y = (size.height - scaledSize.height) * 0.5;
    }
    else if (widthFactor < heightFactor) {
        thumbnailPoint.x = (size.width - scaledSize.width) * 0.5;
    }

    NSMutableArray *scaledImages = [NSMutableArray array];

    for (UIImage *image in self.images) {
        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
        
        [image drawInRect:CGRectMake(thumbnailPoint.x, thumbnailPoint.y, scaledSize.width, scaledSize.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();

        [scaledImages addObject:newImage];

        UIGraphicsEndImageContext();
    }
 
    return [UIImage animatedImageWithImages:scaledImages duration:self.duration];
}

////重构部分 －－ 黄芝标
//+ (UIImage *)sd_animatedGIFWithData:(NSData *)data{
//    NSLog(@"重构完成测试 -- 芝标");
//    return [self imageWithData:data];
//}
//
//+ (id)imageWithData:(NSData *)data
//{
//    return [self imageWithData:data scale:[UIScreen mainScreen].scale];
//}
//
//+ (id)imageWithData:(NSData *)data scale:(CGFloat)scale
//{
//    if (!data) {
//        return nil;
//    }
//    
//    CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)(data), NULL);
//    UIImage *image;
//    
//    if (CGImageSourceContainsAnimatedGif(imageSource)) {
//        image = [[self alloc] initWithCGImageSource:imageSource scale:scale];
//    } else {
//        image = [UIImage imageWithData:data scale:scale];
//    }
//    
//    if (imageSource) {
//        CFRelease(imageSource);
//        imageSource = nil;
//    }
//    
//    return image;
//}
//
//- (id)initWithCGImageSource:(CGImageSourceRef)imageSource scale:(CGFloat)scale
//{
//    if (!imageSource) {
//        return nil;
//    }
//    
//    CFRetain(imageSource);
//    
//    NSUInteger numberOfFrames = CGImageSourceGetCount(imageSource);
//    
////    NSDictionary *imageProperties = CFBridgingRelease(CGImageSourceCopyProperties(imageSource, NULL));
////    NSDictionary *gifProperties = [imageProperties objectForKey:(NSString *)kCGImagePropertyGIFDictionary];
//    
//    NSTimeInterval totalDuration;
////    NSTimeInterval* frameDurations = (NSTimeInterval *)malloc(numberOfFrames  * sizeof(NSTimeInterval));
////    NSInteger loopCount = [gifProperties[(NSString *)kCGImagePropertyGIFLoopCount] unsignedIntegerValue];
////    self.images = [NSMutableArray arrayWithCapacity:numberOfFrames];
//    NSMutableArray* images = [NSMutableArray array];
//    NSNull *aNull = [NSNull null];
//    for (NSUInteger i = 0; i < numberOfFrames; ++i) {
//        [images addObject:aNull];
//        NSTimeInterval frameDuration = CGImageSourceGetGifFrameDelay(imageSource, i);
//        //frameDurations[i] = frameDuration;
//        totalDuration += frameDuration;
//    }
//    //CFTimeInterval start = CFAbsoluteTimeGetCurrent();
//    // Load first frame
//    //NSUInteger num = MIN(_prefetchedNum, numberOfFrames);
//    for (int i=0; i<numberOfFrames; i++) {
//        CGImageRef image = CGImageSourceCreateImageAtIndex(imageSource, i, NULL);
//        [images replaceObjectAtIndex:i withObject:[UIImage imageWithCGImage:image scale:scale orientation:UIImageOrientationUp]];
//        CFRelease(image);
//    }
//    //_imageSourceRef = imageSource;
//    //CFRetain(_imageSourceRef);
//    CFRelease(imageSource);
//    //});
//    
//    //_scale = scale;
//    //readFrameQueue = dispatch_queue_create("com.ronnie.gifreadframe", DISPATCH_QUEUE_SERIAL);
//    
//    return [UIImage animatedImageWithImages:images duration:totalDuration];
//}
//
//
//inline static BOOL CGImageSourceContainsAnimatedGif(CGImageSourceRef imageSource)
//{
//    return imageSource && UTTypeConformsTo(CGImageSourceGetType(imageSource), kUTTypeGIF) && CGImageSourceGetCount(imageSource) > 1;
//}
//
//inline static NSTimeInterval CGImageSourceGetGifFrameDelay(CGImageSourceRef imageSource, NSUInteger index)
//{
//    NSTimeInterval frameDuration = 0;
//    CFDictionaryRef theImageProperties;
//    if ((theImageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, index, NULL))) {
//        CFDictionaryRef gifProperties;
//        if (CFDictionaryGetValueIfPresent(theImageProperties, kCGImagePropertyGIFDictionary, (const void **)&gifProperties)) {
//            const void *frameDurationValue;
//            if (CFDictionaryGetValueIfPresent(gifProperties, kCGImagePropertyGIFUnclampedDelayTime, &frameDurationValue)) {
//                frameDuration = [(__bridge NSNumber *)frameDurationValue doubleValue];
//                if (frameDuration <= 0) {
//                    if (CFDictionaryGetValueIfPresent(gifProperties, kCGImagePropertyGIFDelayTime, &frameDurationValue)) {
//                        frameDuration = [(__bridge NSNumber *)frameDurationValue doubleValue];
//                    }
//                }
//            }
//        }
//        CFRelease(theImageProperties);
//    }
//    
//#ifndef OLExactGIFRepresentation
//    //Implement as Browsers do.
//    //See:  http://nullsleep.tumblr.com/post/16524517190/animated-gif-minimum-frame-delay-browser-compatibility
//    //Also: http://blogs.msdn.com/b/ieinternals/archive/2010/06/08/animated-gifs-slow-down-to-under-20-frames-per-second.aspx
//    
//    if (frameDuration < 0.02 - FLT_EPSILON) {
//        frameDuration = 0.1;
//    }
//#endif
//    return frameDuration;
//}

@end
