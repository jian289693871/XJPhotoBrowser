//
//  ViewController.m
//  Demo
//
//  Created by xuejian on 2018/8/1.
//  Copyright © 2018年 xuejian. All rights reserved.
//

#import "ViewController.h"
#import "XJPhotoBrowser.h"


@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.logoImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(logoTap)];
    [self.logoImageView addGestureRecognizer:tap];
}


- (void)logoTap {
    XJPhoto *photo1 = [XJPhoto photoWithOrginImage:@"http://ww2.sinaimg.cn/bmiddle/677febf5gw1erma104rhyj20k03dz16y.jpg" thumbImage:nil];
    XJPhoto *photo2 = [XJPhoto photoWithOrginImage:[UIImage imageNamed:@"test.jpg"] thumbImage:self.logoImageView.image sourceFrame:self.logoImageView.frame];
    XJPhoto *photo3 = [XJPhoto photoWithOrginImage:[NSURL URLWithString:@"http://ww2.sinaimg.cn/bmiddle/677febf5gw1erma104rhyj20k03dz16y.jpg"] thumbImage:nil];
    XJPhoto *photo4 = [XJPhoto photoWithOrginImage:[NSNumber numberWithBool:YES] thumbImage:nil];
    
    XJPhotoBrowser *browser = [[XJPhotoBrowser alloc] init];
    browser.isFullWidthForLandScape = YES;
    browser.isNeedLandscape = NO;
    browser.currentPhotoIndex = 1;
    browser.photos = @[photo1, photo2, photo3, photo4];
    [browser show];
}


- (IBAction)btnClick:(UIButton *)sender {
    XJPhoto *photo1 = [XJPhoto photoWithOrginImage:@"http://ww2.sinaimg.cn/bmiddle/677febf5gw1erma104rhyj20k03dz16y.jpg" thumbImage:nil];
    XJPhoto *photo2 = [XJPhoto photoWithOrginImage:[UIImage imageNamed:@"test.jpg"] thumbImage:nil];
    XJPhoto *photo3 = [XJPhoto photoWithOrginImage:[NSURL URLWithString:@"http://ww2.sinaimg.cn/bmiddle/677febf5gw1erma104rhyj20k03dz16y.jpg"] thumbImage:nil];
    XJPhoto *photo4 = [XJPhoto photoWithOrginImage:[NSNumber numberWithBool:YES] thumbImage:nil];
    
    XJPhotoBrowser *browser = [[XJPhotoBrowser alloc] init];
    browser.isFullWidthForLandScape = YES;
    browser.isNeedLandscape = NO;
    browser.currentPhotoIndex = 0;
    browser.photos = @[photo1, photo2, photo3, photo4];
    [browser show];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
