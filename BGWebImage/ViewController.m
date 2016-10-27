//
//  ViewController.m
//  BGWebImage
//
//  Created by huangzhibiao on 16/9/21.
//  Copyright © 2016年 Biao. All rights reserved.
//

#import "ViewController.h"
#import "DynamicNetConCell.h"
#import "global.h"
#import <objc/runtime.h>

@interface ViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>

@property(nonatomic,weak)UICollectionView* goodShowView;//表情展示
@property(nonatomic,strong)NSArray* datas;

@property(nonatomic,weak)NSString* weak_str;

@end

static NSString* GOCELLID = @"DynamicNetConCell";

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self initGoodShowView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSLog(@"%@",_weak_str);
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSLog(@"%@",_weak_str);
}

-(NSArray *)datas{
    if (_datas == nil) {
        NSMutableArray* arrM = [NSMutableArray array];
        for(int i=0;i<170;i++){
            NSString* name = [NSString stringWithFormat:@"http://o7pqnqwgs.bkt.clouddn.com/gif%d.gif",i];
            //NSString* name = [NSString stringWithFormat:@"http://o7pq80nc2.bkt.clouddn.com/wbq%d.jpg",i];
            [arrM addObject:name];
        }
        _datas = arrM;
    }
    return _datas;
}

/**
 初始化表情展示View
 */
-(void)initGoodShowView{
    CGFloat margin = 2.5;
    CGFloat itemW = (screenW-margin*4.0)/3.0;
    CGFloat itemH = itemW;//[global BGHeight:itemW*1.16];
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    // cell的大小
    layout.itemSize = CGSizeMake(itemW,itemH);
    //计算内边距
    UIEdgeInsets edge = UIEdgeInsetsMake(margin,margin,margin,margin);
    layout.sectionInset = edge;
    // 设置每一行之间的间距
    layout.minimumLineSpacing = margin;
    layout.minimumInteritemSpacing = margin;
    UICollectionView* collection = [[UICollectionView alloc] initWithFrame:CGRectMake(0,0, screenW,screenH) collectionViewLayout:layout];
    collection.backgroundColor = [UIColor clearColor];
    self.goodShowView = collection;
    [collection registerNib:[UINib nibWithNibName:@"DynamicNetConCell" bundle:nil] forCellWithReuseIdentifier:GOCELLID];
    collection.dataSource = self;
    collection.delegate = self;
    collection.alwaysBounceVertical = YES;
    [self.view addSubview:collection];
}

#pragma -- UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return (self.datas==nil)?0:self.datas.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    DynamicNetConCell *cell =  [collectionView dequeueReusableCellWithReuseIdentifier:GOCELLID forIndexPath:indexPath];
    cell.image = self.datas[indexPath.item];
    return cell;
    
}

@end
