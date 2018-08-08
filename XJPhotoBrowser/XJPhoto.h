//
//  XJPhoto.h
//  XJPhotoBrowser
//
//  Created by xuejian on 2018/8/2.
//  Copyright © 2018年 xuejian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XJPhoto : NSObject
// 缩略图，可为空
@property (nonatomic, strong, readonly) UIImage *thumbImage;
// 原图，不可为空，类型限定<UIImage、NSString、NSURL>
@property (nonatomic, strong, readonly) id orginImage;
// 起始图片
@property (nonatomic, strong, readonly) UIImageView *sourceImageView;

/**
 创建photo对象，不带sourceFrame

 @param image 原图，不可为空，类型限定<UIImage、NSString、NSURL>
 @param thumbImage 缩略图，可为空
 @return photo对象
 */
+ (XJPhoto *)photoWithOrginImage:(id __nonnull)image thumbImage:(UIImage *__nullable)thumbImage;


/**
 创建photo对象，带sourceImageView

 @param image 原图，不可为空，类型限定<UIImage、NSString、NSURL>
 @param sourceImageView 起始图片的view
 @return photo对象
 */
+ (XJPhoto *)photoWithOrginImage:(id __nonnull)image sourceImageView:(UIImageView *__nullable)sourceImageView;

@end
