//
//  HealthDataMgrTableViewController.m
//  Mediatek SmartDevice
//
//  Created by user on 10/27/14.
//  Copyright (c) 2014 Mediatek. All rights reserved.
//

#import "HealthDataMgrTableViewController.h"
#import "HealthKitManager.h"
#import "MTKBleManager.h"
#import "PdmsSleepService.h"

@import HealthKit;

@interface HealthDataMgrTableViewController () <PdmsSleepUpdateDelegate> {
@private
    HealthKitManager *hkManager;
    BOOL isViewShowing;
}
- (IBAction)pedometerSwitcher:(id)sender;
- (IBAction)backAction:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *stepCountLabel;
@property (strong, nonatomic) IBOutlet UILabel *coloriesLabel;
@property (strong, nonatomic) IBOutlet UILabel *distanceLabel;
@property (strong, nonatomic) IBOutlet UILabel *sleepStartTime;
@property (strong, nonatomic) IBOutlet UILabel *sleepEndTime;
@property (weak, nonatomic) IBOutlet UILabel *inBedDate;
@property (weak, nonatomic) IBOutlet UILabel *inBedTime;

@end

@implementation HealthDataMgrTableViewController

//@synthesize pedometerSwitcherValue;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //hkservice = [HealthKitSerivce shareInstance: nil Target: nil];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        hkManager = [HealthKitManager healthkitMgrInstance];
    }
    
    //[hkManager setHealthkitDataChangeDelegate: self];
    
    //[hkservice requestAuthorization];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    //[self updateTodaysActivity];
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(didEnterBackgroundNotification:) name:kEnterBackgroundNotification object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(didEnterForegroundNotification:) name:kEnterForegroundNotification object: nil];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    NSLog(@"[BLE][HealthKitView] viewDidAppear");
    [super viewDidAppear: animated];
    
    [[PdmsSleepService getInstance] registerPSDelegate: self];
    [self updateTodaysActivity];
    isViewShowing = YES;
    [[PdmsSleepService getInstance] sendStartReadRequest: INDICATION_INTERVAL_FORGROUND];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear: animated];
    NSLog(@"[BLE][HealthKitView] viewDidDisappear");
    isViewShowing = NO;
    [[PdmsSleepService getInstance] sendStartReadRequest: INDICATION_INTERVAL_BACKGROUND];
    [[PdmsSleepService getInstance] unRegisterPSDelegate: self];
}

-(void)viewWillAppear:(BOOL)animated {
    NSLog(@"[BLE][HealthKitView]viewWillAppear ++");
    //[self updateTodaysActivity];
    //[pedometerSwitcherValue setOn: [[NSUserDefaults standardUserDefaults] boolForKey: UserDefaultKey_synPdmsFromWatch]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section  == 0) {
        return 3;
    } else if (section == 1 || section == 2) {
        return 1;
    }
    return 0;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
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
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)backAction:(id)sender {
    [self dismissViewControllerAnimated: YES completion: nil];
}

- (void)healthDataChanged: (enum HealthDataType)dataTypeChanged {
    NSLog(@"[BLE][HealthKitView]healthDataChanged: %d", dataTypeChanged);
    switch (dataTypeChanged) {
        case stepCount:
            [self updateTodaysStepCount];
            break;
            
        case activityClories:
            [self updateTodaysColories];
            break;
            
        case walkingDistance:
            [self updateTodaysWalkingDistance];
            break;
            
        case sleepType:
            
            break;
            
        default:
            break;
    }
}

//real time
- (void)onPdmsDataChange: (int32_t)totalStepCount calories: (int32_t)totalCalories distance: (int16_t)totalDistance {
    NSLog(@"[BLE][HealthKitView]updateToUIData realtime: %d, %d, %d", totalStepCount, totalCalories, totalDistance);
    
    self.stepCountLabel.text = [NSNumberFormatter localizedStringFromNumber:@(totalStepCount) numberStyle:NSNumberFormatterNoStyle];

    self.distanceLabel.text = [NSString stringWithFormat: @"%.2f %@", totalDistance/1000.0, NSLocalizedString(@"KM", @"KM")];// convert M to KM
    
    self.coloriesLabel.text = [NSString stringWithFormat: @"%.2f %@", totalCalories/1000.0, NSLocalizedString(@"kcal", @"kcal")
                               ];
}

- (void)onSleepDataChange: (NSDate *)startTime endTime: (NSDate *)endtime sleepMode: (int)mode {
    NSLog(@"[BLE][HealthKitView]notifyUiUpdateSleepFromHealthKit ++");
    [self updateLatestSleepData];
}

- (void)didDisconnect {
    NSLog(@"[BLE][HealthKitView]didDisconnect ++");
    [self dismissViewControllerAnimated: YES completion: nil];
}

- (void)forTest: (NSData *)data {
    NSLog(@"tempTest");
    //Byte *byte = (Byte *)[20];
    Byte *byte = (Byte *)[data bytes];
    NSLog(@"test,length = %d",[data length]);
    for (int i =0; i< 20; i ++) {
        NSLog(@"test: %d,  %02x", i, byte[i]);
    }
}

//private action
- (void)updateTodaysActivity {
    [self updateTodaysStepCount];
    [self updateTodaysColories];
    [self updateTodaysWalkingDistance];
    [self updateLatestSleepData];

}

- (void)updateTodaysStepCount {
    
    if (!hkManager) {
        return;
    }
    
    [hkManager getTodaysStepCount:^(double retValue) {
        if (retValue == -1) {
            self.stepCountLabel.text = @"Not avaiable";
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.stepCountLabel.text = [NSNumberFormatter localizedStringFromNumber:@(retValue) numberStyle:NSNumberFormatterNoStyle];
        });
        
        
    }];
}

- (void)updateTodaysColories {
    if (!hkManager) {
        return;
    }
    [hkManager getTodaysActivityColories:^(double retValue) {
        if (retValue == -1) {
            self.coloriesLabel.text = @"Not avaiable";
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *str = [NSString stringWithFormat: @"%.2f %@", retValue/1000, NSLocalizedString(@"kcal", @"kcal")];//convert cal to kcal
            self.coloriesLabel.text = str;
        });
        
    }];
}

- (void)updateTodaysWalkingDistance {
    if (!hkManager) {
        return;
    }
    [hkManager getTodaysWalkingDistance:^(double retValue) {
        if (retValue == -1) {
            self.distanceLabel.text = @"Not avaiable";
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *str = [NSString stringWithFormat: @"%.2f %@", retValue/1000, NSLocalizedString(@"KM", @"KM")];// convert M to KM
            self.distanceLabel.text = str;
        });
    }];
}

- (void)updateLatestSleepData {
    NSLog(@"[BLE][HealthKitView]updateLatestSleepData ++");
    
    if (!hkManager) {
        return;
    }
    
    [hkManager getLatestSleepData:HKCategoryValueSleepAnalysisAsleep ResultBack:^(NSInteger value, NSDate *startDate, NSDate *endDate, NSError *error) {
        if (error) {
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (value == HKCategoryValueSleepAnalysisAsleep) {
                NSLog(@"[BLE][HealthKitView]updateLatestSleepData: ASLEEP");
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"MM-dd HH:mm"];
                //[dateFormatter setDateFormat:@"MM-dd HH:mm"];
                NSLog(@"[BLE][HealthKitView]update Asleep::startDate: %@", [dateFormatter stringFromDate: startDate]);
                NSLog(@"[BLE][HealthKitView]update Asleep::endDate: %@", [dateFormatter stringFromDate: endDate]);
 
                [dateFormatter setDateFormat:@"LLL.dd"];
                NSString *date = [NSString stringWithFormat:@"%@-%@",[dateFormatter stringFromDate: startDate], [dateFormatter stringFromDate: endDate]];
                
                [dateFormatter setDateFormat:@"HH:mm"];
                NSString *time = [NSString stringWithFormat:@"%@-%@", [dateFormatter stringFromDate: startDate], [dateFormatter stringFromDate: endDate]];
                
                self.sleepStartTime.text = date;
                self.sleepEndTime.text = time;

            }
        });
    }];
    
    [hkManager getLatestSleepData:HKCategoryValueSleepAnalysisInBed ResultBack:^(NSInteger value, NSDate *startDate, NSDate *endDate, NSError *error) {
        if (error) {
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (value == HKCategoryValueSleepAnalysisInBed) {
                NSLog(@"[BLE][HealthKitView]updateLatestSleepData: inbed ");
                
                if (startDate == nil || endDate == nil) {
                     NSLog(@"data is null");
                    return;
                }
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"MM-dd HH:mm"];
                //[dateFormatter setDateFormat:@"MM-dd HH:mm"];
                NSLog(@"[BLE][HealthKitView]update Inbed::startDate: %@", [dateFormatter stringFromDate: startDate]);
                NSLog(@"[BLE][HealthKitView]update Inbed::endDate: %@", [dateFormatter stringFromDate: endDate]);

                [dateFormatter setDateFormat:@"MM-dd HH:mm"];
                //[dateFormatter setDateFormat:@"MM-dd HH:mm"];
                NSLog(@"[BLE][HealthKitView]update Asleep::startDate: %@", [dateFormatter stringFromDate: startDate]);
                NSLog(@"[BLE][HealthKitView]update Asleep::endDate: %@", [dateFormatter stringFromDate: endDate]);
                
                [dateFormatter setDateFormat:@"LLL.dd"];
                NSString *date = [NSString stringWithFormat:@"%@-%@",[dateFormatter stringFromDate: startDate], [dateFormatter stringFromDate: endDate]];
                
                [dateFormatter setDateFormat:@"HH:mm"];
                NSString *time = [NSString stringWithFormat:@"%@-%@", [dateFormatter stringFromDate: startDate], [dateFormatter stringFromDate: endDate]];
                
                self.inBedDate.text = date;
                self.inBedTime.text = time;
            }
        });
    }];
}

- (void)didEnterBackgroundNotification:(NSNotification*)notification
{
    NSLog(@"[BLE][HealthKitView]Entered background notification called.");
    [[PdmsSleepService getInstance] sendStartReadRequest: INDICATION_INTERVAL_BACKGROUND];
}

- (void)didEnterForegroundNotification:(NSNotification*)notification
{
    NSLog(@"[BLE][HealthKitView]Entered foreground notification called.");
    
    if (isViewShowing) {
        [[PdmsSleepService getInstance] sendStartReadRequest: INDICATION_INTERVAL_FORGROUND];
        [[PdmsSleepService getInstance] registerPSDelegate: self];
    }
}

//end of private action

@end
