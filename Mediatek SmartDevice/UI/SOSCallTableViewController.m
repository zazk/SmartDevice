//
//  SOSCallTableViewController.m
//  Mediatek SmartDevice
//
//  Created by user on 15-1-8.
//  Copyright (c) 2015年 Mediatek. All rights reserved.
//

#import "SOSCallTableViewController.h"
#import "SOSCallDataManager.h"
#import "SOSCallOperator.h"
#import "SOSContact.h"
#import "SOSContactTableViewCell.h"
#import "CallModeTableViewCell.h"
#import "MTKBleManager.h"

@interface SOSCallTableViewController () <SOSContactChangeNotify>{
@private
    SOSCallDataManager *dataMgr;
    SOSCallOperator *sosCallOperatorInstance;
    int mKeyCount;
    int mIndexCount;

}
- (IBAction)backButton:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *contactTextField;
@property (weak, nonatomic) IBOutlet UITextField *contact_1_textField;
@property (weak, nonatomic) IBOutlet UITextField *contact_2_textField;
@property (weak, nonatomic) IBOutlet UITextField *contact_3_textField;
@property (weak, nonatomic) IBOutlet UITextField *contact_4_textField;
@property (weak, nonatomic) IBOutlet UITextField *contact_5_textField;
@property (weak, nonatomic) IBOutlet UILabel *LabelCallModeValue;

@end

//static BOOL nibReg = NO;;
//static BOOL nibReg2 = NO;

@implementation SOSCallTableViewController

@synthesize contactTextField;
@synthesize contact_1_textField;
@synthesize contact_2_textField;
@synthesize contact_3_textField;
@synthesize contact_4_textField;
@synthesize contact_5_textField;
@synthesize LabelCallModeValue;

//delegate from ContactEditTableViewController
- (void) passValue: (NSString *)name phoneNumber: (NSString *)num {
    NSLog(@"SOSCallTableViewController::passValue: name = %@, phoneNum = %@", name, num);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"view testing testing");
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    dataMgr = [SOSCallDataManager sosCallDataMgrInstance];
    sosCallOperatorInstance = [SOSCallOperator getSosCallOperaterInstance];
    
    mKeyCount = [dataMgr getKeyCount];
    mIndexCount = [dataMgr getIndexCount];
    
    
    
    //[self updateContactsUI];
}

-(void)viewDidAppear:(BOOL)animated
{
    //[self updateContactsUI];
    NSLog(@"[SOSCallTableViewController]viewDidAppear ++");
    [self.tableView reloadData];
    
    if ([[MTKBleManager sharedInstance] getCurrentConnectState] != CONNECTION_STATE_CONNECTED) {
        NSLog(@"[SOSCallTableViewController]viewDidAppear, disconnect, finish");
        [self dismissViewControllerAnimated: YES completion: nil];
    }
    
    [dataMgr registerChangeDelegate: self];
}

-(void)viewDidDisappear:(BOOL)animated
{
     NSLog(@"viewDidDisappear ++");
    [dataMgr unRegisterChangeDelegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    if (mKeyCount > 1) {
        return 1;
    }
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    
    NSLog(@"[SOSCallTableViewController]numberOfRowsInSection::keycount = %d, indexcount = %d", mKeyCount, mIndexCount);
    
    if (section  == 0) {

        if (mKeyCount == 1) {
            return mIndexCount;
        } else {
            return mKeyCount;
        }

    } else if (section == 1) {
        NSLog(@"section 1 running");
        return 1;
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didSelectRowAtIndexPath ++, section = %d, row = %d", indexPath.section, indexPath.row);

    if (indexPath.section == 0) {
        [dataMgr setCurrentIndex: indexPath.row + 1];
        
        UINavigationController *navController = [self.storyboard instantiateViewControllerWithIdentifier:@"ContactEditTableViewControllerId"];
        
        [self presentViewController: navController animated: YES completion: nil];
        
    } else {
        
        UINavigationController *navController2 = [self.storyboard instantiateViewControllerWithIdentifier:@"CallModeTableViewControllerId"];
        
        [self presentViewController: navController2 animated: YES completion: nil];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SOSContactTableViewCell" forIndexPath:indexPath];
    
    NSLog(@"[SOSCallTableViewController]cellForRowAtIndexPath, secion = %d, row = %d ,reg1 = , reg2 = ", indexPath.section, indexPath.row);
    
    NSMutableDictionary *contactDic = [dataMgr getAllContact];
    // Configure the cell...
    if (indexPath.section == 0) {
        NSString *identifier = @"SOSContactTableViewCell";
        
        BOOL nibReg = NO;
        if (! nibReg) {
            NSLog(@"before register");
            UINib *nib = [UINib nibWithNibName:@"SOSContactTableViewCell" bundle: nil];
            [tableView registerNib: nib forCellReuseIdentifier: identifier];
            nibReg = YES;
        }
        
        SOSContactTableViewCell *contactCell = [tableView dequeueReusableCellWithIdentifier: identifier];
        
        int key = indexPath.row + 1;
        
        //set serial number
        [contactCell setSerial: key];
        
        //get name
        NSData *data = [contactDic objectForKey: [NSString stringWithFormat:@"%d", key]];
        SOSContact *contact = [NSKeyedUnarchiver unarchiveObjectWithData: data];
        
        if (contact && contact.name) {
            [contactCell setName: contact.name];
            [contactCell setDeleteBtnVisibility: YES];
        } else {
            [contactCell setDeleteBtnVisibility: NO];
        }
        
        return contactCell;
    } else {
    
        NSString *identifier2 = @"CallModeCellIdentifier";
        
        BOOL nibReg2 = NO;
        if (! nibReg2) {
            UINib *nib2 = [UINib nibWithNibName:@"CallModeTableViewCell" bundle: nil];
            [tableView registerNib: nib2 forCellReuseIdentifier: identifier2];
            nibReg2 = YES;
        }
        
        CallModeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier2];
        NSString *callModeStr;
        if ([dataMgr getMode] == 0) {
            callModeStr = NSLocalizedString(@"Auto loop", @"Auto loop");
        } else {
            callModeStr = NSLocalizedString(@"Manual", @"Manual");
        }
        [cell setModeValueLable: callModeStr];
        return cell;
    }
    
    return nil;
}



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

- (IBAction)backButton:(id)sender {
    [self dismissViewControllerAnimated: YES completion: nil];
}

- (void) updateContactsUI {
    NSMutableDictionary *contactDict = [dataMgr getAllContact];
    
    NSArray *keys = [contactDict allKeys];
    for (NSString *key in keys) {
        NSData *data = [contactDict objectForKey: key];
        SOSContact *contact = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        [self updateContacts: [key integerValue] value: contact];
    }
    
    if ([dataMgr getMode] == 0) {
        LabelCallModeValue.text = @"Auto loop";
    } else {
        LabelCallModeValue.text = @"Manual";
    }
}

- (void) updateContacts: (int)index value: (SOSContact *)contact {
    NSLog(@"updateContacts::index = %d, name = %@", index, contact.name);
    if (contact_1_textField == nil) {
        NSLog(@"nil");
    }
    switch (index) {
        case 1:
            [contact_1_textField setText: contact.name];
            break;
        case 2:
            [contact_2_textField setText: contact.name];
            break;
        case 3:
            [contact_3_textField setText: contact.name];
            break;
        case 4:
            [contact_4_textField setText: contact.name];
            break;
        case 5:
            [contact_5_textField setText: contact.name];
            break;
            
        default:
            break;
    }
    
}

- (void)onContactChange: (int)index contact: (SOSContact *)contacter {
    NSLog(@"[SOSCallTableViewController]onContactChange::index = %d, name = %@, number = %@", index, contacter.name, contacter.number);
    
    [self.tableView reloadData];
}

- (void)onConnectStateChange: (int)state {
    NSLog(@"[SOSCallTableViewController]onConnectStateChange::state = %d", state);
    [self dismissViewControllerAnimated: YES completion: nil];
}


@end
