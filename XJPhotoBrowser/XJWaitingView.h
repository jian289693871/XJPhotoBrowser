//
//  XJWaitingView.h
//  XJPhotoBrowser
//
//  Created by xuejian on 2018/8/2.
//  Copyright © 2018年 xuejian. All rights reserved.
//
#import <UIKit/UIKit.h>

typedef enum {
    XJWaitingViewModeLoopDiagram, // 环形
    XJWaitingViewModePieDiagram // 饼型
} XJWaitingViewMode;

@interface XJWaitingView : UIView

@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, assign) XJWaitingViewMode mode;

@end
