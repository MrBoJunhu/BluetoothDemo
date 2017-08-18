//
//  ViewController.m
//  BluetoothDemo
//
//  Created by BillBo on 2017/8/18.
//  Copyright © 2017年 BillBo. All rights reserved.
//

#import "ViewController.h"

#import "BluetoothManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {

    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [BluetoothManager shareBluetoothManager];
    
}


- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];

}


@end
