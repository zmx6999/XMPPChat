//
//  ViewController.m
//  UseXmpp
//
//  Created by zmx on 16/1/19.
//  Copyright © 2016年 zmx. All rights reserved.
//

#import "ViewController.h"
#import "XMPPTool.h"
#import "XMPPFramework.h"
#import "MessageCell.h"
#import "RoomTool.h"
#import "GroupChatViewController.h"
#import "ChatViewController.h"

@interface ViewController () <XMPPStreamDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) XMPPTool *tool;

@property (nonatomic, strong) NSArray *messages;

@end

@implementation ViewController

- (IBAction)joinChatGroup:(id)sender {
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"友情提示" message:@"请输入聊天室的名称" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    av.alertViewStyle = UIAlertViewStylePlainTextInput;
    [av show];
}

- (XMPPTool *)tool {
    if (_tool == nil) {
        _tool = [XMPPTool sharedTool];
    }
    return _tool;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.tableView.rowHeight = 80;
    
    [self fetchMessage];
    [self.tool.stream addDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
    [NSThread sleepForTimeInterval:0.1];
    [self fetchMessage];
}

- (void)fetchMessage {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSManagedObjectContext *context = self.tool.messageArchivingCoreData.mainThreadManagedObjectContext;
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"XMPPMessageArchiving_Contact_CoreDataObject"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@", self.tool.stream.myJID.bare];
        request.predicate = predicate;
        NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"mostRecentMessageTimestamp" ascending:NO];
        request.sortDescriptors = @[descriptor];
        self.messages = [context executeFetchRequest:request error:nil];
        [self.tableView reloadData];
    });
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(XMPPMessageArchiving_Contact_CoreDataObject *)sender {
    if ([sender.bareJid.domain isEqualToString:@"192.168.31.196"]) {
        ChatViewController *cvc = segue.destinationViewController;
        cvc.chatJID = sender.bareJid;
    } else {
        GroupChatViewController *gvc = segue.destinationViewController;
        gvc.roomJID = sender.bareJid;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        UITextField *textField = [alertView textFieldAtIndex:0];
        XMPPJID *jid = [XMPPJID jidWithUser:textField.text domain:@"conference.192.168.31.196" resource:nil];
        [[RoomTool sharedTool] joinOrCreateRoomWithJID:jid];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XMPPMessageArchiving_Contact_CoreDataObject *message = self.messages[indexPath.row];
    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"message"];
    cell.avatarView.image = [UIImage imageWithData:[self.tool.cardAvatarModule photoDataForJID:message.bareJid]];
    cell.nameLabel.text = message.bareJidStr;
    cell.messageLabel.text = message.mostRecentMessageBody;
    NSDate *date = message.mostRecentMessageTimestamp;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"HH:mm:ss";
    cell.timLabel.text = [formatter stringFromDate:date];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    XMPPMessageArchiving_Contact_CoreDataObject *message = self.messages[indexPath.row];
    if ([message.bareJid.domain isEqualToString:@"192.168.31.196"]) {
        [self performSegueWithIdentifier:@"chat" sender:message];
    } else {
        [self performSegueWithIdentifier:@"group" sender:message];
    }
}

@end
