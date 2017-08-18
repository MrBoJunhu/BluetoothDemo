//
//  SearchResultView.h
//  BluetoothDemo
//
//  Created by BillBo on 2017/8/18.
//  Copyright © 2017年 BillBo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CBPeripheral;

typedef void(^clickSelectedPeripherals)(CBPeripheral *peripheral);

@interface SearchResultView : UIView

- (instancetype)initWithPeripherals:(NSArray <CBPeripheral *> *)peripherals clickSelectedPeripheral:(clickSelectedPeripherals)peripheral;

- (void)show;


@end
