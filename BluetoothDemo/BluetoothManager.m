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



#define DATA_HEAD_1     0x64
#define DATA_HEAD_2     0x95

//用户指令
#define DATA_ZL_02           0x02           //02指令，需输入用户信息
#define DATA_ZL_02_NUMBER    0x0C           //发送02指令的位数

#define DATA_ZL_07           0x07           //07指令，接收信息

#define DATA_ZL_08           0x08           //08指令，接收信息

#define DATA_ZL_09           0x09           //09指令，体重清零
#define DATA_ZL_09_NUMBER       1           //发送09指令的位数

#define DATA_ZL_017          0x17           //回传给秤的命令号
#define DATA_ZL_017_NUMBER      5           //发送017指令的位数



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
 设备的MAC地址(连接到的设备的蓝牙id)
 */
@property (nonatomic, copy) NSString *MAC_AddressString;

@property (nonatomic, retain) NSMutableString * firstStr;
@property (nonatomic, retain) NSMutableString * secondStr;
@property (nonatomic,retain) NSMutableData *receiveNewData;
@property (nonatomic,retain) NSMutableData *receiveData;
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
        
    
        self.firstStr = [[NSMutableString alloc] initWithString:@""];
        self.secondStr = [[NSMutableString alloc] initWithString:@""];
        self.receiveNewData = [NSMutableData data];
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
            self.currentPeripheral = nil;
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
  
    //开始扫描服务中的特征
    [peripheral discoverCharacteristics:@[macCharcteristicUUID] forService:deviceService];
    
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
                
                //读取特征数据
                [peripheral readValueForCharacteristic:characteristic];
                
            }
            
        }

    }
    
    
}

/*
 "access_token" = "0Pmg0UmrnZBYbcPABC5YB0pSqNXOFnB885ZYInLptG8YvAZsT87oGUPZtU5wbAad-26xsvP8Ov_eoq6Mj9rISg-XZiz2xesbiiqYPWK0AeYquQ8fXwXNpmvL0XwbUkse";
 macid = "68:9E:19:2D:6E:2A";

 */

//读取了特征包含的相关信息，只要读取就会进入
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    
    NSLog(@"/n 🍎 didUpdateValueForCharacteristic : 此处获取MAC 地址 🍎");
    
    CBUUID *systemID = [CBUUID UUIDWithString:@"2A23"];
    
    if ([characteristic.UUID isEqual:systemID]) {
        
      self.macAddressStr = [self getMacAddressWithCBCharacteristic:characteristic];
        
    }
    
    NSData *receiveData = characteristic.value;
    
    [self didRecieveData:receiveData];
    
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


//接收设备数据

- (void)didRecieveData:(NSData *)data {
   
    NSLog(@"接收设备数据====%@",data);
    
    [self.receiveNewData appendData:data];
    
    NSString * subStr = [self.receiveNewData.description stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    subStr = [subStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSLog(@"all subStr = %@", subStr);
    {
        if (subStr.length >= 30) {
            //开始测量数据通知
            for (int i = 0; i < subStr.length - 20; i ++) {
                
                if ([subStr characterAtIndex:i] == '6' && [subStr characterAtIndex:i + 1] == '4' && [subStr characterAtIndex:i + 2] == '9' && [subStr characterAtIndex:i + 3] == '5' && [subStr characterAtIndex:i + 7] == '8' && [subStr characterAtIndex:i + 19] == '3' && ([subStr characterAtIndex:i + 9] == '3' || [subStr characterAtIndex:i + 9] == '5')) {
                    
                    [self parseNewBleProtocal:subStr];
                    
                    break;
                }
            }
        }
        
        if (subStr.length >= 30) {
            //开始测量数据通知
            for (int i = 0; i < subStr.length - 20; i ++) {
                
                if ([subStr characterAtIndex:i] == '6' && [subStr characterAtIndex:i + 1] == '4' && [subStr characterAtIndex:i + 2] == '9' && [subStr characterAtIndex:i + 3] == '5' && [subStr characterAtIndex:i + 7] == '8' && [subStr characterAtIndex:i + 19] == '2' && ([subStr characterAtIndex:i + 9] == '4' || [subStr characterAtIndex:i + 9] == '7')) {
                    
                    [self parseOldBleProtocal:subStr];
                    
                    break;
                }
            }
        }
    }
    
    if (data) {
        
        [self.receiveData appendData:data];
        
        [self jyData];
        
    }
}

- (void)parseNewBleProtocal:(NSString *)subStr
{
    {
        //解析新的蓝牙协议
        int index = 0;
        
        int a = 0;
        
        if (subStr.length >= 30) {
            
            for (int i = 0; i < subStr.length - 20; i ++) {
                
                if ([subStr characterAtIndex:i] == '6' && [subStr characterAtIndex:i + 1] == '4' && [subStr characterAtIndex:i + 2] == '9' && [subStr characterAtIndex:i + 3] == '5' && [subStr characterAtIndex:i + 7] == '8' && [subStr characterAtIndex:i + 19] == '3' && ([subStr characterAtIndex:i + 9] == '3' || [subStr characterAtIndex:i + 9] == '5')) { // 修改频段号  1改为4  7
                    NSLog(@"i = 什么 = %c i = %d firstStrLength = %lu", [subStr characterAtIndex:i], i, (unsigned long)self.firstStr.length);
                    
                    index = i + 10;
                    
                    if (subStr.length > index + 50 + 16) {
                        
                        if (a == 0) {
                            
                            if(self.firstStr.length != 50 + 16){
                                
                                //                    NSString * ss = [subStr substringWithRange:NSMakeRange(186, 222)];
                                
                                for (int j = index; j < index + 52 + 16; j ++) {
                                    
                                    if (j != index + 8 && j != index + 9) {
                                        
                                        [_firstStr appendString:[NSString stringWithFormat:@"%c", [subStr characterAtIndex:j]]];
                                    }
                                }
                                
                                NSString * sss = [_firstStr substringToIndex:8];
                                
                                NSLog(@"sssss first= %@", sss);
                                
                                float aaaaa = [self getFloatFromData:[self ddMsg:[self getDataFromString:sss]]];
                                
                                NSLog(@"全部出来first = %@---%@ %f", _firstStr, _secondStr, aaaaa);
                                
                                NSLog(@"firstStr = %@",_firstStr);
                                
                                NSLog(@"蓝牙问题：解析第一部分完成＝%@, %f", _firstStr, aaaaa);
                            }
                            
                            a = 1;
                        }else{
                            
                            if (_firstStr.length == 50 + 16) {
                                
                                for (int j = index; j < index + 52 + 16; j ++) {
                                    
                                    if (j != index + 8 && j != index + 9) {
                                        
                                        [_secondStr appendString:[NSString stringWithFormat:@"%c", [subStr characterAtIndex:j]]];
                                    }
                                }
                                
                                NSString * sss = [_secondStr substringToIndex:8];
                                
                                NSLog(@"sssss second = %@", sss);
                                
                                float aaaaa = [self getFloatFromData:[self ddMsg:[self getDataFromString:sss]]];
                                
                                NSLog(@"全部出来second = %@---%@ %f", _firstStr, _secondStr, aaaaa);
                                NSLog(@"蓝牙问题：解析第二部分完成＝%@, %f", _secondStr, aaaaa);
                            }
                        }
                    }
                    
                    if (_firstStr.length == 50 + 16 && _secondStr.length == 50 + 16) {
                        
                        NSLog(@"meici wancheng str = %@", subStr);
                        
                        NSLog(@"蓝牙问题：接收秤数据完成＝%@", subStr);
                        
                        NSMutableArray * dataArr = [NSMutableArray array];
                        
                        //解析16进制数据
                        NSString * sss = [_secondStr substringToIndex:8];
                        
                        NSLog(@"sssss second = %@", sss);
                        
                        float aaaaa = [self getFloatFromData:[self ddMsg:[self getDataFromString:sss]]];
                        
                        NSDictionary * dict = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%f", aaaaa] forKey:@"weight"];
                        
                        [dataArr addObject:dict];
                        
                        NSMutableArray * tempArr = [NSMutableArray array];
                        
                        for (int i = 1; i <= 7; i ++) {
                            
                            NSString * s = [_firstStr substringToIndex:8 * (i + 1)];
                            
                            s = [s substringFromIndex:8 * i];
                            
                            float a = [self getFloatFromData:[self ddMsg:[self getDataFromString:s]]];
                            
                            [tempArr addObject:[NSString stringWithFormat:@"%f", a]];
                            
                        }
                        
                        NSDictionary * dict1 = [NSDictionary dictionaryWithObject:tempArr forKey:@"ZL0x1"];
                        
                        [dataArr addObject:dict1];
                        
                        NSMutableArray * tempArr1 = [NSMutableArray array];
                        
                        for (int i = 1; i <= 7; i ++) {
                            
                            NSString * s = [_secondStr substringToIndex:8 * (i + 1)];
                            
                            s = [s substringFromIndex:8 * i];
                            
                            float a = [self getFloatFromData:[self ddMsg:[self getDataFromString:s]]];
                            
                            [tempArr1 addObject:[NSString stringWithFormat:@"%f", a]];
                        }
                        
                        NSDictionary * dict2 = [NSDictionary dictionaryWithObject:tempArr1 forKey:@"ZL0x7"];
                        
                        [dataArr addObject:dict2];
                        
                        NSLog(@"蓝牙问题：解析数据完成！通知上传函数！");
//                        [[NSNotificationCenter defaultCenter] postNotificationName:BLUETOOTHMANAGER_JSSBSJ object:nil userInfo:@{@"data": dataArr}];
                        
                        [self.receiveNewData setLength:0];
                        
                        [self.firstStr setString:@""];
                        [self.secondStr setString:@""];
                    }
                }
            }
        }
    }
}

//校验数据

-(void)jyData {
    //
    Byte *byte = (Byte *)[_receiveData bytes];
   
    NSLog(@"receiveData = %d %@", (int)_receiveData.length ,_receiveData);
    
    if (_receiveData.length>=4) {
        
        //包含包头和数据长度
        if (byte[0] == DATA_HEAD_1 && byte[1] == DATA_HEAD_2) {
            
            //正常数据
            //获取指令
            int zl = byte[3];
            
            NSLog(@"获取指令的值是：%d", zl);
            if (zl == DATA_ZL_02) {
                //发送用户信息
//                if ([self getDataSucess]) {
//                    [self sendUserMsg];
                    [self.receiveData setLength:0];
                    
//                }
            }else if (zl == DATA_ZL_07){
                //接收信息
//                if ([self getDataSucess]) {
//                    [self getUserMsg];
                
                    [self.receiveData setLength:0];
//                }
            }else if(zl == DATA_ZL_08){
                
                NSLog(@"receiveNewData = %@", self.receiveNewData);
                
                NSLog(@"receiveData = %d %@", (int)self.receiveData.length ,self.receiveData);
                
                
//                if ([self getDataSucess]) {
                    [self.self.receiveData setLength:0];
//                }
            }
        }else{
            //清空数据
            [self.self.receiveData setLength:0];
        }
        
    }else{
        if (self.receiveData.length == 1 && byte[0] != DATA_HEAD_1) {
            [self.self.receiveData setLength:0];
        }else if ((self.receiveData.length == 2 || self.receiveData.length == 3) && (byte[0] != DATA_HEAD_1 || byte[1] != DATA_HEAD_2)){
            [self.self.receiveData setLength:0];
        }
    }
}




#pragma mark 解析新旧蓝牙数据

- (void)parseOldBleProtocal:(NSString *)subStr
{
    int index = 0;
    
    int a = 0;
    
    if (subStr.length >= 30) {
        
        for (int i = 0; i < subStr.length - 20; i ++) {
            
            if ([subStr characterAtIndex:i] == '6' && [subStr characterAtIndex:i + 1] == '4' && [subStr characterAtIndex:i + 2] == '9' && [subStr characterAtIndex:i + 3] == '5' && [subStr characterAtIndex:i + 7] == '8' && [subStr characterAtIndex:i + 19] == '2' && ([subStr characterAtIndex:i + 9] == '4' || [subStr characterAtIndex:i + 9] == '7')) { // 修改频段号  1改为4  7
                NSLog(@"i = 什么 = %c i = %d firstStrLength = %lu", [subStr characterAtIndex:i], i, (unsigned long)self.firstStr.length);
                
                index = i + 10;
                
                if (subStr.length > index + 50) {
                    
                    if (a == 0) {
                        
                        if(self.firstStr.length != 50){
                            
                            //                    NSString * ss = [subStr substringWithRange:NSMakeRange(186, 222)];
                            
                            for (int j = index; j < index + 52; j ++) {
                                
                                if (j != index + 8 && j != index + 9) {
                                    
                                    [_firstStr appendString:[NSString stringWithFormat:@"%c", [subStr characterAtIndex:j]]];
                                }
                            }
                            
                            NSString * sss = [_firstStr substringToIndex:8];
                            
                            NSLog(@"sssss first= %@", sss);
                            
                            float aaaaa = [self getFloatFromData:[self ddMsg:[self getDataFromString:sss]]];
                            
                            NSLog(@"全部出来first = %@---%@ %f", _firstStr, _secondStr, aaaaa);
                            
                            NSLog(@"firstStr = %@",_firstStr);
                            
                            NSLog(@"蓝牙问题：解析第一部分完成＝%@, %f", _firstStr, aaaaa);
                        }
                        
                        a = 1;
                    }else{
                        
                        if (_firstStr.length == 50) {
                            
                            for (int j = index; j < index + 52; j ++) {
                                
                                if (j != index + 8 && j != index + 9) {
                                    
                                    [_secondStr appendString:[NSString stringWithFormat:@"%c", [subStr characterAtIndex:j]]];
                                }
                            }
                            
                            NSString * sss = [_secondStr substringToIndex:8];
                            
                            NSLog(@"sssss second = %@", sss);
                            
                            float aaaaa = [self getFloatFromData:[self ddMsg:[self getDataFromString:sss]]];
                            
                            NSLog(@"全部出来second = %@---%@ %f", _firstStr, _secondStr, aaaaa);
                            NSLog(@"蓝牙问题：解析第二部分完成＝%@, %f", _secondStr, aaaaa);
                        }
                    }
                }
                
                if (_firstStr.length == 50 && _secondStr.length == 50) {
                    //解析数据完成
                    
                    NSLog(@"meici wancheng str = %@", subStr);
                    
                    NSLog(@"蓝牙问题：接收秤数据完成＝%@", subStr);
                    
                    NSMutableArray * dataArr = [NSMutableArray array];
                    
                    //解析16进制数据
                    NSString * sss = [_secondStr substringToIndex:8];
                    
                    NSLog(@"sssss second = %@", sss);
                    
                    float aaaaa = [self getFloatFromData:[self ddMsg:[self getDataFromString:sss]]];
                    
                    NSDictionary * dict = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%f", aaaaa] forKey:@"weight"];
                    
                    [dataArr addObject:dict];
                    
                    NSMutableArray * tempArr = [NSMutableArray array];
                    
                    for (int i = 1; i <= 5; i ++) {
                        
                        NSString * s = [_firstStr substringToIndex:8 * (i + 1)];
                        
                        s = [s substringFromIndex:8 * i];
                        
                        float a = [self getFloatFromData:[self ddMsg:[self getDataFromString:s]]];
                        
                        [tempArr addObject:[NSString stringWithFormat:@"%f", a]];
                    }
                    
                    NSDictionary * dict1 = [NSDictionary dictionaryWithObject:tempArr forKey:@"ZL0x1"];
                    
                    [dataArr addObject:dict1];
                    
                    NSMutableArray * tempArr1 = [NSMutableArray array];
                    
                    for (int i = 1; i <= 5; i ++) {
                        
                        NSString * s = [_secondStr substringToIndex:8 * (i + 1)];
                        
                        s = [s substringFromIndex:8 * i];
                        
                        float a = [self getFloatFromData:[self ddMsg:[self getDataFromString:s]]];
                        
                        
                        [tempArr1 addObject:[NSString stringWithFormat:@"%f", a]];
                    }
                    
                    NSDictionary * dict2 = [NSDictionary dictionaryWithObject:tempArr1 forKey:@"ZL0x7"];
                    
                    [dataArr addObject:dict2];
                    NSLog(@"蓝牙问题：解析数据完成！通知上传函数！");
                    
                    [self.self.receiveNewData setLength:0];
                    
                    [self.firstStr setString:@""];
                    [self.secondStr setString:@""];
                }
            }
        }
    }
}

#pragma mark - 小端模式，颠倒信息

-(NSData*)ddMsg:(NSData*)oldData
{
    NSMutableData *data = [NSMutableData dataWithCapacity:1];
    
    Byte *byte = (Byte *)[oldData bytes];
    for (int i = (int)oldData.length-1; i >= 0; i--) {
        int c = byte[i];
        [data appendData:[self getdata:[NSString stringWithFormat:@"%d",c]]];
    }
    return data;
}



#pragma mark - 转换16进制流

-(NSData*)getdata:(NSString*)old
{
    Byte bb1=[old intValue];
    NSData *dd1 = [[NSData alloc] initWithBytes:&bb1 length:sizeof(bb1)];
    return dd1;
}


#pragma mark - 将NSString转换成对应字符的NSData

-(NSData*)getDataFromString:(NSString*)text
{
    ///// 将16进制数据转化成Byte 数组
    NSString *hexString = text; //16进制字符串
    int j=0;
    Byte bytes[hexString.length/2];
    ///3ds key的Byte 数组， 128位
    for(int i=0;i<[hexString length];i++)
    {
        int int_ch; /// 两位16进制数转化后的10进制数
        
        unichar hex_char1 = [hexString characterAtIndex:i]; ////两位16进制数中的第一位(高位*16)
        int int_ch1;
        if(hex_char1 >= '0' && hex_char1 <='9')
            int_ch1 = (hex_char1-48)*16; //// 0 的Ascll - 48
        else if(hex_char1 >= 'A' && hex_char1 <='F')
            int_ch1 = (hex_char1-55)*16; //// A 的Ascll - 65
        else
            int_ch1 = (hex_char1-87)*16; //// a 的Ascll - 97
        i++;
        
        unichar hex_char2 = [hexString characterAtIndex:i]; ///两位16进制数中的第二位(低位)
        int int_ch2;
        if(hex_char2 >= '0' && hex_char2 <='9')
            int_ch2 = (hex_char2-48); //// 0 的Ascll - 48
        else if(hex_char1 >= 'A' && hex_char1 <='F')
            int_ch2 = hex_char2-55; //// A 的Ascll - 65
        else
            int_ch2 = hex_char2-87; //// a 的Ascll - 97
        
        int_ch = int_ch1+int_ch2;
        NSLog(@"int_ch=%d",int_ch);
        bytes[j] = int_ch; ///将转化后的数放入Byte数组里
        j++;
    }
    NSData *newData = [[NSData alloc] initWithBytes:bytes length:hexString.length/2];
    
    return newData;
}


#pragma mark - nsdata转换成float

-(float)getFloatFromData:(NSData*)data
{
    Byte *tbytes = (Byte*)[data bytes];
    int bint = 0;
    for (int i = 0; i < [data length]; i++) {
        bint += ((tbytes[i]&0xff)<<(8*([data length]-1-i)));
    }
    float bfloat = *(float*)&bint;
    return bfloat;
}


@end
