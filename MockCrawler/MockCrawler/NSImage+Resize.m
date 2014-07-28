//
//  NSImage+Resize.m
//  MockCrawler
//
//  Created by Mike Bernardo on 12/11/13.
//  Copyright (c) 2013 Mike Bernardo. All rights reserved.
//

#import "NSImage+Resize.h"

@implementation NSImage (Resize)

- (NSImage *)resizedImage:(CGSize)newSize
                transform:(CGAffineTransform)transform
           drawTransposed:(BOOL)transpose
     interpolationQuality:(CGInterpolationQuality)quality {
    
    CGRect newRect;
    newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
    CGRect transposedRect = CGRectMake(0, 0, newRect.size.height, newRect.size.width);
    CGImageRef imageRef = self.CGImage;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    
    // Build a context that's the same dimensions as the new size
    CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                                newRect.size.width,
                                                newRect.size.height,
                                                8,
                                                0,
                                                colorSpace,
                                                kCGImageAlphaPremultipliedFirst);
    
    CGColorSpaceRelease(colorSpace);
    
    // Rotate and/or flip the image if required by its orientation
    CGContextConcatCTM(bitmap, transform);
    
    // Set the quality level to use when rescaling
    CGContextSetInterpolationQuality(bitmap, quality);
    
    // Draw into the context; this scales the image
    CGContextDrawImage(bitmap, transpose ? transposedRect : newRect, imageRef);
    
    // Get the resized image from the context and a UIImage
    CGImageRef newImageRef = CGBitmapContextCreateImage(bitmap);
    UIImage *newImage;
    if ([self respondsToSelector:@selector(scale)] && [UIImage respondsToSelector:@selector(imageWithCGImage:scale:orientation:)]) {
    	newImage = [UIImage imageWithCGImage:newImageRef scale:self.scale orientation:self.imageOrientation];
    } else {
    	newImage = [UIImage imageWithCGImage:newImageRef];
    }
    
    
    // Clean up
    CGContextRelease(bitmap);
    CGImageRelease(newImageRef);
    
    return newImage;
}
@end
