//
//  DeviceManagerTableViewController.m
//  BLEManager
//
//  Created by ken on 14-7-11.
//  Copyright (c) 2014年 com.mediatek. All rights reserved.
//

#import "DeviceManagerTableViewController.h"
#import "CachedBLEDevice.h"
#import "MTKBleManager.h"
#import "MTKDeviceParameterRecorder.h"
#import "BackgroundManager.h"
#import "SOSCallDataManager.h"

@interface DeviceManagerTableViewController () <CachedBLEDeviceDelegate>

@property (weak, nonatomic) CachedBLEDevice *mDevice;

@property (weak, nonatomic) IBOutlet UITextField *mDeviceNameTextField;
- (IBAction)deleteAction:(UIButton *)sender;
- (IBAction)returnKeyPressed:(UITextField *)sender;
- (IBAction)backButtonAction:(UIBarButtonItem *)sender;

@property (weak, nonatomic) MTKBleManager* mManager;

@end

@implementation DeviceManagerTableViewController

@synthesize mDeviceNameTextField;
@synthesize mDevice;

@synthesize mManager;

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

-(void)viewWillAppear:(BOOL)animated
{
    if([MTKDeviceParameterRecorder getDeviceParameters].count == 0)
    {
        [self dismissViewControllerAnimated:NO completion:nil];
        return;
    }
    
    mManager = [MTKBleManager sharedInstance];
    
    mDevice = [CachedBLEDevice defaultInstance];
    // register the device attribute change listener
    [mDevice registerAttributeChangedListener:self];
    
    // update the device name text field
    [mDeviceNameTextField setText:mDevice.mDeviceName];
    
    // update the device connection button title
//    [self updateDisconnectButtonState];
    
    self.tableView.scrollEnabled = NO;
}

/********************************************************************************/
/* while the view is going to disappear, check the text field is equal to device*/
/* name, if not, change the device name to be the text field text and persit it */
/********************************************************************************/
-(void)viewWillDisappear:(BOOL)animated
{
    if ([self checkDeviceNameValid:mDeviceNameTextField.text] && ![mDeviceNameTextField.text isEqualToString:mDevice.mDeviceName])
    {
        mDevice.mDeviceName = mDeviceNameTextField.text;
        [mDevice persistData:2];
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    NSLog(@"[DeviceManagerTableViewController] [viewDidDisappear] enter");
    [mDevice unregisterAttributeChangedListener:self];
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

/********************************************************************************/
/* used to update the disconnect button according to the connection state       */
/********************************************************************************/
/*-(void)updateDisconnectButtonState
{
//    if (mDevice.mDevicePeripheral == nil)
//    {
//        NSLog(@"[DeviceManagerTableViewController] [updateDisconnectButtonState] mDevice.mDevicePeripheral is nil");
//        [mDisconnectButton setTitle:@"Connect" forState:UIControlStateNormal];
//        [mDisconnectButton setEnabled:false];
//        return;
//    }
    if (mDevice.mConnectionState == CONNECTION_STATE_CONNECTED
        || mDevice.mConnectionState == CONNECTION_STATE_CONNECTING)
    {
        NSLog(@"[DeviceManagerTableViewController] [updateDisconnectButtonState] set button to be DISCONNECT");
        [mDisconnectButton setEnabled:YES];
        [mDisconnectButton setTitle:@"Disconnect" forState:UIControlStateNormal];
        if (mDevice.mConnectionState == CONNECTION_STATE_CONNECTING)
        {
            [mDisconnectButton setEnabled:NO];
        }
    }
    else if (mDevice.mConnectionState == CONNECTION_STATE_DISCONNECTED
             || mDevice.mConnectionState == CONNECTION_STATE_DISCONNECTING)
    {
        NSLog(@"[DeviceManagerTableViewController] [updateDisconnectButtonState] set button to be CONNECT");
        [mDisconnectButton setEnabled:YES];
        [mDisconnectButton setTitle:@"Connect" forState:UIControlStateNormal];
        if (mDevice.mConnectionState == CONNECTION_STATE_DISCONNECTING)
        {
            [mDisconnectButton setEnabled:NO];
        }
    }
}*/

/********************************************************************************/
/* if the device is connected or disconnected, the callback will be called.     */
/* the should update the disconnect button title & change the button action     */
/********************************************************************************/
-(void)onDeviceAttributeChanged:(int)which
{
//    if (which == DEVICE_CONNECTION_STATE_CHANGE
//        || which == DEVICE_PERIPHERAL_CHANGE)
//    {
////        [self updateDisconnectButtonState];
//        if (which == DEVICE_CONNECTION_STATE_CHANGE)
//        {
//            [[BackgroundManager sharedInstance] stopConnectTimer];
//        }
//    }
}

/********************************************************************************/
/* disconnect button click action                                               */
/* if the device is disconnected, click the button to do connect action         */
/* if the device is connected, click the button to do disconnect acion          */
/********************************************************************************/
//- (IBAction)disconnectAction:(UIButton *)sender {
//    NSString* str = sender.titleLabel.text;
//    NSLog(@"[DeviceManagerTableViewController] [disconnectAction] str : %@", str);
//    
//    if (mDevice.mConnectionState == CONNECTION_STATE_CONNECTED)
//    {
//        // TODO do disconnect action
//        BOOL b = [[BackgroundManager sharedInstance] disconnectDevice:[mDevice getDevicePeripheral]];
//        if (b == YES)
//        {
//            NSLog(@"[DeviceManagerTableViewController] [disconnectAction] do disconnect action");
//            mDevice.mConnectionState = CONNECTION_STATE_DISCONNECTING;
//            [self updateDisconnectButtonState];
//            [[BackgroundManager sharedInstance] setDisconnectFromUx:YES];
//        }
//    }
//    else if (mDevice.mConnectionState == CONNECTION_STATE_DISCONNECTED)
//    {
//        // TODO do connect action
//        BOOL b = [[BackgroundManager sharedInstance] connectDevice:[mDevice getDevicePeripheral]];
//        if (b == YES)
//        {
//            NSLog(@"[DeviceManagerTableViewController] [disconnectAction] do connect action");
//            mDevice.mConnectionState = CONNECTION_STATE_CONNECTING;
//            [self updateDisconnectButtonState];
//        }
//    }
//}

/********************************************************************************/
/* delete button click action                                                   */
/* do delete cached device which is in db.                                      */
/********************************************************************************/
- (IBAction)deleteAction:(UIButton *)sender {
    NSLog(@"[DeviceManagerTableViewController] [deleteAction] enter");
    //[MTKDeviceParameterRecorder deleteDevice:mDevice.mDeviceIdentifier];
//    UIAlertView* alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Forget device", @"Forget device") message:@"Your iPhone and other devices using iCloud keychain will no longer connect to this device automatically" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Forget", nil];
//    alert.tag = 0;
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") destructiveButtonTitle:NSLocalizedString(@"Forget", @"Forget") otherButtonTitles:nil];
    [sheet showInView:self.view];
    
//    [alert show];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"click sheet enter : %ld", (long)buttonIndex);

        if (buttonIndex == 0)
        {
            NSLog(@"[DeviceManagerTableViewController] [clickedButtonAtIndex] begin to delete the device");
            
            [[BackgroundManager sharedInstance] setDisconnectFromUx:YES];
            
            [[BackgroundManager sharedInstance] disconnectDevice:[mDevice getDevicePeripheral]];
            [[MTKBleManager sharedInstance] forgetPeripheral];
            
            [MTKDeviceParameterRecorder deleteDevice:mDevice.mDeviceIdentifier];
            [[BackgroundManager sharedInstance] stopScan];
            
            [[SOSCallDataManager sosCallDataMgrInstance] clearAllData];
            
            [self dismissViewControllerAnimated:NO completion:nil];
        }
}

/********************************************************************************/
/* keyboard return key clicked action                                           */
/* click the return key to save the device name which has been changed by user  */
/********************************************************************************/
- (IBAction)returnKeyPressed:(UITextField *)sender {
    [mDeviceNameTextField resignFirstResponder];
    if([self checkDeviceNameValid:mDeviceNameTextField.text] == NO)
    {
        NSLog(@"[DeviceManagerTableViewController] [returnKeyPressed] device name text field length is 0");
        UIAlertView* view = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning", @"Warning") message:NSLocalizedString(@"Device name should not be empty", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
        view.tag = 1;
        [view show];
        return;
    }
    mDevice.mDeviceName = mDeviceNameTextField.text;
    [mDevice persistData:2];
}

- (IBAction)backButtonAction:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/********************************************************************************/
/* alert dialog button click listener                                           */
/* if user click the forget button, do delete action and dismiss the view       */
/********************************************************************************/
-(void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1)
    {
        mDeviceNameTextField.text = mDevice.mDeviceName;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

-(BOOL)checkDeviceNameValid:(NSString*)name
{
    if(name == nil || name.length == 0)
    {
        return NO;
    }
    if ([[name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]length] == 0)
    {
        return NO;
    }
    return YES;
}

@end
