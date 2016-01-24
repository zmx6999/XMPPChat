//
//  XMPPTool.h
//  UseXmpp
//
//  Created by zmx on 16/1/19.
//  Copyright © 2016年 zmx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPFramework.h"

@interface XMPPTool : NSObject

@property (nonatomic, strong) XMPPStream *stream;

@property (nonatomic, strong) XMPPAutoPing *autoping;

@property (nonatomic, strong) XMPPReconnect *reconnect;

@property (nonatomic, strong) XMPPvCardTempModule *cardTempModule;

@property (nonatomic, strong) XMPPvCardAvatarModule *cardAvatarModule;

@property (nonatomic, strong) XMPPRoster *roster;

@property (nonatomic, strong) XMPPRosterCoreDataStorage *rosterCoreData;

@property (nonatomic, strong) XMPPMessageArchiving *messageArchiving;

@property (nonatomic, strong) XMPPMessageArchivingCoreDataStorage *messageArchivingCoreData;

@property (nonatomic, strong) XMPPRoomCoreDataStorage *roomCoreDataStorage;

+ (instancetype)sharedTool;

- (void)loginWithJID:(XMPPJID *)jid pwd:(NSString *)pwd;

@end
