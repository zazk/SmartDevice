//
//  MTKDevicePrarmeterRecorder.h
//  BleProfile
//
//  Created by ken on 14-7-9.
//  Copyright (c) 2014年 MTK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DeviceParameter.h"
#import "DeviceInfo.h"

/*
typedef struct {
    int alertEnabler;
    int rangeAlertEnabler;
    int rangeType;
    int rangeValue;
    int disconnectEnabler;
    int ringtoneEnabler;
    int vibrationEnabler;
}DEVICEPXPPARAMS;
*/

//const int INSERT_DATA = 1;
//const int UPDATE_DATA = 2;

//NSString* DATA_BASE_NAME = @"DeviceInfo";
 
@interface MTKDeviceParameterRecorder : NSObject

//@property (strong, nonatomic) NSManagedObjectContext* mManagedObjectContext;

/* Public Interface */
+(void) deleteDevice:(NSString*) deviceIdentifier;

+(BOOL) setParameters:(int)which
           deviceName:(NSString*)name
         deviceIdentifier:(NSString*)identifier
             alertEnabler:(BOOL)alertEnabler
        rangeAlertEnabler:(BOOL)rangeEnabler
                rangeType:(int)rangeType
               rangeValue:(int)rangeValue
   disconnectAlertEnabler:(BOOL)disconnectEnabler
          ringtoneEnabler:(BOOL)ringtoneEnabler
         vibrationEnabler:(BOOL)vibrationEnabler;

+(DeviceParameter *) getParameters: (NSString *)deviceIdentifier;

+(NSMutableArray*) getDeviceParameters;

+ (NSString *) getSavedDeviceIdentifier;

@end
