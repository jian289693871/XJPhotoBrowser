//
//  XJPhotoBrowser.m
//  XJPhotoBrowser
//
//  Created by xuejian on 2018/8/2.
//  Copyright © 2018年 xuejian. All rights reserved.
//

#import "XJPhotoBrowser.h"
#import "XJPhotoBrowserView.h"

#define kAPPWidth [UIScreen mainScreen].bounds.size.width
#define KAppHeight [UIScreen mainScreen].bounds.size.height

#define iPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)
//状态栏高度，iphoneX->44 其他 20
#define kStatusBar_Height [UIApplication sharedApplication].statusBarFrame.size.height
//底部安全距离 iphoneX->34 其他 0
#define kBottomSafeHeight (iPhoneX?34.0f:0.0f)

#define XJPhotoBrowserImageViewMargin 10
#define kRotateAnimationDuration 0.35f
#define XJPhotoBrowserShowImageAnimationDuration 0.25f
#define XJPhotoBrowserHideImageAnimationDuration 0.25f

@interface XJPhotoBrowser()
@property (nonatomic,strong) UITapGestureRecognizer *singleTap;
@property (nonatomic,strong) UITapGestureRecognizer *doubleTap;
@property (nonatomic,strong) UIPanGestureRecognizer *pan;
@property (nonatomic,strong) UIImageView *tempView;
@property (nonatomic,strong) UIView *coverView;
@property (nonatomic,strong) UILabel *tipLabel;
@property (nonatomic,strong) XJPhotoBrowserView *photoBrowserView;
@property (nonatomic,assign) UIDeviceOrientation orientation;
@property (nonatomic,strong) UIView *contentView;

@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,assign) BOOL hasShowedFistView;
@property (nonatomic,strong) UILabel *indexLabel;
@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, assign) NSInteger photoCount;
@end
@implementation XJPhotoBrowser

#pragma mark recyle
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.isFullWidthForLandScape = YES;
        self.isNeedLandscape = NO;
    }
    return self;
}

//当视图移动完成后调用
- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    _currentPhotoIndex = _currentPhotoIndex < 0 ? 0 : _currentPhotoIndex;
    NSInteger count = _photoCount - 1;
    if (count > 0) {
        if (_currentPhotoIndex > count) {
            _currentPhotoIndex = 0;
        }
    }
    [self setupScrollView];
    [self setupToolbars];
    [self addGestureRecognizer:self.singleTap];
    [self addGestureRecognizer:self.doubleTap];
    [self addGestureRecognizer:self.pan];
    self.photoBrowserView = _scrollView.subviews[self.currentPhotoIndex];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    //    NSLog(@"layoutSubviews -- ");
    CGRect rect = self.bounds;
    rect.size.width += XJPhotoBrowserImageViewMargin * 2;
    _scrollView.bounds = rect;
    _scrollView.center = CGPointMake(self.bounds.size.width *0.5, self.bounds.size.height *0.5);
    CGFloat y = 0;
    __block CGFloat w = _scrollView.frame.size.width - XJPhotoBrowserImageViewMargin * 2;
    CGFloat h = _scrollView.frame.size.height;
    [_scrollView.subviews enumerateObjectsUsingBlock:^(XJPhotoBrowserView *obj, NSUInteger idx, BOOL *stop) {
        CGFloat x = XJPhotoBrowserImageViewMargin + idx * (XJPhotoBrowserImageViewMargin * 2 + w);
        obj.frame = CGRectMake(x, y, w, h);
    }];
    
    _scrollView.contentSize = CGSizeMake(_scrollView.subviews.count * _scrollView.frame.size.width, _scrollView.frame.size.height);
    _scrollView.contentOffset = CGPointMake(self.currentPhotoIndex * _scrollView.frame.size.width, 0);
    
    
    if (!_hasShowedFistView) {
        [self showFirstImage];
    }
    _indexLabel.bounds = CGRectMake(0, 0, 80, 30);
    _indexLabel.center = CGPointMake(self.bounds.size.width * 0.5, 30);
    _saveButton.frame = CGRectMake(self.bounds.size.width - 80, self.bounds.size.height - 50, 55, 30);
    _tipLabel.frame = CGRectMake((self.bounds.size.width - 150)*0.5, (self.bounds.size.height - 40)*0.5, 150, 40);
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)setPhotos:(NSArray<XJPhoto *> *)photos {
    _photos = photos;
    _photoCount = photos.count;
}

#pragma mark getter settter
- (UITapGestureRecognizer *)singleTap {
    if (!_singleTap) {
        _singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoClick:)];
        _singleTap.numberOfTapsRequired = 1;
        _singleTap.delaysTouchesBegan = YES;
        [_singleTap requireGestureRecognizerToFail:self.doubleTap];
    }
    return _singleTap;
}

- (UITapGestureRecognizer *)doubleTap {
    if (!_doubleTap) {
        _doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        _doubleTap.numberOfTapsRequired = 2;
    }
    return _doubleTap;
}

- (UIPanGestureRecognizer *)pan{
    if (!_pan) {
        _pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPan:)];
    }
    return _pan;
}


- (UIImageView *)tempView{
    if (!_tempView) {
        XJPhotoBrowserView *photoBrowserView = _scrollView.subviews[self.currentPhotoIndex];
        UIImageView *currentImageView = photoBrowserView.imageview;
        CGFloat tempImageX = currentImageView.frame.origin.x - photoBrowserView.scrollOffset.x;
        CGFloat tempImageY = currentImageView.frame.origin.y - photoBrowserView.scrollOffset.y;
        
        CGFloat tempImageW = photoBrowserView.zoomImageSize.width;
        CGFloat tempImageH = photoBrowserView.zoomImageSize.height;
        UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
        if (UIDeviceOrientationIsLandscape(orientation)) {//横屏
            
            //处理长图,图片太长会导致旋转动画飞掉
            if (tempImageH > KAppHeight) {
                tempImageH = tempImageH > (tempImageW * 1.5)? (tempImageW * 1.5):tempImageH;
                if (fabs(tempImageY) > tempImageH) {
                    tempImageY = 0;
                }
            }
            
        }
        
        _tempView = [[UIImageView alloc] init];
        //这边的contentmode要跟 XJPhotoGrop里面的按钮的 contentmode保持一致（防止最后出现闪动的动画）
        _tempView.contentMode = UIViewContentModeScaleAspectFill;
        _tempView.clipsToBounds = YES;
        _tempView.frame = CGRectMake(tempImageX, tempImageY, tempImageW, tempImageH);
        _tempView.image = currentImageView.image;
    }
    return _tempView;
}

//做颜色渐变动画的view，让退出动画更加柔和
- (UIView *)coverView{
    if (!_coverView) {
        _coverView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _coverView.backgroundColor = [UIColor blackColor];
    }
    return _coverView;
}

- (void)setPhotoBrowserView:(XJPhotoBrowserView *)photoBrowserView{
    _photoBrowserView = photoBrowserView;
    __weak typeof(self) weakSelf = self;
    _photoBrowserView.scrollViewWillEndDragging = ^(CGPoint velocity,CGPoint offset) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (((velocity.y < -2 && offset.y < 0) || offset.y < -100)) {
            [strongSelf hidePhotoBrowser];
        }
    };
}


- (void)setCurrentPhotoIndex:(int)currentPhotoIndex{
    _currentPhotoIndex = currentPhotoIndex < 0 ? 0 : currentPhotoIndex;
    NSInteger count0 = _photoCount;
    NSInteger count1 = _photos.count;
    if (count0 > 0) {
        if (_currentPhotoIndex > count0) {
            _currentPhotoIndex = 0;
        }
    }
    if (count1 > 0) {
        if (_currentPhotoIndex > count1) {
            _currentPhotoIndex = 0;
        }
    }
}

#pragma mark private methods
- (void)setupToolbars {
    // 1. 序标
    UILabel *indexLabel = [[UILabel alloc] init];
    indexLabel.textAlignment = NSTextAlignmentCenter;
    indexLabel.textColor = [UIColor whiteColor];
    indexLabel.font = [UIFont boldSystemFontOfSize:20];
    indexLabel.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.3f];
    indexLabel.bounds = CGRectMake(0, 0, 80, 30);
    indexLabel.center = CGPointMake(kAPPWidth * 0.5, 30);
    indexLabel.layer.cornerRadius = 15;
    indexLabel.clipsToBounds = YES;
    if (self.photoCount > 1) {
        indexLabel.text = [NSString stringWithFormat:@"1/%ld", (long)self.photoCount];
        _indexLabel = indexLabel;
        [self addSubview:indexLabel];
    }
    
    // 2.保存按钮
    UIButton *saveButton = [[UIButton alloc] init];
    [saveButton setTitle:@"保存" forState:UIControlStateNormal];
    [saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    saveButton.layer.borderWidth = 0.1;
    saveButton.layer.borderColor = [UIColor whiteColor].CGColor;
    saveButton.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.3f];
    saveButton.layer.cornerRadius = 2;
    saveButton.clipsToBounds = YES;
    [saveButton addTarget:self action:@selector(saveImage) forControlEvents:UIControlEventTouchUpInside];
    _saveButton = saveButton;
    [self addSubview:saveButton];
}

//保存图像
- (void)saveImage {
    int index = _scrollView.contentOffset.x / _scrollView.bounds.size.width;
    XJPhotoBrowserView *currentView = _scrollView.subviews[index];
    if (currentView.hasLoadedImage) {
        UIImageWriteToSavedPhotosAlbum(currentView.imageview.image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    } else {
        [self showTip:NSLocalizedString(@" 保存失败 ", nil)];
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        [self showTip:NSLocalizedString(@" 保存失败 ", nil)];
    } else {
        [self showTip:NSLocalizedString(@" 保存成功 ", nil)];
    }
}

- (void)showTip:(NSString *)tipStr {
    if (_tipLabel) {
        [_tipLabel removeFromSuperview];
        _tipLabel = nil;
    }
    UILabel *label = [[UILabel alloc] init];
    _tipLabel = label;
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.90f];
    label.layer.cornerRadius = 5;
    label.clipsToBounds = YES;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:20];
    label.text = tipStr;
    [self addSubview:label];
    [label performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:1.0];
}

- (void)setupScrollView {
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.delegate = self;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.pagingEnabled = YES;
    [self addSubview:_scrollView];
    for (int i = 0; i < self.photoCount; i++) {
        XJPhotoBrowserView *view = [[XJPhotoBrowserView alloc] init];
        view.isFullWidthForLandScape = self.isFullWidthForLandScape;
        view.imageview.tag = i;
        [_scrollView addSubview:view];
    }
    [self setupImageOfImageViewForIndex:self.currentPhotoIndex];
}

// 加载图片
- (void)setupImageOfImageViewForIndex:(NSInteger)index {
    XJPhotoBrowserView *view = _scrollView.subviews[index];
    if (view.beginLoadingImage) return;
    
    XJPhoto *photo = self.photos[index];
    [view setImage:photo.orginImage placeholderImage:photo.thumbImage];
    view.beginLoadingImage = YES;
}

- (void)onDeviceOrientationChangeWithObserver {
    [self onDeviceOrientationChange];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDeviceOrientationChange) name:UIDeviceOrientationDidChangeNotification object:nil];
}

-(void)onDeviceOrientationChange {
    if (!self.isNeedLandscape) {
        return;
    }
    
    XJPhotoBrowserView *currentView = _scrollView.subviews[self.currentPhotoIndex];
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    self.orientation = orientation;
    if (UIDeviceOrientationIsLandscape(orientation)) {
        if (self.bounds.size.width < self.bounds.size.height) {
            [currentView.scrollview setZoomScale:1.0 animated:YES];//还原
        }
        [UIView animateWithDuration:kRotateAnimationDuration delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.transform = (orientation==UIDeviceOrientationLandscapeRight)?CGAffineTransformMakeRotation(M_PI*1.5):CGAffineTransformMakeRotation(M_PI/2);
            if (iPhoneX) {
                self.center = [UIApplication sharedApplication].keyWindow.center;
                self.bounds = CGRectMake(0, 0,  KAppHeight - kStatusBar_Height - kBottomSafeHeight, kAPPWidth);
            } else {
                self.bounds = CGRectMake(0, 0, KAppHeight, kAPPWidth);
            }
            [self setNeedsLayout];
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {
            
        }];
        
    }else if (orientation==UIDeviceOrientationPortrait){
        if (self.bounds.size.width > self.bounds.size.height) {
            [currentView.scrollview setZoomScale:1.0 animated:YES];//还原
        }
        [UIView animateWithDuration:kRotateAnimationDuration delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.transform = (orientation==UIDeviceOrientationPortrait)?CGAffineTransformIdentity:CGAffineTransformMakeRotation(M_PI);
            if (iPhoneX) {
                self.bounds = CGRectMake(0, 0, kAPPWidth, KAppHeight - kStatusBar_Height - kBottomSafeHeight);
            } else {
                self.bounds = CGRectMake(0, 0, kAPPWidth, KAppHeight);
            }
            
            [self setNeedsLayout];
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {
            
        }];
        
    }
}

- (void)showFirstImage {
    self.userInteractionEnabled = NO;
    XJPhoto *photo = self.photos[self.currentPhotoIndex];
    if (!CGRectIsEmpty(photo.sourceFrame) && photo.thumbImage) {
        CGRect rect = photo.sourceFrame;
        UIImageView *tempView = [[UIImageView alloc] init];
        tempView.frame = rect;
        tempView.image = photo.thumbImage;
        [self addSubview:tempView];
        tempView.contentMode = UIViewContentModeScaleAspectFit;

        CGFloat placeImageSizeW = tempView.image.size.width;
        CGFloat placeImageSizeH = tempView.image.size.height;
        CGRect targetTemp;
        CGFloat selfW = self.frame.size.width;
        CGFloat selfH = self.frame.size.height;

        CGFloat placeHolderH = (placeImageSizeH * selfW)/placeImageSizeW;
        if (placeHolderH <= selfH) {
            targetTemp = CGRectMake(0, (selfH - placeHolderH) * 0.5 , selfW, placeHolderH);
        } else {//图片高度>屏幕高度
            targetTemp = CGRectMake(0, 0, selfW, placeHolderH);
        }
        //先隐藏scrollview
        _scrollView.hidden = YES;
        _indexLabel.hidden = YES;
        _saveButton.hidden = YES;
        [UIView animateWithDuration:XJPhotoBrowserShowImageAnimationDuration animations:^{
            //将点击的临时imageview动画放大到和目标imageview一样大
            tempView.frame = targetTemp;
        } completion:^(BOOL finished) {
            //动画完成后，删除临时imageview，让目标imageview显示
            self.hasShowedFistView = YES;
            [tempView removeFromSuperview];
            self.scrollView.hidden = NO;
            self.indexLabel.hidden = NO;
            self.saveButton.hidden = NO;
            self.userInteractionEnabled = YES;
        }];
    } else {
        _photoBrowserView.alpha = 0;
        self.contentView.alpha = 0;
        [UIView animateWithDuration:0.2 animations:^{
            //将点击的临时imageview动画放大到和目标imageview一样大
            self.photoBrowserView.alpha = 1;
            self.contentView.alpha = 1;
        } completion:^(BOOL finished) {
            self.hasShowedFistView = YES;
            self.userInteractionEnabled = YES;
        }];
    }
}

- (void)hidePhotoBrowser {
    [self prepareForHide];
    [self hideAnimation];
}

- (void)hideAnimation{
    self.userInteractionEnabled = NO;
    CGRect targetTemp;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    XJPhoto *photo = self.photos[self.currentPhotoIndex];
    if (CGRectIsEmpty(photo.sourceFrame)) {
        targetTemp = CGRectMake(window.center.x, window.center.y, 0, 0);
    } else {
        targetTemp = photo.sourceFrame;
    }
    
    self.window.windowLevel = UIWindowLevelNormal;//显示状态栏
    [UIView animateWithDuration:XJPhotoBrowserHideImageAnimationDuration animations:^{
        if (CGRectIsEmpty(photo.sourceFrame)) {
            self.tempView.alpha = 0;
        } else {
            self.tempView.transform = CGAffineTransformInvert(self.transform);
            self.tempView.frame = targetTemp;
        }
        self.coverView.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        [self.tempView removeFromSuperview];
        [self.contentView removeFromSuperview];
        self.tempView = nil;
        self.contentView = nil;
    }];
}

- (void)prepareForHide {
    [_contentView insertSubview:self.coverView belowSubview:self];
    _saveButton.hidden = YES;
    _indexLabel.hidden = YES;
    [self addSubview:self.tempView];
    _photoBrowserView.hidden = YES;
    self.backgroundColor = [UIColor clearColor];
    _contentView.backgroundColor = [UIColor clearColor];
}

- (void)bounceToOrigin {
    self.userInteractionEnabled = NO;
    [UIView animateWithDuration:XJPhotoBrowserHideImageAnimationDuration animations:^{
        self.tempView.transform = CGAffineTransformIdentity;
        self.coverView.alpha = 1;
    } completion:^(BOOL finished) {
        self.userInteractionEnabled = YES;
        self.saveButton.hidden = NO;
        self.indexLabel.hidden = NO;
        [self.tempView removeFromSuperview];
        [self.coverView removeFromSuperview];
        self.tempView = nil;
        self.coverView = nil;
        self.photoBrowserView.hidden = NO;
        self.backgroundColor = [UIColor blackColor];
        self.contentView.backgroundColor = [UIColor blackColor];
    }];
}

#pragma mark - scrollview代理方法
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    int index = (scrollView.contentOffset.x + _scrollView.bounds.size.width * 0.5) / _scrollView.bounds.size.width;
    _indexLabel.text = [NSString stringWithFormat:@"%d/%ld", index + 1, (long)self.photoCount];
    long left = index - 1;
    long right = index + 1;
    left = left>0?left : 0;
    right = right>self.photoCount?self.photoCount:right;
    
    for (long i = left; i < right; i++) {
        [self setupImageOfImageViewForIndex:i];
    }
}

//scrollview结束滚动调用
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    int autualIndex = scrollView.contentOffset.x  / _scrollView.bounds.size.width;
    //设置当前下标
    self.currentPhotoIndex = autualIndex;
    self.photoBrowserView = _scrollView.subviews[self.currentPhotoIndex];
    
    //将不是当前imageview的缩放全部还原 (这个方法有些冗余，后期可以改进)
    for (XJPhotoBrowserView *view in _scrollView.subviews) {
        if (view.imageview.tag != autualIndex) {
            view.scrollview.zoomScale = 1.0;
        }
    }
}

#pragma mark - tap
#pragma mark 单击
- (void)photoClick:(UITapGestureRecognizer *)recognizer {
    [self hidePhotoBrowser];
}

#pragma mark 双击
- (void)handleDoubleTap:(UITapGestureRecognizer *)recognizer {
    XJPhotoBrowserView *view = _scrollView.subviews[self.currentPhotoIndex];
    CGPoint touchPoint = [recognizer locationInView:self];
    if (view.scrollview.zoomScale <= 1.0) {
        CGFloat scaleX = touchPoint.x + view.scrollview.contentOffset.x;//需要放大的图片的X点
        CGFloat sacleY = touchPoint.y + view.scrollview.contentOffset.y;//需要放大的图片的Y点
        [view.scrollview zoomToRect:CGRectMake(scaleX, sacleY, 10, 10) animated:YES];
    } else {
        [view.scrollview setZoomScale:1.0 animated:YES]; //还原
    }
}

#pragma mark 长按
- (void)didPan:(UIPanGestureRecognizer *)panGesture {
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsLandscape(orientation)) {//横屏不允许拉动图片
        return;
    }
    //transPoint : 手指在视图上移动的位置（x,y）向下和向右为正，向上和向左为负。
    //locationPoint ： 手指在视图上的位置（x,y）就是手指在视图本身坐标系的位置。
    //velocity： 手指在视图上移动的速度（x,y）, 正负也是代表方向。
    CGPoint transPoint = [panGesture translationInView:self];
    //    CGPoint locationPoint = [panGesture locationInView:self];
    CGPoint velocity = [panGesture velocityInView:self];//速度
    
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            [self prepareForHide];
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            _saveButton.hidden = YES;
            _indexLabel.hidden = YES;
            double delt = 1 - fabs(transPoint.y) / self.frame.size.height;
            delt = MAX(delt, 0);
            double s = MAX(delt, 0.5);
            CGAffineTransform translation = CGAffineTransformMakeTranslation(transPoint.x/s, transPoint.y/s);
            CGAffineTransform scale = CGAffineTransformMakeScale(s, s);
            self.tempView.transform = CGAffineTransformConcat(translation, scale);
            self.coverView.alpha = delt;
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            if (fabs(transPoint.y) > 220 || fabs(velocity.y) > 500) {//退出图片浏览器
                [self hideAnimation];
            } else {//回到原来的位置
                [self bounceToOrigin];
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark public methods
- (void)show {
    _contentView = [[UIView alloc] init];
    _contentView.backgroundColor = [UIColor blackColor];
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    _contentView.center = window.center;
    _contentView.bounds = window.bounds;
    
    if (iPhoneX) {
        self.frame = CGRectMake(0, kStatusBar_Height,kAPPWidth,KAppHeight - kStatusBar_Height - kBottomSafeHeight);
    } else {
        self.frame = _contentView.bounds;
    }
    window.windowLevel = UIWindowLevelStatusBar+10.0f;//隐藏状态栏
    [_contentView addSubview:self];
    
    [window addSubview:_contentView];
    
    [self performSelector:@selector(onDeviceOrientationChangeWithObserver) withObject:nil afterDelay:XJPhotoBrowserShowImageAnimationDuration + 0.2];
}

@end
