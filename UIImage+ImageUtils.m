//
//  UIImage+ImageUtils.m
//  twttr
//
//  Created by Brian Donohue on 7/22/15.
//
//

#import "UIImage+ImageUtils.h"

@implementation UIImage (ImageUtils)

+ (UIImage *)maskedImageNamed:(NSString *)name color:(UIColor *)color {
    UIImage *image = [UIImage imageNamed:name];
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, image.scale);
    CGContextRef c = UIGraphicsGetCurrentContext();
    [image drawInRect:rect];
    CGContextSetFillColorWithColor(c, [color CGColor]);
    CGContextSetBlendMode(c, kCGBlendModeSourceAtop);
    CGContextFillRect(c, rect);
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

@end
