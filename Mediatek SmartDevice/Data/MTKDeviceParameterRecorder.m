//
//  MTKDevicePrarmeterRecorder.m
//  BleProfile
//
//  Created by ken on 14-7-9.
//  Copyright (c) 2014年 MTK. All rights reserved.
//

#import "MTKDeviceParameterRecorder.h"
#import "BLEManagerConstants.h"
#import "MTKAppDelegate.h"

@implementation MTKDeviceParameterRecorder

//@synthesize mManagedObjectContext;

/* Public Interface */
+(void) deleteDevice:(NSString*) deviceIdentifier
{
    if(deviceIdentifier == nil || deviceIdentifier.length == 0)
    {
        NSLog(@"[MTKDeviceParameterRecorder] [deleteDevice] deviceIdentifier is WRONG");
        return;
    }
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    MtkAppDelegate* delegate = [[UIApplication sharedApplication] delegate];
    NSEntityDescription* user = [NSEntityDescription entityForName:@"DeviceInfo" inManagedObjectContext:delegate.managedObjectContext];
    [request setEntity:user];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"device_identifier=%@", deviceIdentifier];
    [request setPredicate:predicate];
    NSError* error;
    NSMutableArray* mutableResult = [[delegate.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (mutableResult == nil)
    {
        NSLog(@"[MTKDevicePrarmeterRecorder] [deleteDevice] mutableResult is nill & error : %@", error);
        return;
    }
    for(DeviceInfo* info in mutableResult)
    {
        [delegate.managedObjectContext deleteObject:info];
    }
    if (![delegate.managedObjectContext save:&error])
    {
        NSLog(@"[MTKDeviceParameterRecorder] [deleteDevice] ERROR : %@, %@", error, [error userInfo]);
        return;
    }
    NSLog(@"[MTKDeviceParameterRecorder] [deleteDevice] delete succeed");
}

/**************************************************************************************/
/* which is 1, insert; is 2, update */
/**************************************************************************************/
+(BOOL) setParameters:(int) which
           deviceName:(NSString*)name
     deviceIdentifier:(NSString*)identifier
         alertEnabler:(BOOL)alertEnabler
    rangeAlertEnabler:(BOOL)rangeEnabler
            rangeType:(int)rangeType
           rangeValue:(int)rangeValue
disconnectAlertEnabler:(BOOL)disconnectEnabler
      ringtoneEnabler:(BOOL)ringtoneEnabler
     vibrationEnabler:(BOOL)vibrationEnabler
{
    if (identifier == nil || [identifier length] == 0)
    {
        NSLog(@"[MTKDeviceParameterRecorder] [setParameters] identifier is WRONG");
        return false;
    }
    /*
    if (which != INSERT_DATA && which != UPDATE_DATA)
    {
        NSLog(@"[MTKDevicePrarmeterRecorder] [setParameters] which iw WRONG, only should be INSERTDATA && UPDATE_DATA");
        return false;
    }*/
    MtkAppDelegate* delegate = (MtkAppDelegate*)[[UIApplication sharedApplication] delegate];
    BOOL isSuccess = false;
    if (which == 1)
    {
    
        DeviceInfo* info = (DeviceInfo*) [NSEntityDescription insertNewObjectForEntityForName:@"DeviceInfo" inManagedObjectContext:delegate.managedObjectContext];
        NSError* err;
        [info setDevice_identifier:identifier];
        [info setDevice_name:name];
        [info setAlert_enabler:[NSNumber numberWithBool:alertEnabler]];
        [info setRange_alert_enabler:[NSNumber numberWithBool:rangeEnabler]];
        [info setDisconnect_alert_enabler:[NSNumber numberWithBool:disconnectEnabler]];
        [info setRingtone_enabler:[NSNumber numberWithBool:ringtoneEnabler]];
        [info setVibration_enabler:[NSNumber numberWithBool:vibrationEnabler]];
        [info setRange_type:[NSNumber numberWithInt:rangeType]];
        [info setRange_value:[NSNumber numberWithInt:rangeValue]];
        isSuccess = [delegate.managedObjectContext save:&err];
        if (!isSuccess)
        {
            NSLog(@"[MTKDeviceParameterRecorder] [setParameters] insert ERROR %@ ", err);
        }
    }
    else if (which == 2)
    {
        NSFetchRequest* request = [[NSFetchRequest alloc] init];
        NSEntityDescription* user = [NSEntityDescription entityForName:@"DeviceInfo" inManagedObjectContext:delegate.managedObjectContext];
        [request setEntity:user];
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"device_identifier=%@", identifier];
        [request setPredicate:predicate];
        NSError* erro = nil;
        NSMutableArray* mutableFetchResult = [[delegate.managedObjectContext executeFetchRequest:request error:&erro] mutableCopy];
        if (mutableFetchResult == nil)
        {
            NSLog(@"[MTKDeviceParameterRecorder] [setParameters] device is not in DB error : %@", erro);
            return false;
        }
        NSLog(@"[MTKDeviceParameterRecorder] [setParameters] mutable fetch result : %lu", (unsigned long)[mutableFetchResult count]);
        for (DeviceInfo* info in mutableFetchResult)
        {
            [info setDevice_name:name];
            [info setAlert_enabler:[NSNumber numberWithBool:alertEnabler]];
            [info setRange_alert_enabler:[NSNumber numberWithBool:rangeEnabler]];
            [info setDisconnect_alert_enabler:[NSNumber numberWithBool:disconnectEnabler]];
            [info setRingtone_enabler:[NSNumber numberWithBool:ringtoneEnabler]];
            [info setVibration_enabler:[NSNumber numberWithBool:vibrationEnabler]];
            [info setRange_type:[NSNumber numberWithInt:rangeType]];
            [info setRange_value:[NSNumber numberWithInt:rangeValue]];
        }
        BOOL isSuccess = [delegate.managedObjectContext save:&erro];
        
        if (!isSuccess)
        {
            NSLog(@"[MTKDeviceParameterRecorder] [setParameters] ERROR update failed error : %@", erro);
        }
    }
    return isSuccess;
}

+(DeviceParameter *) getParameters: (NSString *)deviceIdentifier
{
    DeviceParameter* parameter = [[DeviceParameter alloc] init];
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    MtkAppDelegate* delegate = (MtkAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSEntityDescription* user = [NSEntityDescription entityForName:@"DeviceInfo" inManagedObjectContext:delegate.managedObjectContext];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"device_identifier=%@", deviceIdentifier];
    [request setEntity:user];
    [request setPredicate:predicate];
    NSError* error;
    NSMutableArray* array = [[delegate.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (array == nil)
    {
        NSLog(@"[MTKDeviceParameterRecorder] [getParameters] query result is nil, error : %@", error);
        return nil;
    }
    if (array.count != 1)
    {
        NSLog(@"[MTKDeviceParameterRecorder] [getParameters] query count is not equal 1");
        return nil;
    }
    DeviceInfo* info = [array objectAtIndex:0];
    NSLog(@"[MTKDeviceParameterRecorder] [getParameters] %@", info);
    parameter.mAlertEnabler = [info.alert_enabler boolValue];
    parameter.mDeviceName = info.device_name;
    parameter.mRingtoneEnabler = [info.ringtone_enabler boolValue];
    parameter.mRangeAlertEnabler = [info.range_alert_enabler boolValue];
    parameter.mRangeType = [info.range_type intValue];
    parameter.mRangeValue = [info.range_value intValue];
    parameter.mDisconnectAlertEnabler = [info.disconnect_alert_enabler boolValue];
    parameter.mVibrationEnabler = [info.vibration_enabler boolValue];
    return parameter;
}

+(NSMutableArray*) getDeviceParameters
{
    NSFetchRequest* request=[[NSFetchRequest alloc] init];
    MtkAppDelegate* delegate = (MtkAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSEntityDescription* user=[NSEntityDescription entityForName:@"DeviceInfo" inManagedObjectContext:delegate.managedObjectContext];
    [request setEntity:user];
    NSError* error=nil;
    NSMutableArray* mutableFetchResult=[[delegate.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResult==nil) {
        NSLog(@"Error:%@",error);
        return nil;
    }
    NSLog(@"[MTKDeviceParameterRecorder] [getDeviceParameters] The count of entry: %lu", (unsigned long)[mutableFetchResult count]);
    return mutableFetchResult;
}

+ (NSString *) getSavedDeviceIdentifier {
    NSString *result = nil;
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    MtkAppDelegate* delegate = (MtkAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSEntityDescription* user = [NSEntityDescription entityForName:@"DeviceInfo" inManagedObjectContext:delegate.managedObjectContext];
    //NSPredicate* predicate = [NSPredicate predicateWithFormat:@"device_identifier=%@", deviceIdentifier];
    [request setEntity:user];
    //[request setPredicate:predicate];
    NSError* error;
    NSMutableArray* array = [[delegate.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (array == nil)
    {
        NSLog(@"[MTKDeviceParameterRecorder] [getParameters] query result is nil, error : %@", error);
        return nil;
    }
    if (array.count != 1)
    {
        NSLog(@"[MTKDeviceParameterRecorder] [getParameters] query count is not equal 1");
        return nil;
    }
    DeviceInfo* info = [array objectAtIndex:0];
    NSLog(@"[MTKDeviceParameterRecorder] [getParameters] %@", info);
//    parameter.mAlertEnabler = [info.alert_enabler boolValue];
//    parameter.mDeviceName = info.device_name;
//    parameter.mRingtoneEnabler = [info.ringtone_enabler boolValue];
//    parameter.mRangeAlertEnabler = [info.range_alert_enabler boolValue];
//    parameter.mRangeType = [info.range_type intValue];
//    parameter.mRangeValue = [info.range_value intValue];
//    parameter.mDisconnectAlertEnabler = [info.disconnect_alert_enabler boolValue];
//    parameter.mVibrationEnabler = [info.vibration_enabler boolValue];
    
    result = info.device_identifier;
    
    return result;
}

@end
