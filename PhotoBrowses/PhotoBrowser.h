//
//  PhotoBrowser.h
//  MasterKong
//
//  Created by leiyuyu on 16/8/29.
//  Copyright © 2016年 systexUcom. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^complete)();

@protocol PhotoBrowserDelegate <NSObject>

//编辑状态删除某个图片
- (void)photoBrowserDeleteImage: (int)index;

@end

@class PhotoItem;
@interface PhotoBrowser : UIView

//PhotoItem数组
@property (nonatomic , strong)NSMutableArray<PhotoItem *> *photoItems;
//是否显示编辑按钮
@property (nonatomic , assign)BOOL isEdit;

@property (nonatomic , weak)id<PhotoBrowserDelegate> delegate;

/**
 *  显示
 *
 *  @param superViews 父控件 一般是有导航栏的是nav.view
 *  @param index      查看第几张图片
 *  @param fromView   看哪一张图片的view
 *  @param complete   消失的回调
 */
- (void)show: (UIView *)superViews index: (NSInteger)index fromView:(UIView *)fromView complete: (complete)complete;

/**
 *  显示
 *
 *  @param superViews 父控件 一般是有导航栏的是nav.view
 *  @param index      查看第几张图片
 *  @param complete   消失的回调
 */
- (void)show: (UIView *)superViews index: (NSInteger)index complete: (complete)complete;


//隐藏
- (void)disMiss;

@end
