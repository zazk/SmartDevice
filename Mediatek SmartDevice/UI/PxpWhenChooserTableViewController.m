//
//  PxpWhenChooserTableViewController.m
//  BLEManager
//
//  Created by ken on 14-7-8.
//  Copyright (c) 2014年 com.mediatek. All rights reserved.
//

#import "PxpWhenChooserTableViewController.h"
#import "CachedBLEDevice.h"
#import "MTKBleProximityService.h"


@interface PxpWhenChooserTableViewController ()

@property (weak, nonatomic) IBOutlet UITableViewCell *mOutOfRangeChooser;
@property (weak, nonatomic) IBOutlet UITableViewCell *mInRangeChooser;
@property (weak, nonatomic) CachedBLEDevice *mDevice;
- (IBAction)backButtonAction:(UIBarButtonItem *)sender;

@end

@implementation PxpWhenChooserTableViewController

@synthesize mOutOfRangeChooser;
@synthesize mInRangeChooser;

@synthesize mDevice;

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
    
    [mOutOfRangeChooser setAccessoryType:UITableViewCellAccessoryNone];
    [mInRangeChooser setAccessoryType:UITableViewCellAccessoryNone];
    
    mDevice = [CachedBLEDevice defaultInstance];
    
    if (mDevice.mRangeType == RANGE_ALERT_OUT) {
        [mOutOfRangeChooser setAccessoryType:UITableViewCellAccessoryCheckmark];
    } else {
        [mInRangeChooser setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
    
}

-(void)viewDidAppear:(BOOL)animated
{
    self.tableView.scrollEnabled = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        return 2;
    }
    return 0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [mOutOfRangeChooser setAccessoryType:UITableViewCellAccessoryNone];
    [mInRangeChooser setAccessoryType:UITableViewCellAccessoryNone];
    
    if (indexPath.row == [tableView indexPathForCell:mOutOfRangeChooser].row) {
        [mOutOfRangeChooser setAccessoryType:UITableViewCellAccessoryCheckmark];
        [mDevice updateDeviceConfiguration:CONFIG_RANGE_WHEN_CHOOSER_STATE_CHANGE changedValue:RANGE_ALERT_OUT];
    } else if (indexPath.row == [tableView indexPathForCell:mInRangeChooser].row) {
        [mInRangeChooser setAccessoryType:UITableViewCellAccessoryCheckmark];
        [mDevice updateDeviceConfiguration:CONFIG_RANGE_WHEN_CHOOSER_STATE_CHANGE changedValue:RANGE_ALERT_IN];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

//-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    if (section == 0)
//    {
//        return 30;
//    }
//    return 20;
//}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
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

- (IBAction)backButtonAction:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
