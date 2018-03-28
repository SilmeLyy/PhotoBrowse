//
//  PhotoBrowser.m
//  MasterKong
//
//  Created by leiyuyu on 16/8/29.
//  Copyright © 2016年 systexUcom. All rights reserved.
//

#import "PhotoBrowser.h"
#import "PhotoCell.h"

@interface PhotoBrowser()<UIScrollViewDelegate>
@property (nonatomic , strong)UIView *superNavView;
@property (nonatomic, weak) UIView *fromView;
@property (nonatomic, weak) UIView *toContainerView;
//隐藏前的快照
@property (nonatomic, strong) UIImage *snapshotImage;
//隐藏后的快照
@property (nonatomic, strong) UIImage *snapshorImageHideFromView;
//背景
@property (nonatomic, strong) UIImageView *background;
//毛玻璃效果
@property (nonatomic, strong) UIImageView *blurBackground;

@property (nonatomic , strong)UIScrollView *scrollView;
@property (nonatomic , strong)UIPageControl *pagecontrol;

@property (nonatomic, assign) BOOL isPresented;
@property (nonatomic , copy)complete success;
//删除按钮
@property (nonatomic , strong)UIButton *deleteBtn;
//确认按钮
@property (nonatomic , strong)UIButton *trueBtn;

@property (nonatomic , strong)UIView *btnView;
//拖拽手势
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
//拖拽开始位置
@property (nonatomic, assign) CGPoint panGestureBeginPoint;
//当前的是第几个
@property (nonatomic , assign)NSInteger currIndex;
//点第几个打开的
@property (nonatomic , assign)NSInteger fromeIndex;

@property (nonatomic , strong)NSMutableArray *cells;

@end
//x的取值范围在low和high  如果超过取high  如果低于取low
#define CLAMP(_x_, _low_, _high_)  (((_x_) > (_high_)) ? (_high_) : (((_x_) < (_low_)) ? (_low_) : (_x_)))

@implementation PhotoBrowser

- (UIButton *)deleteBtn{
    if (!_deleteBtn) {
        UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteBtn = deleteBtn;
        [deleteBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [deleteBtn addTarget:self action:@selector(deleteImage) forControlEvents:UIControlEventTouchUpInside];
        deleteBtn.frame = CGRectMake(0, KScreenHeights - 44, 60, 44);
        [deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
        [self addSubview:deleteBtn];
    }
    return _deleteBtn;
}

- (UIButton *)trueBtn{
    if (!_trueBtn) {
        UIButton *trueBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _trueBtn = trueBtn;
        [trueBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [trueBtn addTarget:self action:@selector(disMiss) forControlEvents:UIControlEventTouchUpInside];
        trueBtn.frame = CGRectMake(KScreenWidths - 60, KScreenHeights - 44, 60, 44);
        [trueBtn setTitle:@"确定" forState:UIControlStateNormal];
        [self addSubview:_trueBtn];
    }
    return _trueBtn;
}

//初始化
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        _background = UIImageView.new;
        _background.frame = self.bounds;
        _background.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        _blurBackground = UIImageView.new;
        _blurBackground.frame = self.bounds;
        _blurBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.showsHorizontalScrollIndicator = false;
        _scrollView.frame = CGRectMake(0, 0, KScreenWidths, KScreenHeights);
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = true;
        [self addSubview:_background];
        [self addSubview:_blurBackground];
        [self addSubview:_scrollView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(disMiss)];
        [self addGestureRecognizer:tap];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        [self addGestureRecognizer:pan];
        _panGesture = pan;
        
        _pagecontrol = [[UIPageControl alloc] init];
        _pagecontrol.frame = CGRectMake(20, KScreenHeights - 80, KScreenWidths - 40, 30);
        _pagecontrol.hidesForSinglePage = true;
        [self addSubview:_pagecontrol];
    }
    return self;
}

//是否有删除
- (void)setIsEdit:(BOOL)isEdit{
    
    _isEdit = isEdit;
    if (isEdit) {
        self.trueBtn.tintColor = [UIColor whiteColor];
        self.deleteBtn.tintColor = [UIColor whiteColor];;
    }
    else{
        
    }
    
}

//删除需要刷新
- (void)relodata{
    
    for (PhotoCell *cell in _scrollView.subviews) {
        [cell removeFromSuperview];
    }
    
}

//删除图片
- (void)deleteImage{
    int deleteID = (int)_scrollView.contentOffset.x / KScreenWidths;
    
    [_photoItems removeObjectAtIndex:deleteID];
    
    [self relodata];
    NSInteger count = _photoItems.count;
    _pagecontrol.numberOfPages = count;
    
    if ([_delegate respondsToSelector:@selector(photoBrowserDeleteImage:)]) {
        [_delegate photoBrowserDeleteImage:deleteID];
    }

    if (count == 0) {
        [self disMiss];
        return;
    }
    
    for (int i = 0; i < count; i++) {
        PhotoCell *cell = [[PhotoCell alloc] init];
        cell.frame = CGRectMake(KScreenWidths * i, 0, KScreenWidths, KScreenHeights);
        PhotoItem *item = _photoItems[i];
        cell.item = item;
        [_scrollView addSubview:cell];
    }
    if (deleteID == 0) {
        _scrollView.contentSize = CGSizeMake(KScreenWidths * count, KScreenHeights);
        _scrollView.contentOffset = CGPointMake(0, 0);
    }else{
        _scrollView.contentSize = CGSizeMake(KScreenWidths * count, KScreenHeights);
        _scrollView.contentOffset = CGPointMake(KScreenWidths * (deleteID - 1), 0);
    }
    
    [self scrollViewDidEndDecelerating:_scrollView];
}

//添加到页面有回调
- (void)show:(UIView *)superViews index:(NSInteger)index complete:(complete)complete{
    [self show:superViews index:index fromView:nil complete:complete];
}

- (void)show:(UIView *)superViews index:(NSInteger)index fromView:(UIView *)fromView complete:(complete)complete{
    _success = complete;
    
    NSInteger count = 0;
    
    count = _photoItems.count;
    _cells = @[].mutableCopy;
    for (int i = 0; i < count; i++) {
        PhotoCell *cell = [[PhotoCell alloc] init];
        cell.frame = CGRectMake(KScreenWidths * i, 0, KScreenWidths, KScreenHeights);
        PhotoItem *item = _photoItems[i];
        cell.item = item;
        [_cells addObject:cell];
        [_scrollView addSubview:cell];
    }
    _fromeIndex = index;
    _pagecontrol.numberOfPages = count;
    _pagecontrol.currentPage   = index;
    _scrollView.contentSize = CGSizeMake(KScreenWidths * count, KScreenHeights);
    _scrollView.contentOffset = CGPointMake(KScreenWidths * index, 0);
    
    _toContainerView = superViews;
    _snapshotImage = [self snapshotImageAfterScreenUpdates:false andView:superViews];
    _blurBackground.backgroundColor = [UIColor blackColor];
    _background.image = _snapshotImage;
    self.blurBackground.alpha = 1;
    
    [self scrollViewDidEndDecelerating:_scrollView];
    
    
    if (fromView) {
        _fromView = fromView;
        BOOL fromViewHidden = fromView.hidden;
        fromView.hidden = YES;
        _snapshorImageHideFromView = [self snapshotImageWithView:superViews];
        fromView.hidden = fromViewHidden;
        _background.image = _snapshorImageHideFromView;
        
        PhotoCell *cell = _cells[index];
        CGRect fromFrame = [_fromView convertRect:_fromView.bounds toView:cell.imageContainerView];
        cell.imageContainerView.clipsToBounds = NO;
        cell.imageView.frame = fromFrame;
        cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
        
        float oneTime = 0.18;
        [UIView animateWithDuration:oneTime*2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:^{
            _blurBackground.alpha = 1;
        }completion:NULL];
        
        _scrollView.userInteractionEnabled = NO;
        [UIView animateWithDuration:oneTime delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:^{
            cell.imageView.frame = cell.imageContainerView.bounds;
            [cell.imageView.layer setValue:@(1.01) forKey:@"transform.scale"];
        }completion:^(BOOL finished) {
            [UIView animateWithDuration:oneTime delay:0 options:UIViewAnimationOptionBeginFromCurrentState |UIViewAnimationOptionCurveEaseInOut animations:^{
                [cell.imageView.layer setValue:@(1.0) forKey:@"transform.scale"];
                _pagecontrol.alpha = 1;
            }completion:^(BOOL finished) {
                cell.imageContainerView.clipsToBounds = YES;
                _isPresented = YES;
                _scrollView.userInteractionEnabled = YES;
            }];
        }];
    }
    _superNavView = superViews;
//    [superViews addSubview:self];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self];
}

- (void)disMiss{
    //显示状态栏
    [[UIApplication sharedApplication] setStatusBarHidden:false withAnimation:UIStatusBarAnimationNone];
    [UIView setAnimationsEnabled:YES];
    
    if (_fromView) {
        UIView *fromView = nil;
        PhotoCell *cell = _cells[_currIndex];
        PhotoItem *item = _photoItems[_currIndex];
        if (_fromeIndex == _currIndex) {
            fromView = _fromView;
        }else{
            fromView = item.thumbView;
        }
        _isPresented = NO;
        BOOL isFromImageClipped = fromView.layer.contentsRect.size.height < 1;
        
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        if (isFromImageClipped) {
            CGRect frame = cell.imageContainerView.frame;
            cell.imageContainerView.layer.anchorPoint = CGPointMake(0.5, 0);
            cell.imageContainerView.frame = frame;
        }
        cell.progressLayer.hidden = YES;
        [CATransaction commit];
        
        if (!fromView) {
            self.background.image = _snapshotImage;
            [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
                self.alpha = 0.0;
                [self.scrollView.layer setValue:@(.95) forKeyPath:@"transform.scale"];
                self.scrollView.alpha = 0;
                self.pagecontrol.alpha = 0;
                self.blurBackground.alpha = 0;
            }completion:^(BOOL finished) {
                [self.scrollView.layer setValue:@(1) forKeyPath:@"transform.scale"];
                [self removeFromSuperview];
                if (_success) _success();
            }];
            return;
        }
        
//        if (_fromeIndex != _currIndex) {
//            _background.image = _snapshotImage;
//        } else {
//            _background.image = _snapshorImageHideFromView;
//        }
        
        
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
            _pagecontrol.alpha = 0.0;
            _blurBackground.alpha = 0.0;
            if (isFromImageClipped) {
                
                CGRect fromFrame = [fromView convertRect:fromView.bounds toView:cell];
                CGFloat scale = fromFrame.size.width / cell.imageContainerView.frame.size.width * cell.zoomScale;
                CGFloat height = fromFrame.size.height / fromFrame.size.width * cell.imageContainerView.frame.size.width;
                if (isnan(height)) height = cell.imageContainerView.frame.size.height;
                CGRect frame = cell.imageContainerView.frame;
                frame.size.height = height;
                cell.imageContainerView.frame = frame;
                cell.imageContainerView.center = CGPointMake(CGRectGetMidX(fromFrame), CGRectGetMinY(fromFrame));
                [cell.imageContainerView.layer setValue:@(scale) forKey:@"transform.scale"];
                
            } else {
                CGRect fromFrame = [fromView convertRect:fromView.bounds toView:cell.imageContainerView];
                cell.imageContainerView.clipsToBounds = NO;
                cell.imageView.contentMode = fromView.contentMode;
                cell.imageView.frame = fromFrame;
            }
        }completion:^(BOOL finished) {
            [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                self.alpha = 0;
            } completion:^(BOOL finished) {
                cell.imageContainerView.layer.anchorPoint = CGPointMake(0.5, 0.5);
                [self removeFromSuperview];
                if (_success) _success();
            }];
        }];
    }else{
        [self relodata];
        if (_success) _success();
        [self removeFromSuperview];
    }
}

- (void)pan:(UIPanGestureRecognizer *)g{
    switch (g.state) {
        case UIGestureRecognizerStateBegan:{
            _panGestureBeginPoint = [g locationInView:self];
        }
            break;
        case UIGestureRecognizerStateChanged:{
             if (_panGestureBeginPoint.x == 0 && _panGestureBeginPoint.y == 0) return;
            CGPoint p = [g locationInView:self];
            CGFloat deltaY = p.y - _panGestureBeginPoint.y;
            CGRect frame = _scrollView.frame;
            frame.origin.y = deltaY;
            _scrollView.frame = frame;
            
            CGFloat alphaDelta = 160;
            CGFloat alpha = (alphaDelta - fabs(deltaY) + 50) / alphaDelta;
            alpha = CLAMP(alpha, 0, 1);
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveLinear animations:^{
                _blurBackground.alpha = alpha;
                _pagecontrol.alpha = alpha;
            } completion:nil];
        }
            break;
        case UIGestureRecognizerStateEnded:{
            if (_panGestureBeginPoint.x == 0 && _panGestureBeginPoint.y == 0) return;
            CGPoint v = [g velocityInView:self];
            CGPoint p = [g locationInView:self];
            CGFloat deltaY = p.y - _panGestureBeginPoint.y;
            
            if (fabs(v.y) > 1000 || fabs(deltaY) > 120) {
                _isPresented = NO;
                BOOL moveToTop = (v.y < - 50 || (v.y < 50 && deltaY < 0));
                CGFloat vy = fabs(v.y);
                if (vy < 1) vy = 1;
                CGFloat duration = (moveToTop ? (_scrollView.frame.origin.y + _scrollView.frame.size.height) : self.frame.size.height - _scrollView.frame.origin.y) / vy;
                duration *= 0.8;
                duration = CLAMP(duration, 0.05, 0.3);
                
                [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState animations:^{
                    _blurBackground.alpha = 0;
                    _pagecontrol.alpha = 0;
                    if (moveToTop) {
                        CGRect frame = _scrollView.frame;
                        frame.origin.y = 0 - frame.size.height;
                        _scrollView.frame = frame;
                    } else {
                        CGRect frame = _scrollView.frame;
                        frame.origin.y = self.frame.size.height;
                        _scrollView.frame = frame;
                    }
                } completion:^(BOOL finished) {
                    [self removeFromSuperview];
                }];
                
//                _background.image = _snapshotImage;
//                [_background.layer addFadeAnimationWithDuration:0.3 curve:UIViewAnimationCurveEaseInOut];
                
            } else {
                [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:v.y / 1000 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState animations:^{
                    CGRect frame = _scrollView.frame;
                    frame.origin.y = 0;
                    _scrollView.frame = frame;
                    _blurBackground.alpha = 1;
                    _pagecontrol.alpha = 1;
                } completion:^(BOOL finished) {
                    
                }];
            }
        }
            break;
        case UIGestureRecognizerStateCancelled : {
            CGRect frame = _scrollView.frame;
            frame.origin.y = 0;
            _scrollView.frame = frame;
            _blurBackground.alpha = 1;
        }
            break;
            
        default:
            break;
    }
}

//设置小圆点滚动
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSInteger index = (NSInteger)_scrollView.contentOffset.x / KScreenWidths;
    _currIndex = index;
    _pagecontrol.currentPage = index;
    PhotoItem *item = _photoItems[index];
    item.thumbView.hidden = true;
    _background.image = [self snapshotImageWithView:_superNavView];
    item.thumbView.hidden = false;
    if (item.isEdit) {//可以编辑
        self.deleteBtn.hidden = false;
        self.trueBtn.hidden = false;
    }
    else{//不可以编辑
        self.deleteBtn.hidden = true;
        self.trueBtn.hidden = true;
    }
}

- (UIImage *)snapshotImageAfterScreenUpdates:(BOOL)afterUpdates andView:(UIView *)superView {
    UIGraphicsBeginImageContextWithOptions(superView.bounds.size, superView.opaque, 0);
    [superView drawViewHierarchyInRect:superView.bounds afterScreenUpdates:afterUpdates];
    UIImage *snap = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snap;
}

- (UIImage *)snapshotImageWithView:(UIView *)superView {
    UIGraphicsBeginImageContextWithOptions(superView.bounds.size, superView.opaque, 0);
    [superView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *snap = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snap;
}


@end
