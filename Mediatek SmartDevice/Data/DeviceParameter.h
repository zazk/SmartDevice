//
//  DevciceParameter.h
//  BLEManager
//
//  Created by changjiang on 14-7-21.
//  Copyright (c) 2014年 com.mediatek. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceParameter : NSObject

@property (nonatomic) NSString* mDeviceIdentifier;
@property (nonatomic) NSString* mDeviceName;
@property (nonatomic) BOOL mAlertEnabler;
@property (nonatomic) BOOL mRangeAlertEnabler;
@property (nonatomic) BOOL mDisconnectAlertEnabler;
@property (nonatomic) BOOL mRingtoneEnabler;
@property (nonatomic) BOOL mVibrationEnabler;
@property (nonatomic) int mRangeType;
@property (nonatomic) int mRangeValue;

@end
