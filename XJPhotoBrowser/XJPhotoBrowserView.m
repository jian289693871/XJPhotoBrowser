//
//  XJPhotoBrowserView.m
//  XJPhotoBrowser
//
//  Created by xuejian on 2018/8/2.
//  Copyright © 2018年 xuejian. All rights reserved.
//

#import "XJPhotoBrowserView.h"
#import "XJWaitingView.h"
#if __has_include(<YYWebImage/YYWebImage.h>)
#import <YYWebImage/YYWebImage.h>
#else
#import "YYWebImage.h"
#endif

#define kMinZoomScale 0.6f
#define kMaxZoomScale 2.0f

@interface XJPhotoBrowserView() <UIScrollViewDelegate>
@property (nonatomic,strong) XJWaitingView *waitingView;
@property (nonatomic, strong) NSURL *imageUrl;
@property (nonatomic, strong) UIImage *placeHolderImage;
@property (nonatomic, strong) UIButton *reloadButton;
@end

@implementation XJPhotoBrowserView
#pragma mark recyle
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.scrollview];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat selfW = self.bounds.size.width;
    CGFloat selfH = self.bounds.size.height;
    _waitingView.center = CGPointMake(selfW * 0.5, selfH * 0.5);
    _scrollview.frame = self.bounds;
    CGFloat reloadBtnW = 200;
    CGFloat reloadBtnH = 40;
    _reloadButton.frame = CGRectMake((selfW - reloadBtnW)*0.5, (selfH - reloadBtnH)*0.5, reloadBtnW, reloadBtnH);
    [self adjustFrame];
}

#pragma mark getter setter
- (UIScrollView *)scrollview
{
    if (!_scrollview) {
        _scrollview = [[UIScrollView alloc] init];
        _scrollview.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
        _scrollview.showsVerticalScrollIndicator = NO;
        _scrollview.showsHorizontalScrollIndicator = NO;
        [_scrollview addSubview:self.imageview];
        _scrollview.delegate = self;
        _scrollview.clipsToBounds = YES;
    }
    return _scrollview;
}

- (UIImageView *)imageview
{
    if (!_imageview) {
        _imageview = [[UIImageView alloc] init];
        _imageview.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
        _imageview.userInteractionEnabled = YES;
    }
    return _imageview;
}

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    _waitingView.progress = progress;
}

#pragma mark public methods
- (void)setImage:(id)image placeholderImage:(UIImage *)placeholder {
    if (_reloadButton) [_reloadButton removeFromSuperview];
    
    if ([image isKindOfClass:UIImage.class]) {
        _imageview.image = image;
        [self setNeedsLayout];
        self.hasLoadedImage = YES;//图片加载成功
        return;
    } else {
        if ([image isKindOfClass:NSString.class]) {
            _imageUrl = [NSURL URLWithString:image];
        } else if ([image isKindOfClass:NSURL.class]) {
            _imageUrl = image;
        } else {
            if (!placeholder) {
                _imageUrl = nil;
                self.hasLoadedImage = NO;//图片加载失败
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                self.reloadButton = button;
                button.layer.cornerRadius = 2;
                button.clipsToBounds = YES;
                button.titleLabel.font = [UIFont systemFontOfSize:14];
                button.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.3f];
                [button setTitle:@"图片加载失败" forState:UIControlStateNormal];
                [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [self addSubview:button];
                return;
            }
        }
        
        _placeHolderImage = placeholder;
        //添加进度指示器
        XJWaitingView *waitingView = [[XJWaitingView alloc] init];
        waitingView.mode = XJWaitingViewModeLoopDiagram;
        waitingView.center = CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height * 0.5);
        self.waitingView = waitingView;
        [self addSubview:waitingView];
        
        //XJWebImage加载图片
        __weak __typeof(self)weakSelf = self;
        __weak __typeof(XJWaitingView) *weakWaitingView = waitingView;
        [_imageview yy_setImageWithURL:_imageUrl placeholder:placeholder options:YYWebImageOptionProgressiveBlur|YYWebImageOptionSetImageWithFadeAnimation progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            //在主线程做UI更新
            dispatch_async(dispatch_get_main_queue(), ^{
                strongSelf.waitingView.progress = (CGFloat)receivedSize / expectedSize;
            });
        } transform:NULL completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            __strong __typeof(XJWaitingView) *strongWaitingView = weakWaitingView;
            [strongWaitingView removeFromSuperview];
            
            if (error) {
                //图片加载失败的处理，此处可以自定义各种操作（...）
                strongSelf.hasLoadedImage = NO;//图片加载失败
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                strongSelf.reloadButton = button;
                button.layer.cornerRadius = 2;
                button.clipsToBounds = YES;
                button.titleLabel.font = [UIFont systemFontOfSize:14];
                button.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.3f];
                [button setTitle:@"图片加载失败，点击重新加载" forState:UIControlStateNormal];
                [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [button addTarget:strongSelf action:@selector(reloadImage) forControlEvents:UIControlEventTouchUpInside];
                
                [self addSubview:button];
                return;
            }
            //加载成功重新计算frame,解决长图可能显示不正确的问题
            [self setNeedsLayout];
            strongSelf.hasLoadedImage = YES;//图片加载成功
        }];
    }
}

#pragma mark private methods
- (void)reloadImage {
    [self setImage:_imageUrl placeholderImage:_placeHolderImage];
}

- (void)adjustFrame {
    //    CGRect frame = self.scrollview.frame;
    CGRect frame = self.frame;
    //   NSLog(@"%@",NSStringFromCGRect(self.frame));
    if (self.imageview.image) {
        CGSize imageSize = self.imageview.image.size;//获得图片的size
        CGRect imageFrame = CGRectMake(0, 0, imageSize.width, imageSize.height);
        if (_isFullWidthForLandScape) {//图片宽度始终==屏幕宽度(新浪微博就是这种效果)
            CGFloat ratio = frame.size.width/imageFrame.size.width;
            imageFrame.size.height = imageFrame.size.height*ratio;
            imageFrame.size.width = frame.size.width;
        } else{
            if (frame.size.width<=frame.size.height) {
                //竖屏时候
                CGFloat ratio = frame.size.width/imageFrame.size.width;
                imageFrame.size.height = imageFrame.size.height*ratio;
                imageFrame.size.width = frame.size.width;
            }else{ //横屏的时候
                CGFloat ratio = frame.size.height/imageFrame.size.height;
                imageFrame.size.width = imageFrame.size.width*ratio;
                imageFrame.size.height = frame.size.height;
            }
        }
        
        self.imageview.frame = imageFrame;
        self.scrollview.contentSize = self.imageview.frame.size;
        self.imageview.center = [self centerOfScrollViewContent:self.scrollview];
        
        //根据图片大小找到最大缩放等级，保证最大缩放时候，不会有黑边
        CGFloat maxScale = frame.size.height/imageFrame.size.height;
        maxScale = frame.size.width/imageFrame.size.width>maxScale?frame.size.width/imageFrame.size.width:maxScale;
        //超过了设置的最大的才算数
        maxScale = maxScale>kMaxZoomScale?maxScale:kMaxZoomScale;
        //初始化
        self.scrollview.minimumZoomScale = kMinZoomScale;
        self.scrollview.maximumZoomScale = maxScale;
        self.scrollview.zoomScale = 1.0f;
    }else{
        frame.origin = CGPointZero;
        self.imageview.frame = frame;
        //重置内容大小
        self.scrollview.contentSize = self.imageview.frame.size;
    }
    self.scrollview.contentOffset = CGPointZero;
    self.zoomImageSize = self.imageview.frame.size;
}

- (CGPoint)centerOfScrollViewContent:(UIScrollView *)scrollView {
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    CGPoint actualCenter = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                       scrollView.contentSize.height * 0.5 + offsetY);
    return actualCenter;
}

#pragma mark UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageview;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
    self.zoomImageSize = view.frame.size;
    self.scrollOffset = scrollView.contentOffset;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if(self.scrollViewWillEndDragging) {
        self.scrollViewWillEndDragging(velocity, scrollView.contentOffset);
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (self.scrollViewDidEndDecelerating) {
        self.scrollViewDidEndDecelerating();
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    //这里是缩放进行时调整
    self.imageview.center = [self centerOfScrollViewContent:scrollView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    self.scrollOffset = scrollView.contentOffset;
    if (self.scrollViewDidScroll) {
        self.scrollViewDidScroll(self.scrollOffset);
    }
}
@end

