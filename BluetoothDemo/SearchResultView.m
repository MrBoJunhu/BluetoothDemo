//
//  SearchResultView.m
//  BluetoothDemo
//
//  Created by BillBo on 2017/8/18.
//  Copyright © 2017年 BillBo. All rights reserved.
//

#import "SearchResultView.h"

#import <CoreBluetooth/CoreBluetooth.h>

#import "BluetoothManager.h"

#define  Screen_Width [UIScreen mainScreen].bounds.size.width

#define Screen_Height [UIScreen mainScreen].bounds.size.height

#define showView_width Screen_Width - 20

static CGFloat row_Height = 40;


@interface SearchResultView()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *peripherals;

@property (nonatomic, strong) UITableView *tab;

@property (nonatomic, strong) UIView *backView;

@property (nonatomic, strong) UIView * bottomView;

@property (nonatomic, copy) clickSelectedPeripherals selectedBlock;


@end

@implementation SearchResultView

- (instancetype)initWithPeripherals:(NSArray<CBPeripheral *> *)peripherals clickSelectedPeripheral:(clickSelectedPeripherals)peripheral {
    
    if (self = [super initWithFrame:[UIApplication sharedApplication].keyWindow.bounds]) {
        
        self.selectedBlock = peripheral;
        
        self.backgroundColor = [UIColor clearColor];
        
        self.peripherals = [NSMutableArray arrayWithArray:peripherals];
        
        [self createUI];
    }
    
    return self;
    
}

- (void)createUI {
    
    NSUInteger count = self.peripherals.count;
    CGFloat titleLB_Height = 40;
    
    count = count > 0 ? (count > 3 ? 3 : count) : 1;
    
    self.backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, showView_width, count * row_Height + titleLB_Height)];
    
    self.backView.backgroundColor = [UIColor whiteColor];
    
    self.backView.center = CGPointMake(self.center.x, self.center.y - self.backView.frame.size.height/4);
    
    [self addSubview:self.backView];
    
    
    UILabel *titleLB = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.backView.frame.size.width, titleLB_Height)];
    
    titleLB.backgroundColor = [UIColor lightGrayColor];
    
    titleLB.textColor = [UIColor blackColor];
    
    titleLB.font = [UIFont systemFontOfSize:15.0f];
    
    titleLB.text = @"搜索到的设备";
    
    [self.backView addSubview:titleLB];
    
    self.tab = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(titleLB.frame), titleLB.frame.size.width, self.backView.frame.size.height - titleLB.frame.size.height) style:UITableViewStylePlain];
    
    self.tab.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.tab.delegate = self;
    
    self.tab.dataSource = self;
    
    [self.backView addSubview:self.tab];
    
    [self.tab reloadData];

}

#pragma mark - tableview delegate and datasource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier = @"UITableViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
    
    }
    
    CBPeripheral *peripheral = self.peripherals[indexPath.row];
    
    cell.textLabel.textColor = [UIColor redColor];
    
    cell.textLabel.text = peripheral.name;
    
    return cell;
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.peripherals.count;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CBPeripheral *peripheral = self.peripherals[indexPath.row];
    
    if (self.selectedBlock) {
        
        self.selectedBlock(peripheral);
        
    }
    
    [[BluetoothManager shareBluetoothManager] connectCBPeripheral:peripheral];
    
    [self dismiss];
    
}

- (void)show{
    
    for (UIView *view in self.backView.subviews) {
        
        view.hidden = YES;
        
    }
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    _bottomView = [[UIView alloc] initWithFrame:window.bounds];
    
    _bottomView.alpha = 0;
    
    _bottomView.backgroundColor = [UIColor clearColor];
    
    [window addSubview:_bottomView];
    
    [_bottomView addSubview:self];
    
    [UIView animateWithDuration:0.5 animations:^{
        
        _bottomView.alpha = 0.5;
        
        _bottomView.backgroundColor = [UIColor blackColor];
        
        for (UIView *view in self.backView.subviews) {
            
            view.hidden = NO;
            
        }
        
    } completion:^(BOOL finished) {
       
        if (finished) {
            
        }
    }];
}


- (void)dismiss {
    
    [UIView animateWithDuration:0.4 animations:^{
        
        _bottomView.alpha = 0;
        
        _backView.alpha = 0;
        
    } completion:^(BOOL finished) {
      
        if (finished) {
            
            [self removeFromSuperview];
            
            [_bottomView removeFromSuperview];
            
        }
        
    }];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    UIView *v = [touches anyObject].view;
    
    if (v == self) {
        
        [self dismiss];
        
    }
    
}


@end
