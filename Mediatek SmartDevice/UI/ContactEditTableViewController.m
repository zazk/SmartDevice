//
//  ContactEditTableViewController.m
//  Mediatek SmartDevice
//
//  Created by user on 15-1-15.
//  Copyright (c) 2015年 Mediatek. All rights reserved.
//

#import "ContactEditTableViewController.h"
#import "SOSCallDataManager.h"
#import "SOSContact.h"

static int MAX_NAME_LENGTH = 30;
static int MAX_PHONENUM_LENGHT = 20;

@interface ContactEditTableViewController () <SOSContactChangeNotify> {
@private
    SOSCallDataManager *dataMgr;
}
@property (weak, nonatomic) IBOutlet UITextField *phoneNumTextField;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
- (IBAction)OKButton:(id)sender;
- (IBAction)CancelButton:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *okButton;

@end

@implementation ContactEditTableViewController

@synthesize nameTextField;
@synthesize phoneNumTextField;
@synthesize passValueDelegate;
@synthesize okButton;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    nameTextField.delegate = self;
    phoneNumTextField.delegate = self;
    
    dataMgr = [SOSCallDataManager sosCallDataMgrInstance];
    [dataMgr registerChangeDelegate: self];
    [self updateUI];
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSLog(@"shouldChangeCharactersInRange ++ ");
    
    NSMutableString *newtxt = [NSMutableString stringWithString:textField.text];
    
    [newtxt replaceCharactersInRange:range withString:string];
    
    if (textField.tag == nameTextField.tag) {
         return ([newtxt length] <= MAX_NAME_LENGTH);
    } else if (textField.tag == phoneNumTextField.tag) {
         return ([newtxt length] <= MAX_PHONENUM_LENGHT);
    }
    
    return ([newtxt length] <= MAX_NAME_LENGTH);
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 5;
    }
    
    return 20;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didSelectRowAtIndexPath ++, section = %d, row = %d", indexPath.section, indexPath.row);
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
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

- (IBAction)OKButton:(id)sender {
    NSString *name = nameTextField.text;
    NSString *phoneNum = phoneNumTextField.text;
    NSLog(@"ContactEdit::ok button clicked, name = %@, phoneNum = %@", name, phoneNum);
    
    if (name.length <= 0 || phoneNum.length <= 0) {
        NSLog(@"testing name or phone number == nil");
        
        //show alert dialog
        UIAlertController *alert = [UIAlertController alertControllerWithTitle: NSLocalizedString(@"Warning", @"Warning")
                                                                       message: NSLocalizedString(@"filed_not_empty", @"Name or Phone Number field should not be empty.")
                                                                preferredStyle: UIAlertControllerStyleAlert];
        UIAlertAction *OKAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK") style: UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            
        }];
        [alert addAction: OKAction];
        [self presentViewController: alert animated: YES completion: nil];

        return;
    }
    
    SOSContact *contact = [[SOSContact alloc] init];
    contact.name = name;
    contact.number = phoneNum;
    [dataMgr setContact: contact];

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)CancelButton:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) updateUI {
    NSLog(@"[ContactEditTableViewController]updateUI ++");
    SOSContact *contact = [dataMgr getCurrentContact];
    if (contact) {
        [nameTextField setText: contact.name];
        [phoneNumTextField setText: contact.number];
    }
}

- (void)onConnectStateChange: (int)state {
    NSLog(@"[ContactEditTableViewController]onConnectStateChange ++, state = %d", state);
    if (state == 2) {
        //connected
        [okButton setEnabled: YES];
    } else {
        [okButton setEnabled: NO];
    }
}

- (void)onContactChange: (int)index contact: (SOSContact *)contacter {
    
}
@end
