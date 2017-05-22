//
//  CallModeTableViewController.m
//  Mediatek SmartDevice
//
//  Created by user on 15-1-8.
//  Copyright (c) 2015年 Mediatek. All rights reserved.
//

#import "CallModeTableViewController.h"
#import "SOSCallDataManager.h"

@interface CallModeTableViewController ()  {
    @private
    SOSCallDataManager *dataMgr;
    int mMode;
}

@end

@implementation CallModeTableViewController

@synthesize cellAutoLoop;
@synthesize cellManual;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    dataMgr = [SOSCallDataManager sosCallDataMgrInstance];
    mMode = [dataMgr getMode];
    
    
    [self updateDefaultUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 2;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didSelectRowAtIndexPath ++, row = %d", indexPath.row);

    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    switch (indexPath.row) {
        case 0:
            [cellAutoLoop setAccessoryType: UITableViewCellAccessoryCheckmark];
            [cellManual setAccessoryType: UITableViewCellAccessoryNone];
            [dataMgr setMode: 0];
            break;
            
        case 1:
            [cellAutoLoop setAccessoryType: UITableViewCellAccessoryNone];
            [cellManual setAccessoryType: UITableViewCellAccessoryCheckmark];
            [dataMgr setMode: 1];
            break;

            
        default:
            break;
    }

}

- (void)updateDefaultUI {
    NSLog(@"[CallModeTableViewController]updateDefaultUI, mode = %d", mMode);
    if (mMode == 0) {
        [cellAutoLoop setAccessoryType: UITableViewCellAccessoryCheckmark];
        [cellManual setAccessoryType: UITableViewCellAccessoryNone];
    } else {
        [cellAutoLoop setAccessoryType: UITableViewCellAccessoryNone];
        [cellManual setAccessoryType: UITableViewCellAccessoryCheckmark];
    }
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

- (IBAction)backBarButton:(id)sender {
    [self dismissViewControllerAnimated: YES completion: nil];
}
@end
