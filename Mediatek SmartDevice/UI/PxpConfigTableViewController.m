//
//  PxpConfigTableViewController.m
//  BLEManager
//
//  Created by ken on 14-7-11.
//  Copyright (c) 2014年 com.mediatek. All rights reserved.
//

#import "PxpConfigTableViewController.h"
#import "CachedBLEDevice.h"
#import "ProgressAlertView.h"
#import "MTKBleManager.h"
#import "MTKBleProximityService.h"


@interface PxpConfigTableViewController () <CalibrateProtocol>

- (IBAction)switchValueChanged:(UISwitch *)sender;

@property (weak, nonatomic) IBOutlet UISwitch *mAlertSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *mRangeAlertSwitch;
@property (weak, nonatomic) IBOutlet UILabel *mWhenLabel;
@property (weak, nonatomic) IBOutlet UILabel *mRangeSizeLabel;
@property (weak, nonatomic) IBOutlet UISwitch *mDisconnectAlertSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *mRingtoneSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *mVibrationSwitch;
- (IBAction)backButtonAction:(UIBarButtonItem *)sender;

@property (weak, nonatomic) CachedBLEDevice *mDevice;

@end

@implementation PxpConfigTableViewController

@synthesize mAlertSwitch;
@synthesize mRangeAlertSwitch;
@synthesize mWhenLabel;
@synthesize mRangeSizeLabel;
@synthesize mDisconnectAlertSwitch;
@synthesize mRingtoneSwitch;
@synthesize mVibrationSwitch;

@synthesize mDevice;

NSString* const ALERT_SWITCH_ID = @"AlertSwitch";
NSString* const RANGE_ALERT_SWITCH_ID = @"RangeAlertSwitch";
NSString* const DISCONNECT_ALERT_SWITCH_ID = @"DisconnectAlertSwitch";
NSString* const RINGTONE_SWITCH_ID = @"RingtoneSwitch";
NSString* const VIBRATION_SWITCH_ID = @"VibrationSwitch";

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    
    mDevice = [CachedBLEDevice defaultInstance];
    
    [self initUxState];
}

-(void)viewDidDisappear:(BOOL)animated {
    [[MTKBleManager sharedInstance] unRegisterCalibrateDelegate:self];
}

-(void) initUxState {
    [mAlertSwitch setOn:mDevice.mAlertEnabled];
    [mRangeAlertSwitch setOn:mDevice.mRangeAlertEnabled];
    [mDisconnectAlertSwitch setOn:mDevice.mDisconnectEnabled];
    [mRingtoneSwitch setOn:mDevice.mRingtoneEnabled];
    [mVibrationSwitch setOn:mDevice.mVibrationEnabled];
    
    [mWhenLabel setText:[self convertRangeTypeToString:mDevice.mRangeType]];
    [mRangeSizeLabel setText:[self convertRangeValueToString:mDevice.mRangeValue]];
    
}

-(NSString*)convertRangeTypeToString:(int)type {
    if (type == RANGE_ALERT_IN) {
        return NSLocalizedString(@"In range", @"In range");
    }
    if (type == RANGE_ALERT_OUT) {
        return NSLocalizedString(@"Out of range", @"Out of range");
    }
    return nil;
}

-(NSString*)convertRangeValueToString:(int)type {
    if (type == RANGE_ALERT_FAR) {
        return NSLocalizedString(@"Far", @"Far");
    }
    if (type == RANGE_ALERT_MIDDLE) {
        return NSLocalizedString(@"Middle", @"Middle");
    }
    if (type == RANGE_ALERT_NEAR) {
        return NSLocalizedString(@"Near", @"Near");
    }
    return nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (mDevice.mAlertEnabled == false) {
        return 1;
    }
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        return 1;
    }
    if (section == 1) {
        if (mDevice.mRangeAlertEnabled == true)
        {
            return 4;
        }
        else
        {
            return 1;
        }
    }
    if (section == 2) {
        return 1;
    }
    if (section == 3) {
        return 2;
    }
    return 0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];

    if ([indexPath section] == 1) {
        if ([indexPath row] == 3) {
            MTKBleManager *manager = [MTKBleManager sharedInstance];
            int connectState = [manager getCurrentConnectState];
            if (connectState == CONNECTION_STATE_CONNECTED) {
                ProgressAlertView *view = [ProgressAlertView sharedInstance];
                [view showProgressView];

                [[MTKBleProximityService getInstance] registerCalibrateDelegate: self];
                [[MTKBleProximityService getInstance] calibrateThreshold: mDevice.mRangeValue
                                                                   delay: 5];
                
                
            } else {
                NSString *title = NSLocalizedString(@"Calibrating range", @"Calibrating range");
                NSString *message = NSLocalizedString(@"Calibrating while disconnected", @"Calibrating while disconnected");
                NSString *okButton = NSLocalizedString(@"OK", @"OK");
                UIAlertView *view = [[UIAlertView alloc] initWithTitle:title
                                                               message:message
                                                              delegate:nil
                                                     cancelButtonTitle:nil
                                                     otherButtonTitles:okButton, nil];
                [view show];
            }
            
        }
    }
    
}

//-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    if (section == 1)
//    {
//        return 30;
//    }
//    if (section == 0)
//    {
//        return 30;
//    }
//    return 20;
//}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier" forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)calibrateFinished:(BOOL)result {
    NSLog(@"[calibrateFinished] calibrate result : %d", result);
    [[ProgressAlertView sharedInstance] dismissProgressView];
}

- (IBAction)switchValueChanged:(UISwitch *)sender {
    if ([sender.restorationIdentifier isEqualToString:ALERT_SWITCH_ID]) {
        [mDevice updateDeviceConfiguration:CONFIG_ALERT_SWITCH_STATE_CHANGE changedValue:sender.isOn];
    } else if ([sender.restorationIdentifier isEqualToString:RANGE_ALERT_SWITCH_ID]) {
        [mDevice updateDeviceConfiguration:CONFIG_RANGE_ALERT_SWITCH_STATE_CHANGE changedValue:sender.isOn];
    } else if ([sender.restorationIdentifier isEqualToString:DISCONNECT_ALERT_SWITCH_ID]) {
        [mDevice updateDeviceConfiguration:CONFIG_DISCONNECT_ALERT_SWITCH_STATE_CHANGE changedValue:sender.isOn];
    } else if ([sender.restorationIdentifier isEqualToString:RINGTONE_SWITCH_ID]) {
        [mDevice updateDeviceConfiguration:CONFIG_RINGTONE_SWITCH_STATE_CHANGE changedValue:sender.isOn];
    } else if ([sender.restorationIdentifier isEqualToString:VIBRATION_SWITCH_ID]) {
        [mDevice updateDeviceConfiguration:CONFIG_VIBRATION_SWITCH_STAE_CHANGE changedValue:sender.isOn];
    } else {
        NSLog(@"PxpConfigTableViewController unknown id");
    }
    [self.tableView reloadData];
}

- (IBAction)backButtonAction:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
