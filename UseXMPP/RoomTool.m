//
//  RoomTool.m
//  UseXmpp
//
//  Created by zmx on 16/1/20.
//  Copyright © 2016年 zmx. All rights reserved.
//

#import "RoomTool.h"
#import "XMPPTool.h"

@interface RoomTool () <XMPPRoomDelegate>

@end

static RoomTool *instance;

@implementation RoomTool

+ (instancetype)sharedTool {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (NSMutableDictionary *)rooms {
    if (_rooms == nil) {
        _rooms = [NSMutableDictionary dictionary];
    }
    return _rooms;
}

- (void)joinOrCreateRoomWithJID:(XMPPJID *)jid {
    if (self.rooms[jid.bare] == nil) {
        XMPPRoom *room = [[XMPPRoom alloc] initWithRoomStorage:[XMPPRoomCoreDataStorage sharedInstance] jid:jid dispatchQueue:dispatch_get_global_queue(0, 0)];
        [room addDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
        [room activate:[XMPPTool sharedTool].stream];
        self.rooms[jid.bare] = room;
    }
    [self.rooms[jid.bare] joinRoomUsingNickname:@"aaa" history:nil];
}

- (void)xmppRoomDidJoin:(XMPPRoom *)sender {
    [sender configureRoomUsingOptions:nil];
    [sender inviteUser:[XMPPJID jidWithUser:@"bbb" domain:@"192.168.31.196" resource:nil] withMessage:@"aaa invites you to chat"];
    [sender inviteUser:[XMPPJID jidWithUser:@"ccc" domain:@"192.168.31.196" resource:nil] withMessage:@"aaa invites you to chat"];
}

@end
