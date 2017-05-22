//
//  ProgressAlertView.m
//  Mediatek SmartDevice
//
//  Created by user on 15/2/9.
//  Copyright (c) 2015年 Mediatek. All rights reserved.
//

#import "ProgressAlertView.h"

@interface ProgressAlertView()
{
@private
    UIAlertView *mAlertView;

}

@end

@implementation ProgressAlertView

static ProgressAlertView *sInstance;

+(id)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sInstance = [[ProgressAlertView alloc] init];
    });
    return sInstance;
}

-(void) showProgressView {
    if (mAlertView == nil) {
        NSString* string = NSLocalizedString(@"Calibrating range", @"Calibrating range");
        
        
        mAlertView = [[UIAlertView alloc] initWithTitle:string
                                                message:nil
                                               delegate:nil
                                      cancelButtonTitle:nil
                                      otherButtonTitles:nil, nil];
        
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [indicator startAnimating];
        
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
            [mAlertView setValue:indicator forKey:@"accessoryView"];
        } else {
            [mAlertView addSubview:indicator];
        }
    }
    [mAlertView show];
}

-(void) dismissProgressView {
    if (mAlertView != nil) {
        [mAlertView dismissWithClickedButtonIndex:0 animated:YES];
        mAlertView = nil;
    }
}

@end
