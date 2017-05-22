//
//  BackgroundManager.m
//  BLEManager
//
//  Created by user on 14-7-25.
//  Copyright (c) 2014年 com.mediatek. All rights reserved.
//

#import "BackgroundManager.h"
#import "FmpGattClient.h"
#import "PdmsSleepService.h"
#import "BloodPressureService.h"
#import "BodyTemperatureService.h"
#import "MTKBleProximityService.h"

@interface BackgroundManager()
{
@private

    NSMutableArray* stateChangeDelegateList;
    CBCentralManagerState centralManagerState;
    int scanningState;
}
@end

@implementation BackgroundManager

@synthesize mManager;
@synthesize alert;

@synthesize tempPeripheral;

@synthesize alertDialog;
@synthesize alertNotification;

@synthesize mAlertType;
@synthesize mDialogShowedUp;
@synthesize mNotificationShowedUp;
@synthesize mRingtoneAlerting;

@synthesize mAppCurrentState;

static BackgroundManager* instance;

+(BackgroundManager*)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLog(@"[BackgroundManager] [sharedInstance] begin to init");
        instance = [[BackgroundManager alloc] init];
        [instance initilize];
    });
    return instance;
}

-(void)initilize
{
    stateChangeDelegateList = [[NSMutableArray alloc] init];
    
    
    [FmpGattClient getInstance];
    [PdmsSleepService getInstance];
    [BloodPressureService getInstance];
    [BodyTemperatureService getInstance];
    [MTKBleProximityService getInstance];
    
    mManager = [MTKBleManager sharedInstance];
    [mManager registerDiscoveryDelgegate:self];
    [mManager registerBluetoothStateChangeDelegate:self];
    [mManager registerConnectDelgegate:self];
    [mManager registerScanningStateChangeDelegate:self];
    [[CachedBLEDevice defaultInstance] registerAttributeChangedListener:self];
    alert = [PhoneRinger sharedInstance];
    mAppCurrentState = APP_CURRENT_FOREGROUND;
    scanningState = SCANNING_STATE_OFF;
}

-(void)dealloc
{
    [mManager unRegisterDiscoveryDelgegate:self];
    [mManager unRegisterBluetoothStateChangeDelegate:self];
    [mManager unRegisterConnectDelgegate:self];
    [mManager unRegisterBluetoothStateChangeDelegate:self];
    [[CachedBLEDevice defaultInstance] unregisterAttributeChangedListener:self];
    [stateChangeDelegateList removeAllObjects];
    stateChangeDelegateList = nil;
}

/************************************************************************************/
/*  */
/************************************************************************************/
-(void)registerStateChangeDelegate:(id<StateChangeDelegate>)delegate
{
    if (delegate == nil)
    {
        return;
    }
    if ([stateChangeDelegateList containsObject:delegate] == NO)
    {
        [stateChangeDelegateList addObject:delegate];
    }
}

/************************************************************************************/
/*  */
/************************************************************************************/
-(void)unRegisterStateChangeDelegate:(id<StateChangeDelegate>)delegate
{
    if (delegate == nil)
    {
        return;
    }
    if ([stateChangeDelegateList containsObject:delegate] == YES)
    {
        [stateChangeDelegateList removeObject:delegate];
    }
}

/************************************************************************************/
/*  */
/************************************************************************************/
-(void)startScan:(BOOL)timerOrNot
{
    if (centralManagerState == CBCentralManagerStatePoweredOff)
    {
        [self notifyScanStateChange:SCANNING_STATE_OFF];
        return;
    }
    [mManager startScanning];
    if(timerOrNot == YES)
    {
        self.mScanTimerStarted = YES;
        [self performSelector:@selector(timeoutToStopScan) withObject:nil afterDelay:SCAN_DEVICE_TIMEOUT];
    }
    [self notifyScanStateChange:SCANNING_STATE_ON];
}

/************************************************************************************/
/*  */
/************************************************************************************/
-(void)stopScan
{
    [mManager stopScanning];
    if(self.mScanTimerStarted == YES)
    {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(timeoutToStopScan) object:nil];
        self.mScanTimerStarted = NO;
    }
    [self notifyScanStateChange:SCANNING_STATE_OFF];
}

/************************************************************************************/
/*  */
/************************************************************************************/
-(void)timeoutToStopScan
{
    self.mScanTimerStarted = NO;
    [self stopScan];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(timeoutToStopScan) object:nil];
}

/************************************************************************************/
/*  */
/************************************************************************************/
-(BOOL)connectDevice:(CBPeripheral*)peripheral
{
    if (centralManagerState == CBCentralManagerStatePoweredOff)
    {
        NSLog(@"[BackgroundManager] [connectDevice] current adapter state is off, no need to do connect action");
        [self notifyConnectionStateChange:peripheral connectionState:CONNECTION_STATE_DISCONNECTED];
        return NO;
    }
    tempPeripheral = peripheral;
    self.mConnectTimerStarted = YES;
    self.mConnectTimeout = NO;
    [mManager connectPeripheral:peripheral];
    [self performSelector:@selector(timeoutToStopConnectAction) withObject:nil afterDelay:CONNECT_DEVICE_TIMEOUT];
    return YES;
}

/************************************************************************************/
/*  */
/************************************************************************************/
-(BOOL)disconnectDevice:(CBPeripheral*)peripheral
{
    if (centralManagerState == CBCentralManagerStatePoweredOff)
    {
        NSLog(@"[BackgroundManager] [disconnectDevice] current state is off, no need do disconnect action");
        [self notifyConnectionStateChange:peripheral connectionState:CONNECTION_STATE_DISCONNECTED];
//        return NO;
    }
    [mManager disconnectPeripheral:peripheral];
    tempPeripheral = nil;
    if(self.mConnectTimerStarted == YES)
    {
        [self stopConnectTimer];
        self.mConnectTimerStarted = NO;
    }
    return YES;
}

/************************************************************************************/
/*  */
/************************************************************************************/
-(void)timeoutToStopConnectAction
{
    self.mConnectTimeout = YES;
    self.mConnectTimerStarted = NO;
    [self disconnectDevice:tempPeripheral];
    [self stopConnectTimer];
    if (tempPeripheral != nil)
    {
        tempPeripheral = nil;
    }
    [self notifyConnectionStateChange:tempPeripheral connectionState:CONNECTION_STATE_DISCONNECTED];
}


/************************************************************************************/
/*  */
/************************************************************************************/
-(void)stopConnectTimer
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(timeoutToStopConnectAction) object:nil];
}

/************************************************************************************/
/*  */
/************************************************************************************/
- (void) discoveryDidRefresh: (CBPeripheral *)peripheral
{
    CachedBLEDevice* device = [CachedBLEDevice defaultInstance];
    if ([device.mDeviceIdentifier length] == 0)
    {
        NSLog(@"[BackgroundManager] [discoveryDidRefresh] deivce is nil");
        return;
    }
    NSLog(@"[BackgroundManager] [discoveryDidRefresh] founded identifier : %@", [[peripheral identifier] UUIDString]);
    NSLog(@"[BackgroundManager] [discoveryDidRefresh] device identifier : %@", device.mDeviceIdentifier);
    NSLog(@"[BackgroundManager] [discoveryDidRefresh] device connection state : %i", device.mConnectionState);
    if ([[[peripheral identifier]UUIDString] isEqualToString:device.mDeviceIdentifier])
    {
        if (device.mConnectionState == CONNECTION_STATE_DISCONNECTED)
        {
            [device setDevicePeripheral:peripheral];
            device.mDeviceIdentifier = [[peripheral identifier] UUIDString];
            [device persistData:2];
        }
    }
}

- (void) discoveryStatePoweredOff
{
    CachedBLEDevice* device = [CachedBLEDevice defaultInstance];
    if ([device.mDeviceIdentifier length] == 0)
    {
        return;
    }
    device.mDevicePeripheral = nil;
}

- (void) scanStateChange:(int)state
{
    [self notifyScanStateChange:state];
}

-(void)onBluetoothStateChange:(int)state
{
    NSLog(@"[BackgroundManager] [onBluetoothStateChange] state : %d", state);
    if (state != centralManagerState)
    {
        centralManagerState = state;
        for(id<StateChangeDelegate> delegate in stateChangeDelegateList)
        {
            [delegate onAdapterStateChange:state];
        }
        if (centralManagerState == CBCentralManagerStatePoweredOff)
        {
            NSLog(@"[BackgroundManager] [onBluetoothStateChange] BT is OFF, notify scan state to be OFF ");
            [self notifyScanStateChange:SCANNING_STATE_OFF];
            if (tempPeripheral != nil)
            {
                [self notifyConnectionStateChange:tempPeripheral connectionState:CONNECTION_STATE_DISCONNECTED];
            }
            else
            {
                [[CachedBLEDevice defaultInstance]updateDeviceConnectionState:nil connectionState:CONNECTION_STATE_DISCONNECTED];
            }
            if (self.mConnectTimerStarted == YES)
            {
                [self stopConnectTimer];
            }
            if (self.mScanTimerStarted == YES)
            {
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(timeoutToStopScan) object:nil];
            }
        }
    }
}

- (void) connectDidRefresh:(int)connectionState deviceName:(CBPeripheral*)peripheral
{
    if (connectionState == CONNECTION_STATE_CONNECTED)
    {
        /* do init cachedBLEDevice action */

        [self stopConnectTimer];
        
        [self notifyConnectionStateChange:peripheral connectionState:CONNECTION_STATE_CONNECTED];
    }
}

- (void) disconnectDidRefresh: (int)connectionState devicename: (CBPeripheral *)peripheral
{
    [self notifyConnectionStateChange:peripheral connectionState:CONNECTION_STATE_DISCONNECTED];
}

- (void) retrieveDidRefresh: (NSArray *)peripherals
{
    
}

-(void)onDeviceAttributeChanged:(int)which
{
    if (which == DEVICE_CONNECTION_STATE_CHANGE)
    {
        if ([CachedBLEDevice defaultInstance].mConnectionState == CONNECTION_STATE_CONNECTED)
        {
            NSLog(@"[BackgroundManager] [onDeviceAttributeChanged] device be CONNECTED, update disconnectFromUX to be NO");
            [self setDisconnectFromUx:NO];
        }
    }
    [self alertOut:which];
}

-(void)notifyScanStateChange:(int)state
{
    if (state != SCANNING_STATE_OFF && state != SCANNING_STATE_ON)
    {
        NSLog(@"[BackgroundManager] [notifyScanStateChange] unkonw state");
        return;
    }
    if (scanningState != state)
    {
        scanningState = state;
        NSLog(@"[BackgroundManager] [notifyScanStateChange] scanningstate : %d", scanningState);
        for (id<StateChangeDelegate> delegate in stateChangeDelegateList)
        {
            [delegate onScanningStateChange:scanningState];
        }
    }
}

-(void)notifyConnectionStateChange:(CBPeripheral*)perpheral connectionState:(int)state
{
    [[CachedBLEDevice defaultInstance]updateDeviceConnectionState:perpheral connectionState:state];
    for (id<StateChangeDelegate> delegate in stateChangeDelegateList)
    {
        [delegate onConnectionStateChange:perpheral connectionState:state];
    }
}

-(int)getScanningState
{
    return scanningState;
}

/************************************************************************************/
/* alert phone out with dialog and ringtone                                         */
/* if the dialog is not clicked, after 30s, show the notification                   */
/************************************************************************************/
-(void)alertOut:(int)which
{
    CachedBLEDevice* device = [CachedBLEDevice defaultInstance];
    if (device == nil)
    {
        return;
    }
    if (which == CONFIG_ALERT_SWITCH_STATE_CHANGE)
    {
        if (device.mAlertEnabled == YES)
        {
            
        }
        else
        {
            NSLog(@"[BackgroundManager][alertOut] alert enabled to be NO, call alert off");
            [self alertOff];
        }
    }
    if (which == CONFIG_DISCONNECT_ALERT_SWITCH_STATE_CHANGE)
    {
        if (device.mDisconnectEnabled == NO)
        {
            if (mAlertType == ALERT_TYPE_DISCONNECTED)
            {
                NSLog(@"[BackgroundManager] [alertOut] device disconnected enabled to NO, stop the alert action");
                [self alertOff];
            }
        }
    }
    if (which == CONFIG_RANGE_ALERT_SWITCH_STATE_CHANGE)
    {
        if (device.mRangeAlertEnabled == NO)
        {
            if (mAlertType == ALERT_TYPE_IN_RANGE || mAlertType == ALERT_TYPE_OUT_OF_RANGE)
                NSLog(@"[BackgroundManager] [alertOut] device range alert & range alert be NO, stop the alert action");
                [self alertOff];
        }
    }
    if (which == CONFIG_RANGE_SIZE_CHOOSER_STATE_CHANGE)
    {
        
    }
    if (which == CONFIG_RANGE_WHEN_CHOOSER_STATE_CHANGE)
    {
        
    }
    if (which == DEVICE_CONNECTION_STATE_CHANGE)
    {
        if (device.mConnectionState == CONNECTION_STATE_DISCONNECTED && device.mDisconnectEnabled == YES)
        {
            NSLog(@"[BackgroundManager] [alertOut] disconnect From UX : %d, mConnectTimeout : %d", [self getDisconnectFromUx], self.mConnectTimeout);
            if ([self getDisconnectFromUx] == NO && self.mConnectTimeout == NO)
            {
                NSLog(@"[BackgroundManager] [alertOut] connection is disconnected cause of range, and alert out");
                mAlertType = ALERT_TYPE_DISCONNECTED;
                [self alertOn];
            }
        }
        if (device.mConnectionState == CONNECTION_STATE_CONNECTED)
        {
            NSLog(@"[BackgroundManager] [alertOut] connection is connected, stop alert action");
            mAlertType = ALERT_TYPE_NONE;
            [self alertOff];
        }
    }
    if (which == DEVICE_ALERT_STATE_CHANGE)
    {
        if (device.mAlertState == ALERT_STATE_ON && device.mRangeAlertEnabled == YES)
        {
            NSLog(@"[BackgroundManager] [alertOut] alert state change, alert state on");
            if (device.mRangeStatus == RANGE_STATUS_OUT_OF_RANGE)
            {
                mAlertType = ALERT_TYPE_OUT_OF_RANGE;
            }
            else if (device.mRangeStatus == RANGE_STATUS_IN_RANGE)
            {
                mAlertType = ALERT_TYPE_IN_RANGE;
            }
            else
            {
                mAlertType = ALERT_TYPE_NONE;
            }
            NSLog(@"[BackgroundManager] [alertOut] alert status change alert type : %d", mAlertType);
            if (mAlertType != ALERT_TYPE_NONE)
            {
                [self alertOn];
            }
            if (mAlertType == ALERT_TYPE_NONE)
            {
                NSLog(@"[BackgroundManager] [alertOut] alert status change & alert type is NONE, stop alert");
                [self alertOff];
            }
        }
        if (device.mAlertState == ALERT_STATE_OFF)
        {
            NSLog(@"[BackgroundManager] [alertOut] alert status change to OFF, stop alert");
            [self alertOff];
        }
    }
    
}

-(void)alertOn
{
    NSLog(@"[BackgroundManager] [alertOn] device alert state change to ON, do alert action");
    CachedBLEDevice* device = [CachedBLEDevice defaultInstance];
    if (device == nil)
    {
        return;
    }
    if (mDialogShowedUp == NO)
    {
        NSLog(@"[BackgroundManager] [alertOn] need to show up dialog");
        if (mAppCurrentState == APP_CURRENT_FOREGROUND)
        {
            [self showDialog:device.mDeviceName];
        }
    }
    else
    {
        NSLog(@"[BackgroundManager] [alertOn] need update the dialog and notification");
        if (mAppCurrentState == APP_CURRENT_FOREGROUND)
        {
            
            if (alertDialog != nil)
            {
                NSLog(@"[BackgroundManager] [alertOn] call to update dialog message");
                NSString* str = [self buildAlertDialogMessage:YES deviceName:device.mDeviceName];
                [alertDialog setMessage:str];
            }
        }
    }
    if (mNotificationShowedUp == NO)
    {
        if(mAppCurrentState == APP_CURRENT_BACKGROUND)
        {
            NSLog(@"[BackgroundManager] [alertOn] show notification");
            [self showNotification:device.mDeviceName];
        }
    }
    else
    {
        if (mAppCurrentState == APP_CURRENT_BACKGROUND)
        {
            if (alertNotification != nil)
            {
                NSLog(@"[BackgroundManager] [alertOn] call to update notification alert body");
                [self showNotification:device.mDeviceName];
            }
        }
    }
    if (mRingtoneAlerting == NO)
    {
        NSLog(@"[BackgroundManager] [alertOn] need to ring out");
        [self startPhoneAlert:device.mRingtoneEnabled vibrationEnabledOrNot:device.mVibrationEnabled];
    }
}

-(void)alertOff
{
    NSLog(@"[BackgroundManager] [alertOff] device alert state change to NO, stop alert action");
    if (mDialogShowedUp == YES)
    {
        NSLog(@"[BackgroundManager] [alertOff] device alert state change to NO, dismiss dialog");
        [self dismissDialog];
//        if(mAppCurrentState == APP_CURRENT_BACKGROUND)
//        {
//            if(mNotificationShowedUp == YES)
//            {
//                [self removeNotification];
//            }
//        }
    }
    if (mRingtoneAlerting == YES)
    {
        NSLog(@"[BackgroundManager] [alertOff] device alert state change to NO, stop ringing");
        [self stopPhoneAlert];
    }
//    if (mNotificationShowedUp == YES)
//    {
//        NSLog(@"[BackgroundManager] [alertOff] device alert state change to NO, remove notification");
////        [self removeNotification];
//    }
}

-(void)startPhoneAlert:(BOOL)ringtoneEnabled vibrationEnabledOrNot:(BOOL)vibration
{
    mRingtoneAlerting = YES;
    [alert startAlert:ringtoneEnabled vibrationOnOrNot:vibration];
}

-(void)stopPhoneAlert
{
    mRingtoneAlerting = NO;
    [alert stopAlert];
}

-(void)showNotification:(NSString*)deviceName;
{
    UIApplication* app = [UIApplication sharedApplication];
//    NSArray* array = [app scheduledLocalNotifications];
//    NSLog(@"[BackgroundManager][showNotification] ayyay : %@, count : %lu", array, (unsigned long)array.count);
//    if (array != nil && array.count > 0)
//    {
        NSLog(@"[BackgroundManager] [showNotification] remove all notifications");
        [app cancelAllLocalNotifications];
//    }

//    [app registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert];
    alertNotification = nil;
    alertNotification = [[UILocalNotification alloc] init];
    if (alertNotification != nil)
    {
        alertNotification.alertBody = [self buildAlertDialogMessage:NO deviceName:deviceName];
        alertNotification.repeatInterval = 0;
        [app scheduleLocalNotification:alertNotification];
        mNotificationShowedUp = YES;
    }
}

-(void)removeNotification
{
    NSLog(@"[BackgroundManager] [removeNotification] enter");
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    mNotificationShowedUp = NO;
    alertNotification = nil;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    NSLog(@"[BackgroundManager] [didReceLocalNotification] enter");
    NSString* str = [self buildAlertDialogMessage:YES deviceName:[CachedBLEDevice defaultInstance].mDeviceName];
    UIAlertView* view = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"MediaTek SmartDevice Alert", @"MediaTek SmartDevice Alert") message:str delegate:self cancelButtonTitle: NSLocalizedString(@"Cancel", @"Cancel") otherButtonTitles:notification.alertAction, nil];
    [view show];
}

-(void)startNotificationTimer
{
    
}

-(void)stopNotificationTimer
{
    
}

-(void)showDialog:(NSString*)deviceName
{
    NSLog(@"[BackgroundManager] [showDialog] mAlertTYpe : %d", mAlertType);
    
    NSString* str = [self buildAlertDialogMessage:YES deviceName:deviceName];
    
    NSLog(@"[BackgroundManager] [showDialog] showString : %@", str);
    
    mDialogShowedUp = YES;
    
    alertDialog = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"MediaTek SmartDevice Alert", @"MediaTek SmartDevice Alert") message:str delegate:self cancelButtonTitle:NSLocalizedString(@"Dismiss", @"Dismiss") otherButtonTitles:nil];
    [alertDialog show];
}

-(void)updateAlertDialog:(NSString*)deviceName
{
    if (alertDialog != nil)
    {
        if (mDialogShowedUp == YES)
        {
            [alertDialog setMessage: [self buildAlertDialogMessage:YES deviceName:deviceName]];
            [alertDialog show];
        }
    }
}

/************************************************************************************/
/*  */
/************************************************************************************/
-(void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"[BackgroundManager] [clickedButtonAtIndex] buttonIndex : %lu", (unsigned long) buttonIndex);
    if (buttonIndex == 0)
    {
        // TODO should stop remote alert action
    }
    if (buttonIndex == 1)
    {
        
    }
    mDialogShowedUp = NO;
    [alertView dismissWithClickedButtonIndex:buttonIndex animated:NO];
}

/************************************************************************************/
/*  */
/************************************************************************************/
-(void)dismissDialog
{
    if (alertDialog != nil)
    {
        mDialogShowedUp = NO;
        [alertDialog dismissWithClickedButtonIndex:0 animated:NO];
    }
}

/************************************************************************************/
/*  */
/************************************************************************************/
-(NSString*)buildAlertDialogMessage:(BOOL)needNewLine deviceName:(NSString*)name
{
    NSString* str = nil;
    if (mAlertType == ALERT_TYPE_DISCONNECTED)
    {
        str = NSLocalizedString(@"Disconnected", @"Disconnected");
    }
    if (mAlertType == ALERT_TYPE_IN_RANGE)
    {
        str = NSLocalizedString(@"In range", @"In range");
    }
    if (mAlertType == ALERT_TYPE_OUT_OF_RANGE)
    {
        str = NSLocalizedString(@"Out of range", @"Out of range");
    }
    if (str == nil)
    {
        NSLog(@"[BackgroundManager] [showDialog] unrecognized mAlertType");
        return nil;
    }
    NSString* showString = [[self buildDeviceName:needNewLine deviceName:name] stringByAppendingString:str];
    return showString;
}

/************************************************************************************/
/*  */
/************************************************************************************/
-(NSString*)buildDeviceName:(BOOL)needNewLine deviceName:(NSString*)str
{
    if (needNewLine == YES)
    {
        return [NSString stringWithFormat:@"[%@]\r\n", str];
    }
    else
    {
        return [NSString stringWithFormat:@"[%@] ", str];
    }
}

/************************************************************************************/
/*  */
/************************************************************************************/
-(void)setDisconnectFromUx:(BOOL)disconnectFromUx
{
    NSLog(@"[BackgroundManager] [setDisconnectFromUx] disconnectFromUx : %d", disconnectFromUx);
    [[NSUserDefaults standardUserDefaults] setBool:disconnectFromUx forKey:DISCONNECT_FROM_UX];
}

/************************************************************************************/
/*  */
/************************************************************************************/
-(BOOL)getDisconnectFromUx
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:DISCONNECT_FROM_UX];
}

/************************************************************************************/
/*  */
/************************************************************************************/
-(void)setAppBackgroundOrForeground:(BOOL)background
{
    if(background == YES)
    {
        mAppCurrentState = APP_CURRENT_BACKGROUND;
    }
    else
    {
        mAppCurrentState = APP_CURRENT_FOREGROUND;
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
    }
}

@end
