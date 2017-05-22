//
//  PhoneRinger.m
//  BLEManager
//
//  Created by user on 14-7-31.
//  Copyright (c) 2014年 com.mediatek. All rights reserved.
//

#import "PhoneRinger.h"

@implementation PhoneRinger

static PhoneRinger* instance;
//static SystemSoundID soundId;
static NSURL* filePath;

+(PhoneRinger*)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLog(@"[PhoneRinger] [sharedInstance] begin to init");
        instance = [[PhoneRinger alloc] init];
    });
    return instance;
}

-(void)startAlert:(int)ringtoneOnOrNot vibrationOnOrNot:(int)on
{
    if (ringtoneOnOrNot == YES && on == YES)
    {
        AudioServicesPlayAlertSound(1006);
    }
    else if (ringtoneOnOrNot == YES && on == NO)
    {
        AudioServicesPlaySystemSound(1006);
    }
    else if (ringtoneOnOrNot == NO && on == YES)
    {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
    else if (ringtoneOnOrNot == NO && on == NO)
    {
        [self stopAlert];
    }
}

-(void)stopAlert
{
    AudioServicesDisposeSystemSoundID(1006);
}

@end
