//
//  ContactEditTableViewController.h
//  Mediatek SmartDevice
//
//  Created by user on 15-1-15.
//  Copyright (c) 2015年 Mediatek. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PassValueDelegate <NSObject>

- (void) passValue: (NSString *)name phoneNumber: (NSString *)num;

@end

@interface ContactEditTableViewController : UITableViewController <UITextFieldDelegate>

@property (nonatomic, assign) id<PassValueDelegate> passValueDelegate;

@end
