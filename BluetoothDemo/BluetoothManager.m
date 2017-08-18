//
//  BluetoothManager.m
//  BluetoothDemo
//
//  Created by BillBo on 2017/8/18.
//  Copyright © 2017年 BillBo. All rights reserved.
//

#import "BluetoothManager.h"
//蓝牙库
#import <CoreBluetooth/CoreBluetooth.h>
@interface BluetoothManager()<CBCentralManagerDelegate,  CBPeripheralDelegate>

/**
 管理者中心
 */
@property (nonatomic, strong) CBCentralManager *centralManager;


/**
 当前连接的外设
 */
@property (nonatomic, strong) CBPeripheral * currentPeripheral;

/**
 搜索外设的结果
 */
@property (nonatomic, copy) searchResultBlock searchBlock;

/**
 搜索到的外设组
 */
@property (nonatomic, strong) NSMutableArray *searchResultArray;


/**
 MAC校验
 */
@property (nonatomic, copy) NSString *macAddressStr;


/**
 MAC地址
 */
@property (nonatomic, copy) NSString *MAC_AddressString;

@end


@implementation BluetoothManager

+ (instancetype)shareBluetoothManager {
    
    static BluetoothManager *manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    
    return manager;
    
}

- (instancetype)init{
    
    if (self = [super init]) {
        
    }
    
    return self;
}

- (NSMutableArray *)searchResultArray {
    
    if (!_searchResultArray) {
        
        self.searchResultArray = [NSMutableArray array];
        
    }
    
    return _searchResultArray;

}

#pragma mark - 创建管理者中心

- (CBCentralManager *)centralManager {
    
    if (!_centralManager) {
        
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
    
    return _centralManager;
    
}

#pragma mark - CBCentralManagerDelegate


/**
 蓝牙状态发生改变

 @param central central description
 */
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    
    NSLog(@"\n------------------蓝牙状态发生改变------------------\n");
    
    switch (central.state) {
        case CBManagerStateUnknown:
        {
            NSLog(@"CBManagerStateUnknown");
        }
            break;
        case CBManagerStateResetting:
        {
            NSLog(@"CBManagerStateResetting");
        }
            break;
        case CBManagerStateUnsupported:
        {
            NSLog(@"CBManagerStateUnsupported");
        }
            break;
        case CBManagerStateUnauthorized:
        {
            NSLog(@"CBManagerStateUnauthorized");
        }
            break;
        case CBManagerStatePoweredOff:
        {
            //蓝牙关闭
            NSLog(@"蓝牙关闭   :  CBManagerStatePoweredOff");
        }
            break;
        case CBManagerStatePoweredOn:
        {
            //蓝牙开启
            NSLog(@"蓝牙开启  : CBManagerStatePoweredOn");
     
        }
            break;
        default:
            break;
    }
    
    if (central.state != CBManagerStatePoweredOff) {
        
        [central scanForPeripheralsWithServices:nil options:nil];
        
    }
    //            CBUUID *cbUUID = [CBUUID UUIDWithString:@"FF12"];
    //            [self.centralManager scanForPeripheralsWithServices:@[cbUUID] options:nil];
    
}



- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary<NSString *, id> *)dict {
    
    
    
}


/**
 搜索外围设备

 @param central 中心管理者
 @param peripheral 外设
 @param advertisementData 外设携带的数据
 @param RSSI 外设发出的蓝牙信号强度
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI {
    
    //扫描周围外设
    
    if ([peripheral.name hasPrefix:@"SHHC"] ) {
        
        if (self.searchResultArray.count == 0) {
            
            [self.searchResultArray addObject:peripheral];
            
        }
        
        for (CBPeripheral *per in self.searchResultArray) {
            
            if (per.identifier == peripheral.identifier) {
                
                return;
            
            }
            
            [self.searchResultArray addObject:peripheral];
        
        }
        
    }
    
    self.searchBlock(self.searchResultArray);
    
}

#pragma mark - 过滤设备

- (void)dealSearchReult {
    
    for (CBPeripheral *peripheral in self.searchResultArray) {
        
        if ([peripheral.name hasPrefix:@"SHHC"]) {
            
            
        }
        
    }
    
}




- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    
    NSLog(@"\n😂  -------- 连接外设成功 -------- 😂");
   
    self.currentPeripheral.delegate = self;
    
    CBUUID *macServiceUUID = [CBUUID UUIDWithString:@"180A"];

    [self.currentPeripheral discoverServices:@[macServiceUUID]];

}


- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error {
    
    
}


- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error {
    
    NSLog(@"\n⚠️ ------ 自动断开与外设的连接 -------- ⚠️");
    
}



#pragma mark - 外设代理 CBPeripheralDelegate

- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral NS_AVAILABLE(NA, 6_0)  {
    
    
}

- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray<CBService *> *)invalidatedServices NS_AVAILABLE(NA, 7_0) {
    
    
}

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(nullable NSError *)error NS_DEPRECATED(NA, NA, 5_0, 8_0) {
    
    
}


- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(nullable NSError *)error NS_AVAILABLE(NA, 8_0) {
    
    
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(nullable NSError *)error {
    
    
    NSLog(@"发现服务");
    //服务
    CBService *deviceService = peripheral.services.firstObject;
    
    CBUUID *macCharcteristicUUID = [CBUUID UUIDWithString:@"2A23"];
    
    [self.currentPeripheral discoverCharacteristics:@[macCharcteristicUUID] forService:deviceService];
    
}


- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(nullable NSError *)error {
    
    
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(nullable NSError *)error {
    
    //连接到服务数据
    CBUUID *macCharcteristicUUID = [CBUUID UUIDWithString:@"2A23"];
    
    if (service.characteristics.count == 0) {
    
        self.macAddressStr = [NSString stringWithFormat:@"OLD BLE:%@", self.currentPeripheral.name];
        
    }else{
        
        for (CBCharacteristic *characteristic in service.characteristics) {
            
            if ([characteristic.UUID isEqual:macCharcteristicUUID]) {
                
                [self.currentPeripheral readValueForCharacteristic:characteristic];
                
            }
            
        }

    }
    
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    
    NSLog(@"/n 🍎 didUpdateValueForCharacteristic : 此处获取MAC 地址 🍎");
    
    CBUUID *systemID = [CBUUID UUIDWithString:@"2A23"];
    
    if ([characteristic.UUID isEqual:systemID]) {
        
      self.macAddressStr = [self getMacAddressWithCBCharacteristic:characteristic];
        
    }
    
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    
    
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    
    
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    
    
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(nullable NSError *)error {
    
    
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(nullable NSError *)error {
    
    
}
#pragma mark - 对外接口

- (void)searchPeripherals:(searchResultBlock)result {
    
    self.searchBlock = result;
    
    [self.searchResultArray removeAllObjects];
    
    if (self.centralManager.state != CBManagerStatePoweredOff) {
        
        [self.centralManager scanForPeripheralsWithServices:nil options:nil];

    }else{
        
        NSLog(@"请检查手机的蓝牙设置");
        
    }
    
}

/**
 连接外设
 @param peripheral peripheral description
 */
- (void)connectCBPeripheral:(CBPeripheral *)peripheral {
   
    self.currentPeripheral = peripheral;
    
    [_centralManager connectPeripheral:peripheral options:nil];
    
}

/**
 主动断开蓝牙连接
 */
- (void)disconnectBluetooth {
    
    if (self.centralManager && self.currentPeripheral) {
        
        [self.centralManager cancelPeripheralConnection:self.currentPeripheral];
        
    }
    
}


#pragma mark - 获取设备的mac地址

- (NSString *)getMacAddressWithCBCharacteristic:(CBCharacteristic *)characteristic {
    
    NSString *value = [NSString stringWithFormat:@"%@",characteristic.value];
    
    NSMutableString*macString = [[NSMutableString alloc]init];
    
    [macString appendString:[[value substringWithRange:NSMakeRange(16,2)] uppercaseString]];
    
    [macString appendString:@":"];
    
    [macString appendString:[[value substringWithRange:NSMakeRange(14,2)]uppercaseString]];
    
    [macString appendString:@":"];
    
    [macString appendString:[[value substringWithRange:NSMakeRange(12,2)]uppercaseString]];
    
    [macString appendString:@":"];
    
    [macString appendString:[[value substringWithRange:NSMakeRange(5,2)]uppercaseString]];
    
    [macString appendString:@":"];
    
    [macString appendString:[[value substringWithRange:NSMakeRange(3,2)]uppercaseString]];
    
    [macString appendString:@":"];
    
    [macString appendString:[[value substringWithRange:NSMakeRange(1,2)]uppercaseString]];
    
    NSLog(@"MAC地址是 : %@",macString);
  
    return macString;

}


@end
