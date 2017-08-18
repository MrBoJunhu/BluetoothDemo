//
//  BluetoothManager.h
//  BluetoothDemo
//
//  Created by BillBo on 2017/8/18.
//  Copyright © 2017年 BillBo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

typedef void(^searchResultBlock)(NSMutableArray *resultArray);

@interface BluetoothManager : NSObject

+(instancetype)shareBluetoothManager;

/**
 搜索外设

 @param result result description
 */
- (void)searchPeripherals:(searchResultBlock)result;


/**
 连接外设

 @param peripheral peripheral description
 */
- (void)connectCBPeripheral:(CBPeripheral *)peripheral;

@end
