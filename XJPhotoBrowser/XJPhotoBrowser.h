//
//  XJPhotoBrowser.h
//  XJPhotoBrowser
//
//  Created by xuejian on 2018/8/2.
//  Copyright © 2018年 xuejian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XJPhoto.h"

@interface XJPhotoBrowser : UIView <UIScrollViewDelegate>
// 展示图片的数组
@property (nonatomic, strong) NSArray <XJPhoto *> *photos;
//从第几张图片开始展示，默认0
@property (nonatomic, assign) int currentPhotoIndex;
//是否在横屏的时候直接满宽度，而不是满高度，一般是在有长图需求的时候设置为YES(默认值YES)
@property (nonatomic, assign) BOOL isFullWidthForLandScape;
//是否支持横竖屏，默认支持（NO）
@property (nonatomic, assign) BOOL isNeedLandscape;

- (void)show;
@end
