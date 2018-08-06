//
//  XJPhotoBrowserView.h
//  XJPhotoBrowser
//
//  Created by xuejian on 2018/8/2.
//  Copyright © 2018年 xuejian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XJPhotoBrowserView : UIView
@property (nonatomic,strong) UIScrollView *scrollview;
@property (nonatomic,strong) UIImageView *imageview;
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, assign) BOOL beginLoadingImage;
/**判断图片是否加载成功*/
@property (nonatomic, assign) BOOL hasLoadedImage;
@property (nonatomic,assign) CGSize zoomImageSize;
@property (nonatomic,assign) CGPoint scrollOffset;
@property (nonatomic, strong) void(^scrollViewDidScroll)(CGPoint offset);
@property (nonatomic,copy) void(^scrollViewWillEndDragging)(CGPoint velocity,CGPoint offset);//返回scrollView滚动速度
@property (nonatomic,copy) void(^scrollViewDidEndDecelerating)(void);
@property (nonatomic, assign) BOOL isFullWidthForLandScape;

//- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder;


/**
 设置图片

 @param image 图片，限定类型<UIImage、NSURL、NSString>
 @param placeholder 缩略图，可为空
 */
- (void)setImage:(id)image placeholderImage:(UIImage *)placeholder;
@end
