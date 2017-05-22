//
//  PhoneRinger.h
//  BLEManager
//
//  Created by user on 14-7-31.
//  Copyright (c) 2014年 com.mediatek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface PhoneRinger : NSObject

+(PhoneRinger*)sharedInstance;
-(void)startAlert:(int)ringtoneOnOrNot vibrationOnOrNot:(int)on;
-(void)stopAlert;

@end
