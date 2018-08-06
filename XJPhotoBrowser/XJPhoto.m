//
//  XJPhoto.m
//  XJPhotoBrowser
//
//  Created by xuejian on 2018/8/2.
//  Copyright © 2018年 xuejian. All rights reserved.
//

#import "XJPhoto.h"

@interface XJPhoto ()
@property (nonatomic, strong) UIImage *thumbImage;
@property (nonatomic, strong) id orginImage;
@property (nonatomic, assign) CGRect sourceFrame;
@end

@implementation XJPhoto
+ (XJPhoto *)photoWithOrginImage:(id)image thumbImage:(UIImage *)thumbImage {
    XJPhoto *photo = [[XJPhoto alloc] init];
    photo.orginImage = image;
    photo.thumbImage = thumbImage;
    photo.sourceFrame = CGRectZero;
    return photo;
}

+ (XJPhoto *)photoWithOrginImage:(id)image thumbImage:(UIImage *)thumbImage sourceFrame:(CGRect)sourceFrame {
    XJPhoto *photo = [[XJPhoto alloc] init];
    photo.orginImage = image;
    photo.thumbImage = thumbImage;
    photo.sourceFrame = sourceFrame;
    return photo;
}
@end
