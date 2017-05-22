//
//  CachedBLEDevice.h
//  BLEManager
//
//  Created by ken on 14-7-11.
//  Copyright (c) 2014年 com.mediatek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTKBleManager.h"
#import "MTKBleProximityService.h"

// device value change
const static int DEVICE_CONNECTION_STATE_CHANGE = 0;                    //indicate device connection state changed
const static int DEVICE_NAME_CHANGE = 1;                                //indicate device name changed
const static int DEVICE_FINDING_STATE_CHANGE = 2;                       //indicate device finding state changed
const static int DEVICE_PERIPHERAL_CHANGE = 3;                          //indicate device Peripheral changed, used to do connect, disconnect action
const static int DEVICE_SIGNAL_STRENGTH_CHANGE = 4;                     //indicate device RSSI changed
const static int DEVICE_RANGE_STATE_CHANGE = 5;                         //indicate device device range status change
const static int DEVICE_ALERT_STATE_CHANGE = 6;                         //indicate device alert state change

// device configuration state changed
const static int CONFIG_ALERT_SWITCH_STATE_CHANGE = 100;                //indicate device alert switch state changed
const static int CONFIG_RANGE_ALERT_SWITCH_STATE_CHANGE = 101;          //indicate device range alert switch state changed
const static int CONFIG_RANGE_WHEN_CHOOSER_STATE_CHANGE = 102;          //indicate device when chooser state changed
const static int CONFIG_RANGE_SIZE_CHOOSER_STATE_CHANGE = 103;          //indicate device range size chooser state changed
const static int CONFIG_DISCONNECT_ALERT_SWITCH_STATE_CHANGE = 104;     //indicate device disconnection alert switch state changed
const static int CONFIG_RINGTONE_SWITCH_STATE_CHANGE = 105;             //indicate device ringtone switch state changed
const static int CONFIG_VIBRATION_SWITCH_STAE_CHANGE = 106;             //indicate device vibration switch state changed

const static int CONFIGURATION_STATE_ON = 1;
const static int CONFIGURATION_STATE_OFF = 0;

const static int SIGNAL_VALUE_1 = 95;
const static int SIGNAL_VALUE_2 = 85;
const static int SIGNAL_VALUE_3 = 75;
const static int SIGNAL_VALUE_4 = 65;

// device signal strength value
const static int SIGNAL_STRENGTH_FOUR = 4;
const static int SIGNAL_STRENGTH_THREE = 3;
const static int SIGNAL_STRENGTH_TWO = 2;
const static int SIGNAL_STRENGTH_ONE = 1;
const static int SIGNAL_STRENGTH_NULL = 0;

const static int ALERT_STATE_ON = 1;
const static int ALERT_STATE_OFF = 0;

const static int FINDING_STATE_ON = 1;
const static int FINDING_STATE_OFF = 0;

const static int RANGE_STATUS_OUT_OF_RANGE = 1;
const static int RANGE_STATUS_IN_RANGE = 0;
const static int RANGE_STATUS_NONE = -1;

@protocol CachedBLEDeviceDelegate

-(void)onDeviceAttributeChanged:(int)which;

@end

@interface CachedBLEDevice : NSObject </*BleConnectDlegate, */ProximityAlarmProtocol>

@property NSString* mDeviceName;
@property NSString* mDeviceIdentifier;

@property int mRangeValue;                                                  //indicate device range size to alert out (Near, Middle, Far)
@property int mRangeType;                                                   //indicate device range in or out (in range, out of range)

@property bool mAlertEnabled;
@property bool mRangeAlertEnabled;
@property bool mDisconnectEnabled;
@property bool mRingtoneEnabled;
@property bool mVibrationEnabled;

@property int mConnectionState;

//@property int mRingingState;

@property int mFindingState;
@property int mAlertState;

@property int mRangeStatus;

@property MTKBleManager* mManager;
@property CBPeripheral* mDevicePeripheral;

@property NSMutableArray* mAttributeListeners;

// add for PXP
@property int mCurrentSignalStrength;
@property int mCurrentAlertStatus;

    
+(CachedBLEDevice*)defaultInstance;


-(void)persistData:(int)which;

-(void)loadFinished;

-(void)registerAttributeChangedListener:(id<CachedBLEDeviceDelegate>)delegate;
-(void)unregisterAttributeChangedListener:(id<CachedBLEDeviceDelegate>)delegate;

-(void)setDevicePeripheral:(CBPeripheral*)peripheral;
-(CBPeripheral*)getDevicePeripheral;

-(void)setDeviceFindingState:(int)state;
-(void)updateAlertState:(int)state;

-(void)updateDeviceConfiguration:(int)which changedValue:(int)value;

-(void)updateDeviceConnectionState:(CBPeripheral*)peripheral connectionState:(int)state;

@end
