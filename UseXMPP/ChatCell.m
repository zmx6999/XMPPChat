//
//  ChatCell.m
//  UseXmpp
//
//  Created by zmx on 16/1/21.
//  Copyright © 2016年 zmx. All rights reserved.
//

#import "ChatCell.h"

@implementation ChatCell

- (void)awakeFromNib {
    // Initialization code
    self.avatarView.layer.cornerRadius = 25;
    self.avatarView.layer.masksToBounds = YES;
}

@end