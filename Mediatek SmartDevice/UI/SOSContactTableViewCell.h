//
//  SOSContactTableViewCell.h
//  Mediatek SmartDevice
//
//  Created by user on 15-2-3.
//  Copyright (c) 2015年 Mediatek. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SOSContactTableViewCell : UITableViewCell

- (void)setSerial: (int)serial;
- (void)setName: (NSString *)contactName;
- (void)setDeleteBtnVisibility: (BOOL)visible;

@end
