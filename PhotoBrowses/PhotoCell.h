//
//  PhotoCell.h
//  MasterKong
//
//  Created by leiyuyu on 16/8/29.
//  Copyright © 2016年 systexUcom. All rights reserved.
//

#import <UIKit/UIKit.h>


#define KScreenWidths [UIScreen mainScreen].bounds.size.width
#define KScreenHeights [UIScreen mainScreen].bounds.size.height

//一张图片显示的控件
@class PhotoItem;
@interface PhotoCell : UIScrollView 
//图片模型
@property (nonatomic , strong)PhotoItem *item;
//原图片父控件
@property (nonatomic , strong)UIView *imageContainerView;
//图片控件
@property (nonatomic , strong)UIImageView *imageView;
//进度
@property (nonatomic, strong) CAShapeLayer *progressLayer;

@end

@interface PhotoItem : NSObject

///小图的view 用于执行动画
@property (nonatomic, strong)UIView *thumbView;

///图片地址
@property (nonatomic , copy)NSString *imageURL;

///图片
@property (nonatomic , strong)UIImage *image;

///是否可以编辑一个图片
@property (nonatomic , assign)BOOL isEdit;

@end
