//
//  XMPPTool.m
//  UseXmpp
//
//  Created by zmx on 16/1/19.
//  Copyright © 2016年 zmx. All rights reserved.
//

#import "XMPPTool.h"

@interface XMPPTool () <XMPPStreamDelegate, XMPPAutoPingDelegate, XMPPReconnectDelegate, XMPPvCardTempModuleDelegate>

@property (nonatomic, copy) XMPPJID *jid;

@property (nonatomic, copy) NSString *pwd;

@end

static XMPPTool *instance;

@implementation XMPPTool

+ (instancetype)sharedTool {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)loginWithJID:(XMPPJID *)jid pwd:(NSString *)pwd {
    NSLog(@"%s", __func__);
    self.stream = [[XMPPStream alloc] init];
    
    self.stream.hostName = @"192.168.31.196";
    self.stream.hostPort = 5222;
    [self.stream setMyJID:jid];
    
    [self.stream addDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    BOOL success = [self.stream connectWithTimeout:-1 error:nil];
    
    self.jid = jid;
    self.pwd = pwd;
    
    [self setModule];
}

- (void)setModule {
    self.autoping = [[XMPPAutoPing alloc] initWithDispatchQueue:dispatch_get_global_queue(0, 0)];
    self.autoping.pingInterval = 1;
    self.autoping.pingInterval = 20;
    self.autoping.respondsToQueries = YES;
    [self.autoping addDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    [self.autoping activate:self.stream];
    
    self.reconnect = [[XMPPReconnect alloc] initWithDispatchQueue:dispatch_get_global_queue(0, 0)];
    self.reconnect.autoReconnect = YES;
    [self.reconnect addDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    [self.reconnect activate:self.stream];
    
    self.cardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:[XMPPvCardCoreDataStorage sharedInstance] dispatchQueue:dispatch_get_global_queue(0, 0)];
    [self.cardTempModule addDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    [self.cardTempModule activate:self.stream];
    
    self.cardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:self.cardTempModule dispatchQueue:dispatch_get_global_queue(0, 0)];
    [self.cardAvatarModule activate:self.stream];
    
    self.rosterCoreData = [XMPPRosterCoreDataStorage sharedInstance];
    self.roster = [[XMPPRoster alloc] initWithRosterStorage:self.rosterCoreData dispatchQueue:dispatch_get_global_queue(0, 0)];
    self.roster.autoFetchRoster = NO;
    [self.roster activate:self.stream];
    
    self.messageArchivingCoreData = [XMPPMessageArchivingCoreDataStorage sharedInstance];
    self.messageArchiving = [[XMPPMessageArchiving alloc] initWithMessageArchivingStorage:self.messageArchivingCoreData dispatchQueue:dispatch_get_global_queue(0, 0)];
    [self.messageArchiving activate:self.stream];
    
    self.roomCoreDataStorage = [XMPPRoomCoreDataStorage sharedInstance];
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender {
    NSLog(@"%s", __func__);
    XMPPPlainAuthentication *authentication = [[XMPPPlainAuthentication alloc] initWithStream:self.stream password:self.pwd];
    [self.stream authenticate:authentication error:nil];
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    NSLog(@"%s", __func__);
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"available"];
    XMPPElement *element = [[XMPPElement alloc] initWithName:@"show" stringValue:@"chat"];
    [presence addChild:element];
    [self.stream sendElement:presence];
}

@end
