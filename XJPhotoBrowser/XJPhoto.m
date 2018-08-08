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
@property (nonatomic, strong) UIImageView *sourceImageView;
@end

@implementation XJPhoto
+ (XJPhoto *)photoWithOrginImage:(id)image thumbImage:(UIImage *)thumbImage {
    XJPhoto *photo = [[XJPhoto alloc] init];
    photo.orginImage = image;
    photo.thumbImage = thumbImage;
    photo.sourceImageView = nil;
    return photo;
}

+ (XJPhoto *)photoWithOrginImage:(id)image sourceImageView:(UIImageView *)sourceImageView {
    XJPhoto *photo = [[XJPhoto alloc] init];
    photo.sourceImageView = sourceImageView;
    if ([sourceImageView isKindOfClass:UIImageView.class]) {
        photo.orginImage = image;
        photo.thumbImage = sourceImageView.image;
    }
    return photo;
}
@end
