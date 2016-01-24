//
//  ChatViewController.h
//  UseXmpp
//
//  Created by zmx on 16/1/21.
//  Copyright © 2016年 zmx. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XMPPJID;

@interface ChatViewController : UIViewController

@property (nonatomic, strong) XMPPJID *chatJID;

@end
