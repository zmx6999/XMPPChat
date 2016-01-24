//
//  GroupChatViewController.h
//  UseXmpp
//
//  Created by zmx on 16/1/21.
//  Copyright © 2016年 zmx. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XMPPJID;

@interface GroupChatViewController : UIViewController

@property (nonatomic, strong) XMPPJID *roomJID;

@end
