//
//  RoomTool.h
//  UseXmpp
//
//  Created by zmx on 16/1/20.
//  Copyright © 2016年 zmx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPFramework.h"

@interface RoomTool : NSObject

@property (nonatomic, strong) NSMutableDictionary *rooms;

+ (instancetype)sharedTool;

- (void)joinOrCreateRoomWithJID:(XMPPJID *)jid;

@end
