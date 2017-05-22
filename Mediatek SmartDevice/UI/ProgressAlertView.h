//
//  ProgressAlertView.h
//  Mediatek SmartDevice
//
//  Created by user on 15/2/9.
//  Copyright (c) 2015年 Mediatek. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ProgressAlertView : NSObject

+(id)sharedInstance;

-(void) showProgressView;

-(void) dismissProgressView;

@end
