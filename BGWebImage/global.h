//
//  global.h
//  BGWebImage
//
//  Created by huangzhibiao on 16/9/21.
//  Copyright © 2016年 Biao. All rights reserved.
//

#import <Foundation/Foundation.h>

#define BGFont(size) [UIFont systemFontOfSize:size]
#define color(r,g,b,al) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:al]
#define screenH [UIScreen mainScreen].bounds.size.height
#define screenW [UIScreen mainScreen].bounds.size.width

#define imageDir @"imageResource"

@interface global : NSObject

@end
