//
//  SOSCallDataManager.h
//  Mediatek SmartDevice
//
//  Created by user on 15-1-17.
//  Copyright (c) 2015年 Mediatek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SOSContact.h"
#import "SOSCallOperator.h"


@protocol SOSContactChangeNotify <NSObject>

- (void)onContactChange: (int)index contact: (SOSContact *)contacter;
- (void)onConnectStateChange: (int)state;

@end

@protocol SOSCallIndicate <NSObject>

-(void)didGetKeyCount;

@end

@interface SOSCallDataManager : NSObject

+ (id) sosCallDataMgrInstance;
- (void) registerChangeDelegate: (id<SOSContactChangeNotify>)changeDelegate;
- (void) unRegisterChangeDelegate: (id<SOSContactChangeNotify>)changeDelegate;
-  (NSMutableDictionary *)getAllContact;
- (SOSContact *)getCurrentContact;
- (void) setContact: (SOSContact *)newContacter;
- (void) deleteContact: (int)keyId index: (int)indexId;

- (int)getKeyCount;
- (int)getIndexCount;
- (int)getMode;
- (void)setMode: (int)mode;
- (int)getRepTimes;

-(void)clearAllData;

@property (nonatomic, assign) id<SOSCallIndicate> indicate;
@property (atomic, assign) int currentIndex;

@end
