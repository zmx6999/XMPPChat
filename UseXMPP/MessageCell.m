//
//  MessageCell.m
//  UseXmpp
//
//  Created by zmx on 16/1/21.
//  Copyright © 2016年 zmx. All rights reserved.
//

#import "MessageCell.h"

@implementation MessageCell

- (void)awakeFromNib {
    // Initialization code
    self.avatarView.layer.cornerRadius = 30;
    self.avatarView.layer.masksToBounds = YES;
}

@end
