//
//  SOSContactTableViewCell.m
//  Mediatek SmartDevice
//
//  Created by user on 15-2-3.
//  Copyright (c) 2015年 Mediatek. All rights reserved.
//

#import "SOSContactTableViewCell.h"
#import "SOSCallOperator.h"
#import "SOSCallDataManager.h"

@interface SOSContactTableViewCell() {
    
    __weak IBOutlet UITextField *nameLabel;
    __weak IBOutlet UITextField *serialLabel;
    
    __weak IBOutlet UIButton *deleteButton;
    @private
    int mIndex;
    
    SOSCallOperator *operatorInstance;
    SOSCallDataManager *dataMgr;
}
@end

@implementation SOSContactTableViewCell

- (void)awakeFromNib {
    // Initialization code
    operatorInstance = [SOSCallOperator getSosCallOperaterInstance];
    dataMgr = [SOSCallDataManager sosCallDataMgrInstance];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setSerial: (int)serial {
    mIndex = serial;
    serialLabel.text = [NSString stringWithFormat:@"%d", serial];
}
- (void)setName: (NSString *)contactName {
    nameLabel.text = contactName;
}
- (void)setDeleteBtnVisibility: (BOOL)visible {
    deleteButton.hidden = !visible;
}

- (IBAction)ClearButtonAction:(id)sender {
    NSLog(@"[SOSContactTableViewCell]clear clicked, index = %d", mIndex);
    if ([dataMgr getKeyCount] > 1) {
        [dataMgr deleteContact: mIndex index: 1];
    } else {
        [dataMgr deleteContact: 1 index: mIndex];
    }
    
    [self setName: nil];
    [self setDeleteBtnVisibility: NO];
}

@end
