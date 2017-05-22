//
//  CachedBLEDevice.m
//  BLEManager
//
//  Created by ken on 14-7-11.
//  Copyright (c) 2014年 com.mediatek. All rights reserved.
//

#import "CachedBLEDevice.h"
#import "MTKDeviceParameterRecorder.h"
#import "MTKBleProximityService.h"

@implementation CachedBLEDevice

@synthesize mDeviceName;
@synthesize mDeviceIdentifier;
@synthesize mConnectionState;

//@synthesize mRangeValue;
//@synthesize mRangeType;
//@synthesize mRangeAlertEnabled;
//@synthesize mAlertEnabled;
//@synthesize mDisconnectEnabled;
//@synthesize mRingtoneEnabled;
//@synthesize mVibrationEnabled;

//@synthesize mRingingState;
//@synthesize mAlertState;

@synthesize mRangeStatus;

@synthesize mManager;

@synthesize mCurrentSignalStrength;
//@synthesize mCurrentAlertStatus;

@synthesize mAttributeListeners;

static CachedBLEDevice* instance;

+(CachedBLEDevice*)defaultInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLog(@"[CachedBLEDevice] [defaultInstance] begin to init");
        instance = [[CachedBLEDevice alloc] init];
        [instance initDeviceState];
    });
    return instance;
}

-(void)initDeviceState
{
    mAttributeListeners = [[NSMutableArray alloc] init];
    mManager = [MTKBleManager sharedInstance];
    /*
    NSUUID* idenUuid = [[NSUUID alloc] initWithUUIDString:mDeviceIdentifier];
    
    NSLog(@"[CachedBLEDevice] [initDeviceState] idenUuid : %@", idenUuid);
    
    NSArray* array = [[NSArray alloc] initWithObjects:idenUuid, nil];
    NSLog(@"[CachedBLEDevice] [initDeviceState] array count : %lu", (unsigned long)array.count);
    
    if (array.count != 0)
    {
        NSLog(@"[CachedBLEDevice] [initDeviceState] try to retrievePeripherals");
        [mManager retrievePeripherals:array];
    }*/
//    [mManager registerConnectDelgegate:instance];
    
    //[mManager registerProximityDelgegate:instance];
    [[MTKBleProximityService getInstance] registerProximityDelgegate: instance];
    
    mRangeStatus = RANGE_STATUS_NONE;
    mCurrentSignalStrength = SIGNAL_STRENGTH_NULL;
    self.mAlertState = ALERT_STATE_OFF;
}

-(void)persistData:(int)which
{
    if (which != 1 && which != 2)
    {
        NSLog(@"[CachedBLEDevice] [persistData] which is not equal 1 & 2");
        return;
    }
    [MTKDeviceParameterRecorder setParameters:which deviceName:mDeviceName deviceIdentifier:mDeviceIdentifier alertEnabler:self.mAlertEnabled rangeAlertEnabler:self.mRangeAlertEnabled rangeType:self.mRangeType rangeValue:self.mRangeValue disconnectAlertEnabler:self.mDisconnectEnabled ringtoneEnabler:self.mRingtoneEnabled vibrationEnabler:self.mVibrationEnabled];
}

/********************************************************************************************/
/* after load data from DB, should try to query the device distance and alert status value  */
/********************************************************************************************/
-(void)loadFinished
{
    NSLog(@"[CachedBLEDevice] [loadFinished] enter");
    if (self.mDevicePeripheral != nil)
    {
        if (mConnectionState == CONNECTION_STATE_CONNECTED)
        {
            [self updateCurrentSignalStrength:[[MTKBleProximityService getInstance] queryDistance:self.mDevicePeripheral]];
            NSLog(@"[CachedBLEDevice] [loadFinished] alert state from blemanager : %d", [[MTKBleProximityService getInstance] getIsNotifyRemote:self.mDevicePeripheral]);
            self.mAlertState = [[MTKBleProximityService getInstance] getIsNotifyRemote:self.mDevicePeripheral];
        }
    }
}

/********************************************************************************************/
/* update the remote bluetooth device peripheral which used to do connect & disconnect      */
/********************************************************************************************/
-(void)setDevicePeripheral:(CBPeripheral*)peripheral
{
    self.mDevicePeripheral = peripheral;
    [self loadFinished];
    [self notifyAttributeChanged:DEVICE_PERIPHERAL_CHANGE];
}

-(CBPeripheral*)getDevicePeripheral
{
    return self.mDevicePeripheral;
}

/********************************************************************************************/
/* if the device attribute has changed, call this method to notify user                     */
/********************************************************************************************/
-(void)notifyAttributeChanged:(int)which
{
    if (mAttributeListeners != nil)
    {
        if ([mAttributeListeners count] != 0)
        {
            for (id<CachedBLEDeviceDelegate> delegate in mAttributeListeners)
            {
                [delegate onDeviceAttributeChanged:which];
            }
        }
    }
}

/********************************************************************************************/
/* register the device attribute change listener. which used to notify the attribute changed*/
/********************************************************************************************/
-(void)registerAttributeChangedListener:(id<CachedBLEDeviceDelegate>)delegate
{
    if (delegate == nil)
    {
        NSLog(@"[CachedBLEDevice] [registerAttributeChangedListener] delegate is nil");
        return;
    }
    if (mAttributeListeners != nil)
    {
        if (![mAttributeListeners containsObject:delegate])
        {
            [mAttributeListeners addObject:delegate];
        }
    }
}

/********************************************************************************************/
/* unregister the device attribute change listener.                                         */
/********************************************************************************************/
-(void)unregisterAttributeChangedListener:(id<CachedBLEDeviceDelegate>)delegate
{
    if (delegate == nil)
    {
        NSLog(@"[CachedBLEDevice] [unregisterAttributeChangedListener] delegate is nil");
        return;
    }
    if (mAttributeListeners != nil)
    {
        if ([mAttributeListeners containsObject:delegate])
        {
            [mAttributeListeners removeObject:delegate];
        }
    }
}

/********************************************************************************************/
/* update the current signal strength and notify UX to update                               */
/********************************************************************************************/
-(void)updateCurrentSignalStrength:(int)signal
{
    if (signal > 0 && signal <= SIGNAL_VALUE_4)
    {
        mCurrentSignalStrength = SIGNAL_STRENGTH_FOUR;
    }
    else if (signal > SIGNAL_VALUE_4 && signal <= SIGNAL_VALUE_3)
    {
        mCurrentSignalStrength = SIGNAL_STRENGTH_THREE;
    }
    else if (signal > SIGNAL_VALUE_3 && signal <= SIGNAL_VALUE_2)
    {
        mCurrentSignalStrength = SIGNAL_STRENGTH_TWO;
    }
    else if (signal > SIGNAL_VALUE_2 && signal <= SIGNAL_VALUE_1)
    {
        mCurrentSignalStrength = SIGNAL_STRENGTH_ONE;
    }
    else
    {
        mCurrentSignalStrength = SIGNAL_STRENGTH_NULL;
    }
//    if (signal > 0 && signal < RANGE_ALERT_THRESH_NEAR)
//    {
//        mCurrentSignalStrength = SIGNAL_STRENGTH_THREE;
//    }
//    else if (signal > RANGE_ALERT_THRESH_NEAR && signal <= RANGE_ALERT_THRESH_MIDDLE)
//    {
//        mCurrentSignalStrength = SIGNAL_STRENGTH_TWO;
//    }
//    else if (signal > RANGE_ALERT_THRESH_MIDDLE && signal < RANGE_ALERT_THRESH_FAR)
//    {
//        mCurrentSignalStrength = SIGNAL_STRENGTH_ONE;
//    }
//    else
//    {
//        mCurrentSignalStrength = SIGNAL_STRENGTH_NULL;
//    }
    [self notifyAttributeChanged:DEVICE_SIGNAL_STRENGTH_CHANGE];
}

/********************************************************************************************/
/* update the ringing state in the UX                                                       */
/********************************************************************************************/
//-(void)updateRingingState
//{
//    int status = -1;
//    if (self.mAlertState == ALERT_STATE_ON || self.mFindingState == FINDING_STATE_ON)
//    {
//        status = RINGING_STATE_ON;
//    }
//    else
//    {
//        status = RINGING_STATE_OFF;
//    }
//    if (status != -1 && status != mRingingState)
//    {
//        mRingingState = status;
//        [self notifyAttributeChanged:DEVICE_RINGING_STATE_CHANGE];
//    }
//}

-(void)updateRangeState:(int)signal
{
    int status;
    if (self.mRangeType == RANGE_ALERT_IN)
    {
        if (self.mRangeValue ==  RANGE_ALERT_FAR)
        {
            if (signal < RANGE_ALERT_THRESH_FAR)
            {
                status = RANGE_STATUS_IN_RANGE;
            }
            else
            {
                status = RANGE_STATUS_NONE;
            }
        }
        else if (self.mRangeValue == RANGE_ALERT_MIDDLE)
        {
            if (signal < RANGE_ALERT_THRESH_MIDDLE)
            {
                status = RANGE_STATUS_IN_RANGE;
            }
            else
            {
                status = RANGE_STATUS_NONE;
            }
        }
        else if (self.mRangeValue == RANGE_ALERT_NEAR)
        {
            if (signal < RANGE_ALERT_THRESH_NEAR)
            {
                status = RANGE_STATUS_IN_RANGE;
            }
            else
            {
                status = RANGE_STATUS_NONE;
            }
        }
    }
    else if (self.mRangeType == RANGE_ALERT_OUT)
    {
        if (self.mRangeValue == RANGE_ALERT_FAR)
        {
            if (signal > RANGE_ALERT_THRESH_FAR)
            {
                status = RANGE_STATUS_OUT_OF_RANGE;
            }
            else if (signal < RANGE_ALERT_THRESH_FAR)
            {
                status = RANGE_STATUS_NONE;
            }
        }
        else if (self.mRangeValue == RANGE_ALERT_MIDDLE)
        {
            if (signal > RANGE_ALERT_THRESH_MIDDLE)
            {
                status = RANGE_STATUS_OUT_OF_RANGE;
            }
            else if (signal < RANGE_ALERT_MIDDLE)
            {
                status = RANGE_STATUS_NONE;
            }
        }
        else if (self.mRangeValue == RANGE_ALERT_NEAR)
        {
            if (signal > RANGE_ALERT_THRESH_NEAR)
            {
                status = RANGE_STATUS_OUT_OF_RANGE;
            }
            else if (signal < RANGE_ALERT_THRESH_NEAR)
            {
                status = RANGE_STATUS_NONE;
            }
        }
    }
    if (mRangeStatus != status)
    {
        mRangeStatus = status;
        [self notifyAttributeChanged:DEVICE_RANGE_STATE_CHANGE];
    }
}

/********************************************************************************************/
/* device connection state change to connected state                                        */
/********************************************************************************************/
/*
- (void) connectDidRefresh:(int)connectionState deviceName:(CBPeripheral*)peripheral
{
    NSLog(@"[CachedBLEDevice] [connectDidRefresh] connecitonState : %i, %@", connectionState, [[peripheral identifier] UUIDString]);
    if ([[[peripheral identifier] UUIDString] isEqualToString: self.mDeviceIdentifier])
    {
        if (connectionState != self.mConnectionState)
        {
            NSLog(@"[CachedBLEDevice] [connectDidRefresh] update the device connecitons tate");
            self.mConnectionState = connectionState;
            [self setDevicePeripheral:peripheral];
            [self loadFinished];
            [self notifyAttributeChanged:DEVICE_CONNECTION_STATE_CHANGE];
        }
    }
}
*/
/********************************************************************************************/
/* device connection state change to disconnected state                                     */
/********************************************************************************************/
/*
- (void) disconnectDidRefresh: (int)connectionState devicename: (CBPeripheral *)peripheral
{
    NSLog(@"[CachedBLEDevice] [disconnectDidRefresh] connecitonState : %i, %@", connectionState, [[peripheral identifier] UUIDString]);
    if ([[[peripheral identifier] UUIDString] isEqualToString: self.mDeviceIdentifier])
    {
        if (connectionState != self.mConnectionState)
        {
            NSLog(@"[CachedBLEDevice] [disconnectDidRefresh] update the device connecitons tate");
            self.mConnectionState = connectionState;
            self.mAlertState = ALERT_STATE_OFF;
            [self notifyAttributeChanged:DEVICE_CONNECTION_STATE_CHANGE];
            
            [self updateCurrentSignalStrength:0];
            
            [self setDeviceFindingState:FINDING_STATE_OFF];
        }
    }
}

-(void) retrieveDidRefresh: (NSArray *)peripherals
{
    if (peripherals == nil)
    {
        NSLog(@"[CachedBLEDevice] [disconnectDidRefresh] retrieveDidRefresh peripherals is nil");
        return;
    }
    if (peripherals.count == 0)
    {
        NSLog(@"[CachedBLEDevice] [disconnectDidRefresh] retrieveDidRefresh peripherals.count is 0");
        return;
    }
    self.mDevicePeripheral = [peripherals objectAtIndex:0];
    [self notifyAttributeChanged:DEVICE_PERIPHERAL_CHANGE];
    NSLog(@"[CachedBLEDevice] [disconnectDidRefresh] retrieveDidRefresh self.mDevicePeripheral : %@", self.mDevicePeripheral);
}
*/
/********************************************************************************************/
/* device PXP distance value changed callback                                               */
/********************************************************************************************/
- (void)distanceChangeAlarm: (CBPeripheral *)peripheral distance: (int)distanceValue
{
    if (peripheral == nil)
    {
        NSLog(@"[CachedBLEDevice] [distanceChangeAlarm] peripheral is nil");
        return;
    }
    if (![[[peripheral identifier] UUIDString] isEqualToString:mDeviceIdentifier])
    {
        NSLog(@"[CachedBLEDevice] [distanceChangeAlarm] not the same device identifier");
        return;
    }
    NSLog(@"[CachedBLEDevice] [distanceChangeAlarm] distanceValue : %i", distanceValue);
    
    [self updateCurrentSignalStrength:distanceValue];
    [self updateRangeState:distanceValue];
}

/********************************************************************************************/
/* device PXP alert status changed callback                                                 */
/********************************************************************************************/
- (void)alertStatusChangeAlarm:(BOOL)alerted
{
    int status = -1;
    if (alerted == YES)
    {
        status = ALERT_STATE_ON;
    }
    else
    {
        status = ALERT_STATE_OFF;
    }
    if (status != -1)
    {
        [self updateAlertState:status];
    }
}

- (void)rssiReadBack: (CBPeripheral *)peripheral status: (int)status rssi: (int)rss
{
    
}
- (void)linkLostAlertLevelSetBack: (CBPeripheral *)peripheral status: (int)status
{
    
}
- (void)txPowerReadBack: (CBPeripheral *)peripheral status: (int)status txPower: (int)txPwoer
{
    
}

/********************************************************************************************/
/* set the device finding state                                                             */
/********************************************************************************************/
-(void)setDeviceFindingState:(int)state
{
    if (state != self.mFindingState)
    {
        self.mFindingState = state;
        [self notifyAttributeChanged:DEVICE_FINDING_STATE_CHANGE];
    }
}

/********************************************************************************************/
/* update the alert status and notify UX to update                                          */
/********************************************************************************************/
-(void)updateAlertState:(int)alert
{
    if (alert != self.mAlertState && mConnectionState == CONNECTION_STATE_CONNECTED)
    {
        self.mAlertState = alert;
        NSLog(@"[CachedBLEDevice] [updateAlertState] alert state change to : %d", self.mAlertState);
        [self notifyAttributeChanged:DEVICE_ALERT_STATE_CHANGE];
    }
}

-(void)updateDeviceConfiguration:(int)which changedValue:(int)value
{
    NSLog(@"[CachedBLEDevice] [updateDeviceConfiguration] which : %d, value : %d", which, value);
    BOOL changed = NO;
    BOOL status = NO;
    
    switch (which)
    {
        case CONFIG_ALERT_SWITCH_STATE_CHANGE:
            status = [self changeStatus:value];
            if (status != self.mAlertEnabled)
            {
                self.mAlertEnabled = status;
                changed = YES;
            }
            break;
            
        case CONFIG_RANGE_ALERT_SWITCH_STATE_CHANGE:
            status = [self changeStatus:value];
            if (status != self.mRangeAlertEnabled)
            {
                self.mRangeAlertEnabled = status;
                changed = YES;
            }
            break;
            
        case CONFIG_RANGE_WHEN_CHOOSER_STATE_CHANGE:
            if (value != self.mRangeType)
            {
                self.mRangeType = value;
                changed = YES;
            }
            break;
            
        case CONFIG_RANGE_SIZE_CHOOSER_STATE_CHANGE:
            if (value != self.mRangeValue)
            {
                self.mRangeValue = value;
                changed = YES;
            }
            break;
            
        case CONFIG_DISCONNECT_ALERT_SWITCH_STATE_CHANGE:
            status = [self changeStatus:value];
            if (status != self.mDisconnectEnabled)
            {
                self.mDisconnectEnabled = status;
                changed = YES;
            }
            break;
            
        case CONFIG_RINGTONE_SWITCH_STATE_CHANGE:
            status = [self changeStatus:value];
            if (status != self.mRingtoneEnabled)
            {
                self.mRingtoneEnabled = status;
                changed = YES;
            }
            break;
            
        case CONFIG_VIBRATION_SWITCH_STAE_CHANGE:
            status = [self changeStatus:value];
            if (status != self.mVibrationEnabled)
            {
                self.mVibrationEnabled = status;
                changed = YES;
            }
            break;
            
        default:
            break;
    }
    if (changed == YES)
    {
        [[MTKBleProximityService getInstance] updatePxpSetting:mDeviceIdentifier alertEnabler:_mAlertEnabled range:_mRangeAlertEnabled rangeType:_mRangeType alertDistance:_mRangeValue disconnectAlertEnabler:_mDisconnectEnabled];
        
        [self notifyAttributeChanged:which];
        [self persistData:2];
    }
}

-(void)updateDeviceConnectionState:(CBPeripheral*)peripheral connectionState:(int)state;
{
    if (peripheral != nil && ([[[peripheral identifier] UUIDString] isEqualToString:mDeviceIdentifier] == NO))
    {
        NSLog(@"[CachedBLEDevice] [updateDeviceConnectionState] peripheral identifier not match");
        return;
    }
    NSLog(@"[CachedBLEDevice] [updateDeviceConnectionState] mConnectionState : %d, state : %d", mConnectionState, state);
    if (mConnectionState != state)
    {
        mConnectionState = state;
        if (mConnectionState == CONNECTION_STATE_CONNECTED)
        {
            NSLog(@"[CachedBLEDevice] [updateDeviceConnectionState] update device connection state to be CONNECTION_STATE_CONNECTED");
            [self setDevicePeripheral:peripheral];
            [self loadFinished];
        }
        else if (mConnectionState == CONNECTION_STATE_DISCONNECTED)
        {
            NSLog(@"[CachedBLEDevice] [updateDeviceConnectionState] update device connection state to be CONNECTION_STATE_DISCONNECTED");
            self.mAlertState = ALERT_STATE_OFF;
            self.mFindingState = FINDING_STATE_OFF;
            [self updateCurrentSignalStrength:0];
            
            [self setDeviceFindingState:FINDING_STATE_OFF];
        }
        [self notifyAttributeChanged:DEVICE_CONNECTION_STATE_CHANGE];
    }
}

-(BOOL)changeStatus:(int)status
{
    if (status == CONFIGURATION_STATE_ON)
    {
        return YES;
    }
    else if (status == CONFIGURATION_STATE_OFF)
    {
        return NO;
    }
    return NO;
}

@end
