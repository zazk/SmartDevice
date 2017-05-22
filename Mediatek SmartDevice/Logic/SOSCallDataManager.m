//
//  SOSCallDataManager.m
//  Mediatek SmartDevice
//
//  Created by user on 15-1-17.
//  Copyright (c) 2015年 Mediatek. All rights reserved.
//

#import "SOSCallDataManager.h"

static NSString *UserDefaultKey_SOSContact = @"UserDefaultKey_SOSContact";
static NSString *UserDefaultKey_SOSContact_keycount = @"UserDefaultKey_SOSContact_keycount";
static NSString *UserDefaultKey_SOSContact_indexcount = @"UserDefaultKey_SOSContact_indexcount";
static NSString *UserDefaultKey_SOSContact_mode = @"UserDefaultKey_SOSContact_mode";
static NSString *UserDefaultKey_SOSContact_reptimes = @"UserDefaultKey_SOSContact_reptimes";

@interface SOSCallDataManager () <SOSCallDataDelegate>{
@private
    NSUserDefaults *userSharePref;
    NSMutableArray *changeDelegateArr;
    SOSCallOperator *operatorInstance;
    SOSContact *mCurrentContact;
}
@end

@implementation SOSCallDataManager

@synthesize currentIndex;
@synthesize indicate;

static SOSCallDataManager *this = nil;

+ (id) sosCallDataMgrInstance {
    if (!this) {
        this = [[SOSCallDataManager alloc] init];
    }
    return this;
}

- (id) init {
    NSLog(@"[SOSCallDataManager]init ++");
    self = [super init];
    if (self) {
        currentIndex = -1;
        userSharePref = [NSUserDefaults standardUserDefaults];
        operatorInstance = [SOSCallOperator getSosCallOperaterInstance];
        
        [operatorInstance registerSOSCallDelegate: self];
        
        changeDelegateArr = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) setContact: (SOSContact *)newContacter{
    NSLog(@"[SOSCallDataManager]setContact ++, currentIndex = %d, name = %@, phoneNum = %@", currentIndex, newContacter.name, newContacter.number);
    if (newContacter == nil || newContacter.name == nil || newContacter.number == nil || newContacter.name.length <= 0 || newContacter.number.length <= 0 ) {
        NSLog(@"[SOSCallDataManager]ERROR: invalid contacter");
        return;
    }
    
    SOSContact *previousOne = [self getCurrentContact];
    
    if (previousOne != nil) {
        NSLog(@"[SOSCallDataManager]setContact, oldName = %@, oldNum = %@", previousOne.name, previousOne.number);
    }

//    //convert SOSContacter to NSData, saving to NSUserDefault
//    NSData *data = [NSKeyedArchiver archivedDataWithRootObject: newContacter];
//    
//    //convert integer index to NSString
//    NSString *indexString = [NSString stringWithFormat: @"%d", currentIndex];
//
//    NSMutableDictionary *dic = [userSharePref objectForKey: UserDefaultKey_SOSContact];
//    NSMutableDictionary *dicCopy;
//    if (!dic) {
//        dicCopy = [[NSMutableDictionary alloc] init];
//    } else {
//        dicCopy = [dic mutableCopy];
//    }
//
//    [dicCopy setObject: data forKey: indexString];
//
//    [userSharePref setObject: dicCopy forKey: UserDefaultKey_SOSContact];
//    
//    //notify change
//    [self notifyChange: currentIndex contact: newContacter];
    //[self setLocalContactAtIndex: currentIndex contact: newContacter];
    mCurrentContact = newContacter;
    
    //save to remote device
    int keycount = [self getKeyCount];
    int insertKey = 1;
    int insertIndex = 1;

    if (keycount == 1) {
        insertKey = 1;
        insertIndex = currentIndex;
    } else {
        insertKey = currentIndex;
        insertIndex = 1;
    }
    
    if (previousOne == nil) {
        NSLog(@"[SOSCallDataManager] previous not exist, add to remote");
        [operatorInstance setContact: insertKey index: insertIndex contact: newContacter updateType: WRITE_TYPE_ADD];
    } else {
        //old contact already exists
        if (previousOne.name != nil) {
            if ([previousOne.name isEqualToString: newContacter.name]) {
                NSLog(@"[SOSCallDataManager]new name is same to previous, do not save to remote");
            } else {
                [operatorInstance sendWriteContactName: insertKey index: insertIndex name: newContacter.name updateType: WRITE_TYPE_MODIFY];
            }
        }
        
        if (previousOne.number != nil) {
            if ([previousOne.number isEqualToString: newContacter.number]) {
                 NSLog(@"[SOSCallDataManager]new number is same to previous, do not save to remote");
            } else {
                [operatorInstance sendWriteContactNumber: insertKey index: insertIndex number: newContacter.number updateType: WRITE_TYPE_MODIFY];
            }
        }
    }
}

- (void) deleteContact: (int)keyId index: (int)indexId {
    NSLog(@"[SOSCallDataManager]deleteContact ++, keyId = %d, indexId = %d", keyId, indexId);
    
    //delete locally
    int deleteIndex = 0;
    if ([self getKeyCount] > 1) {
        deleteIndex = keyId;
    } else {
        deleteIndex = indexId;
    }
    
    NSLog(@"[SOSCallDataManager]deleteContact, keycount = %d, deleteIndex = %d", [self getKeyCount], deleteIndex);

    [self removeLocalContactAtIndex: deleteIndex];
    
    //delete remotely
    [operatorInstance sendDeleteContact: keyId index: indexId];
}

/**
 *    will not set to remote device
 *
 *    @param index      <#index description#>
 *    @param newContact <#newContact description#>
 */
- (void)setContact:(int)index contact: (SOSContact *)newContact {
    NSLog(@"[SOSCallDataManager]setContact::index = %d", index);

    if (newContact == nil || (newContact.name == nil && newContact.number == nil)) {
        NSLog(@"[SOSCallDataManager]ERROR: invalid contacter");
        return;
    }

    //convert SOSContacter to NSData, saving to NSUserDefault
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject: newContact];
    
    //convert integer index to NSString
    NSString *indexString = [NSString stringWithFormat: @"%d", index];
    
    NSMutableDictionary *dic = [userSharePref objectForKey: UserDefaultKey_SOSContact];
    NSMutableDictionary *dicCopy;
    if (!dic) {
        dicCopy = [[NSMutableDictionary alloc] init];
    } else {
        dicCopy = [dic mutableCopy];
    }
    
    [dicCopy setObject: data forKey: indexString];
    
    [userSharePref setObject: dicCopy forKey: UserDefaultKey_SOSContact];
    
    //notify change
    [self notifyChange: index contact: newContact];
}

- (void)setLocalContactAtIndex: (int)index contact: (SOSContact *)newContact {
    NSLog(@"[SOSCallDataManager]setLocalContactAtIndex, index = %d, name = %@, number = %@", index, newContact.name, newContact.number);
    
    if (newContact == nil || (newContact.name == nil && newContact.number == nil)) {
        NSLog(@"[SOSCallDataManager]setLocalContactAtIndex: invalid contacter");
        return;
    }
    
    //convert SOSContacter to NSData, saving to NSUserDefault
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject: newContact];
    
    //convert integer index to NSString
    NSString *indexString = [NSString stringWithFormat: @"%d", currentIndex];
    
    NSMutableDictionary *dic = [userSharePref objectForKey: UserDefaultKey_SOSContact];
    NSMutableDictionary *dicCopy;
    if (!dic) {
        dicCopy = [[NSMutableDictionary alloc] init];
    } else {
        dicCopy = [dic mutableCopy];
    }
    
    [dicCopy setObject: data forKey: indexString];
    
    [userSharePref setObject: dicCopy forKey: UserDefaultKey_SOSContact];
    
    //notify change
    [self notifyChange: currentIndex contact: newContact];
}

- (void)removeLocalContactAtIndex: (int)index {
    NSLog(@"[SOSCallDataManager]removeLocalContactAtIndex, index = %d", index);
    NSMutableDictionary *dic = [userSharePref objectForKey: UserDefaultKey_SOSContact];
    if (dic == nil) {
        NSLog(@"[SOSCallDataManager]removeContactAtIndex, dic == nil, return");
        return;
    }
    
    NSMutableDictionary *dicCopy = [dic mutableCopy];
    [dicCopy removeObjectForKey: [NSString stringWithFormat:@"%d", index]];
    
    [userSharePref setObject: dicCopy forKey: UserDefaultKey_SOSContact];
}

- (SOSContact *)getCurrentContact{
    NSLog(@"[SOSCallDataManager]getCurrentContact ++, currentIndex = %d", currentIndex);
    SOSContact *ret;
    
    NSMutableDictionary *dic = [userSharePref objectForKey: UserDefaultKey_SOSContact];
    
    if (dic == nil) {
        NSLog(@"[SOSCallDataManager]getCurrentContact::dic == nil");
    } else {
        NSLog(@"dic count = %d", [dic count]);
    }
    
    if (dic == nil || [dic count] <= 0) {
        NSLog(@"[SOSCallDataManager]getCurrentContact, no dic");
        return nil;
    }
    
    //convert integer index to NSString
    NSString *indexString = [NSString stringWithFormat: @"%d", currentIndex];
    NSData *data = [dic objectForKey: indexString];
    if (data) {
        ret = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    
    //get contacts saved in user data
    
    NSLog(@"[SOSCallDataManager]getCurrentContact::retvalue--name = %@, phoneNum = %@", ret.name, ret.number);
    
    return ret;
}

-  (NSMutableDictionary *)getAllContact {
    return [userSharePref objectForKey: UserDefaultKey_SOSContact];
}

- (void)setContacterInDic: (SOSContact *)contacter index: (int)index {
    
}

- (void) registerChangeDelegate: (id<SOSContactChangeNotify>)changeDelegate {
    if (changeDelegateArr) {
        [changeDelegateArr addObject: changeDelegate];
    }
}

- (void) unRegisterChangeDelegate: (id<SOSContactChangeNotify>)changeDelegate {
    if (changeDelegateArr && [changeDelegateArr containsObject: changeDelegate]) {
        [changeDelegateArr removeObject: changeDelegate];
    }
}

- (void)notifyChange: (int)index contact: (SOSContact *)contacter {
    if (changeDelegateArr) {
        for (id<SOSContactChangeNotify> changeDelegate in changeDelegateArr) {
            [changeDelegate onContactChange: index contact: contacter];
        }
    }
}

- (void)onIndication: (int)keyCout indexCount: (int)indexC mode: (int)modeValue repeatTimes: (int)repTimes {
    NSLog(@"[SOSCallDataManager]onIndication:: keycoutn = %d, indecount = %d, mode = %d, repeatetime = %d",
          keyCout, indexC, modeValue, repTimes);
    [[NSUserDefaults standardUserDefaults] setInteger: keyCout forKey: UserDefaultKey_SOSContact_keycount];
    [[NSUserDefaults standardUserDefaults] setInteger: indexC forKey: UserDefaultKey_SOSContact_indexcount];
    [[NSUserDefaults standardUserDefaults] setInteger: modeValue forKey: UserDefaultKey_SOSContact_mode];
    [[NSUserDefaults standardUserDefaults] setInteger: repTimes forKey: UserDefaultKey_SOSContact_reptimes];
    if (indicate) {
        [indicate didGetKeyCount];
    }
}

- (void)onReadNameNumber: (int)keyId indexId: (int)index name: (NSString *)nameVal number: (NSString *)numberVal {
    NSLog(@"[SOSCallDataManager]onReadNameNumber::keyId = %d, indexid = %d, name = %@, num = %@",
          keyId, index, nameVal, numberVal);
    int insertIndex = 0;
    if ([self getKeyCount] == 1) {
        insertIndex = index;
    } else {
        insertIndex = keyId;
    }
    
    SOSContact *newOne = [[SOSContact alloc] init];
    newOne.name = nameVal;
    newOne.number = numberVal;
    
    [self setContact: insertIndex contact: newOne];
    
}

- (void)onWriteCallBack: (int)cmdLabel writeType: (int)type keyId: (int)keyIdVal indexId: (int)indexIdVal valueTag: (NSArray *)valueTagArray {
    NSLog(@"[SOSCallDataManager]onWriteCallBack, type = %d",  type);
    switch (type) {
        case WRITE_TYPE_ADD:
        case WRITE_TYPE_MODIFY:
        {
            int retIndex = [self getKeyCount] == 1 ? indexIdVal: keyIdVal;
            if (mCurrentContact && currentIndex == retIndex) {
                [self setLocalContactAtIndex: currentIndex contact: mCurrentContact];
                mCurrentContact = nil;
            }
        }
            break;
//            
//        case WRITE_TYPE_MODIFY:
//            break;
            
        case WRITE_TYPE_DELETE://delete
        {
            //delete locally
            int deleteIndex = 0;
            if ([self getKeyCount] > 1) {
                deleteIndex = keyIdVal;
            } else {
                deleteIndex = indexIdVal;
            }
            
            NSLog(@"[SOSCallDataManager]onWriteCallBack, deleted: keycount = %d, deleteIndex = %d", [self getKeyCount], deleteIndex);
            
//            [self removeLocalContactAtIndex: deleteIndex];
        }
            break;
            
        default:
            break;
    }
    
}

- (void)onReadMode: (int)keyId indexId: (int)index mode: (int)modeVal {
    [[NSUserDefaults standardUserDefaults] setInteger: modeVal forKey: UserDefaultKey_SOSContact_mode];
}

- (void)onReadRepTimes: (int)keyId indexId: (int)index repTimes: (int)repTimesVal {
    [[NSUserDefaults standardUserDefaults] setInteger: repTimesVal forKey: UserDefaultKey_SOSContact_reptimes];
}

- (void)onConnectStateChange: (int)state {
    NSLog(@"[SOSCallDataManager]onConnectStateChange::state = %d", state);
    for (id<SOSContactChangeNotify>del in changeDelegateArr) {
        [del onConnectStateChange: state];
    }
}

- (int)getKeyCount {
    return [[NSUserDefaults standardUserDefaults] integerForKey: UserDefaultKey_SOSContact_keycount];
}

- (int)getIndexCount {
    return [[NSUserDefaults standardUserDefaults] integerForKey: UserDefaultKey_SOSContact_indexcount];
}

- (void)setMode:(int)mode {
    NSLog(@"[SOSCallDataManager]setMode, mode = %d", mode);
    if (mode == [self getMode]) {
        NSLog(@"[SOSCallDataManager]setMode: the same with saved mode, return");
        return;
    }
    [[NSUserDefaults standardUserDefaults] setInteger: mode forKey: UserDefaultKey_SOSContact_mode];
    [operatorInstance sendWriteMode: 1 index: 1 mode: mode];
}

- (int)getMode {
    return [[NSUserDefaults standardUserDefaults] integerForKey: UserDefaultKey_SOSContact_mode];
}

- (int)getRepTimes {
    return [[NSUserDefaults standardUserDefaults] integerForKey: UserDefaultKey_SOSContact_reptimes];
}

-(void)clearAllData {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:UserDefaultKey_SOSContact];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:UserDefaultKey_SOSContact_keycount];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:UserDefaultKey_SOSContact_indexcount];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:UserDefaultKey_SOSContact_mode];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:UserDefaultKey_SOSContact_reptimes];
}

@end
