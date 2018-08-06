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
// 图片起始加载位置
@property (nonatomic, assign, readonly) CGRect sourceFrame;


/**
 创建photo对象，不带sourceFrame

 @param image 原图，不可为空，类型限定<UIImage、NSString、NSURL>
 @param thumbImage 缩略图，可为空
 @return photo对象
 */
+ (XJPhoto *)photoWithOrginImage:(id __nonnull)image thumbImage:(UIImage *__nullable)thumbImage;


/**
 创建photo对象，带sourceFrame

 @param image 原图，不可为空，类型限定<UIImage、NSString、NSURL>
 @param thumbImage 缩略图，不可为空，一般为UIImageView的image
 @param sourceFrame 图片起始加载位置，坐标为转换后的frame
 @return photo对象
 */
+ (XJPhoto *)photoWithOrginImage:(id __nonnull)image thumbImage:(UIImage *__nonnull)thumbImage sourceFrame:(CGRect)sourceFrame;

@end
