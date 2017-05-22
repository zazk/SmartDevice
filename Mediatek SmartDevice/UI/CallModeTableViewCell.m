//
//  CallModeTableViewCell.m
//  Mediatek SmartDevice
//
//  Created by user on 15-2-3.
//  Copyright (c) 2015年 Mediatek. All rights reserved.
//

#import "CallModeTableViewCell.h"

@interface CallModeTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *callModeValueLable;

@end

@implementation CallModeTableViewCell

@synthesize callModeValueLable;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setModeValueLable: (NSString *)modeString {
    callModeValueLable.text = modeString;
}

@end
