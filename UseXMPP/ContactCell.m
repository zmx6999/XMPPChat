//
//  ContactCell.m
//  UseXmpp
//
//  Created by zmx on 16/1/20.
//  Copyright © 2016年 zmx. All rights reserved.
//

#import "ContactCell.h"
#import "XMPPTool.h"
#import "XMPPFramework.h"

@interface ContactCell ()

@property (weak, nonatomic) IBOutlet UIImageView *iv;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation ContactCell

- (void)setObjc:(XMPPUserCoreDataStorageObject *)objc {
    _objc = objc;
    
    self.iv.image = [UIImage imageWithData:[[XMPPTool sharedTool].cardAvatarModule photoDataForJID:objc.jid]];
    self.titleLabel.text = objc.jidStr;
}

- (void)awakeFromNib {
    // Initialization code
    self.iv.layer.cornerRadius = 30;
    self.iv.layer.masksToBounds = YES;
}

@end
