//
//  ViewController.m
//  BluetoothDemo
//
//  Created by BillBo on 2017/8/18.
//  Copyright © 2017年 BillBo. All rights reserved.
//

#import "ViewController.h"

#import "BluetoothManager.h"

#import "SearchResultView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {

    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
}

- (IBAction)beginSearchBluetooth:(id)sender {
    
    __block BOOL show = YES;
    
    [[BluetoothManager shareBluetoothManager] searchPeripherals:^(NSMutableArray *resultArray) {
                
        if (resultArray.count > 0 && show) {
            
            SearchResultView *v= [[SearchResultView alloc] initWithPeripherals:resultArray clickSelectedPeripheral:^(CBPeripheral *peripheral) {
                
                
            }];
            
            [v show];
            
            show = NO;

        }
        
    }];;

}


- (IBAction)disconnectBluetooth:(id)sender {
    
    [[BluetoothManager shareBluetoothManager] disconnectBluetooth];
    
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];

}

@end
