//
//  DynamicNetConCell.m
//  DouDou
//
//  Created by huangzhibiao on 16/5/31.
//  Copyright © 2016年 Biao. All rights reserved.
//

#import "DynamicNetConCell.h"
#import "UIImageView+WebCache.h"
#import "global.h"

@interface DynamicNetConCell()

@property(nonatomic,assign)CGFloat itemW;
@property(nonatomic,assign)CGFloat itemH;

@property (weak, nonatomic)UIImageView *icon;

@end

@implementation DynamicNetConCell

- (void)awakeFromNib {
    [super awakeFromNib];
    UIImageView* view = [[UIImageView alloc] init];
    view.layer.masksToBounds = YES;
    view.layer.cornerRadius = 5;
    view.contentMode = UIViewContentModeScaleAspectFit;
    CGFloat margin = 2.5;
    CGFloat itemW = (screenW-margin*4.0)/3.0;
    CGFloat itemH = itemW;//[global BGHeight:itemW*1.16];
    _itemW = itemW;
    _itemH = itemH;
    view.frame = CGRectMake(0,0,itemW,itemH);
    _icon = view;
    [self.contentView addSubview:view];
}


-(void)setImage:(NSString *)image{
    _image = image;
    [self.icon sd_setImageWithURL:[NSURL URLWithString:image] placeholderImage:nil];
}
@end
