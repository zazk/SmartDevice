//
//  CallModeTableViewController.h
//  Mediatek SmartDevice
//
//  Created by user on 15-1-8.
//  Copyright (c) 2015年 Mediatek. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CallModeTableViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UITableViewCell *cellAutoLoop;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellManual;
- (IBAction)backBarButton:(id)sender;

@end
