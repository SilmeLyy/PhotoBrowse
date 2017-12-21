//
//  PhotoCell.m
//  MasterKong
//
//  Created by leiyuyu on 16/8/29.
//  Copyright © 2016年 systexUcom. All rights reserved.
//

#import "PhotoCell.h"
//#import "UIImageView+WebCache.h"

@interface PhotoCell()<UIScrollViewDelegate>

@end


@implementation PhotoCell

- (instancetype)init {
    self = super.init;
    if (!self) return nil;
    self.delegate = self;
    self.bouncesZoom = YES;    //允许缩放
    self.maximumZoomScale = 3; //最大缩放倍数
    self.multipleTouchEnabled = YES; //多点触控
    self.alwaysBounceVertical = NO;
    self.showsVerticalScrollIndicator = false;
    self.showsHorizontalScrollIndicator = NO;
    self.frame = [UIScreen mainScreen].bounds;
    
    
    _imageContainerView = [UIView new];
    _imageContainerView.frame = CGRectMake(0, 0, KScreenWidths, KScreenHeights);
    _imageContainerView.clipsToBounds = YES;
    [self addSubview:_imageContainerView];
    
    _imageView = [UIImageView new];
    _imageView.clipsToBounds = YES;
    _imageView.backgroundColor = [UIColor clearColor];
    _imageView.frame = _imageContainerView.bounds;
    [_imageContainerView addSubview:_imageView];
    
    //下载图片的进度
    _progressLayer = [CAShapeLayer layer];
    _progressLayer.frame = CGRectMake((KScreenWidths - 40) * 0.5, (KScreenHeights - 40) * 0.5, 40, 40);
    _progressLayer.cornerRadius = 20;
    _progressLayer.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.500].CGColor;
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(_progressLayer.bounds, 7, 7) cornerRadius:(40 / 2 - 7)];
    _progressLayer.path = path.CGPath;
    _progressLayer.fillColor = [UIColor clearColor].CGColor;
    _progressLayer.strokeColor = [UIColor whiteColor].CGColor;
    _progressLayer.lineWidth = 4;
    _progressLayer.lineCap = kCALineCapRound;
    _progressLayer.strokeStart = 0;
    _progressLayer.strokeEnd = 0;
    _progressLayer.hidden = YES;
    [self.layer addSublayer:_progressLayer];
    
    return self;
}

- (void)setItem:(PhotoItem *)item{
    _item = item;
    if (item.image) {
        _imageView.image = item.image;
        [self setImageViewFrame:item.image];
        _progressLayer.hidden = true;
    }
    else{
//        [_imageView sd_setImageWithURL:[NSURL URLWithString:item.imageURL] placeholderImage:nil options:SDWebImageProgressiveDownload progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
//            _progressLayer.hidden = false;
//            _progressLayer.strokeEnd = (CGFloat)receivedSize / (CGFloat)expectedSize;
//        } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
//            item.image = image;
//            [self setImageViewFrame:image];
//            _progressLayer.hidden = true;
//        }];
    }
}

//设置图片在中心显示
- (void)setImageViewFrame:(UIImage *)image{
    
    CGSize size = image.size;
    CGFloat width  = 0;
    CGFloat height = size.height;
    CGFloat x = 0;
    CGFloat y = 0;
    
    if (size.width > KScreenWidths) {
        width = KScreenWidths;
        height = size.height / size.width * width;
        x = 0;
    }
    else{
        width = size.width;
        x = (KScreenWidths - width) * 0.5;
    }
    
    if (height > KScreenHeights) {
        y = 0;
        self.alwaysBounceVertical = true;
        self.contentSize = CGSizeMake(width, height);
    }
    else{
        y = (KScreenHeights - height) * 0.5;
    }
    [self scrollViewDidZoom:self];
    _imageContainerView.frame = CGRectMake(x, y, width, height);
    _imageView.frame = _imageContainerView.bounds;
    
}

//缩放的控件
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return _imageContainerView;
}

//缩放控制图片张中心显示
- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    UIView *subView = _imageContainerView;
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    subView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                 scrollView.contentSize.height * 0.5 + offsetY);
}


@end

@implementation PhotoItem



@end
