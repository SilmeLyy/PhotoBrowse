//
//  ViewController.m
//  PhotoBrowse
//
//  Created by 未央生 on 2017/12/21.
//  Copyright © 2017年 未央生. All rights reserved.
//

#import "ViewController.h"
#import "PhotoBrowser.h"
#import "PhotoCell.h"

@interface ViewController ()

@property (nonatomic, strong)NSMutableArray *imageArr;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *arr = @[@"publish-audio",@"publish-offline",@"publish-picture"];
    _imageArr = @[].mutableCopy;
    for (NSInteger i = 0; i < 3 ; i ++) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectMake(i * 100 + 10, 100, 90, 90);
        imageView.userInteractionEnabled = true;
        imageView.tag = i;
        imageView.image = [UIImage imageNamed:arr[i]];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        [imageView addGestureRecognizer:tap];
        [_imageArr addObject:imageView];
        [self.view addSubview:imageView];
    }
}

- (void)tap:(UITapGestureRecognizer *)g{
    NSArray *arr = @[@"publish-audio",@"publish-offline",@"publish-picture"];
    NSMutableArray *phptos = @[].mutableCopy;
    NSInteger i = 0;
    for (NSString *name in arr) {
        PhotoItem *item = [[PhotoItem alloc] init];
        item.image = [UIImage imageNamed:name];
        item.thumbView = _imageArr[i];
        i ++;
        [phptos addObject:item];
    }
    PhotoBrowser *browser = [[PhotoBrowser alloc] initWithFrame:[UIScreen mainScreen].bounds];
    browser.photoItems = phptos;
    [browser show:self.navigationController.view index:g.view.tag fromView:g.view complete:^{
        
    }];
}


@end
