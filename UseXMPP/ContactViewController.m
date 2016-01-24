//
//  ContactViewController.m
//  UseXmpp
//
//  Created by zmx on 16/1/20.
//  Copyright © 2016年 zmx. All rights reserved.
//

#import "ContactViewController.h"
#import "ContactCell.h"
#import "XMPPTool.h"
#import "XMPPFramework.h"
#import "ChatViewController.h"

@interface ContactViewController () <XMPPRosterDelegate, XMPPStreamDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) XMPPTool *tool;

@property (nonatomic, strong) NSArray *contacts;

@end

@implementation ContactViewController

- (IBAction)add:(id)sender {
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"加好友" message:@"请输入对方的名字" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
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
    
    self.tableView.rowHeight = 80;
    
    [self.tool.roster addDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    [self.tool.roster fetchRoster];
    
    [self.tool.stream addDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
}

- (void)fetchUser {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSManagedObjectContext *context = self.tool.rosterCoreData.mainThreadManagedObjectContext;
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPUserCoreDataStorageObject" inManagedObjectContext:context];
        [request setEntity:entity];
        self.contacts = [context executeFetchRequest:request error:nil];
        [self.tableView reloadData];
    });
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return self.contacts.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactCell *cell = [tableView dequeueReusableCellWithIdentifier:@"contact"];
    cell.objc = self.contacts[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        XMPPUserCoreDataStorageObject *contact = self.contacts[indexPath.row];
        [self.tool.roster removeUser:contact.jid];
        [NSThread sleepForTimeInterval:0.1];
        [self fetchUser];
    }
}

- (void)xmppRosterDidEndPopulating:(XMPPRoster *)sender {
    [self fetchUser];
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence {
    if ([presence.type isEqualToString:@"subscribe"]) {
        [self.tool.roster acceptPresenceSubscriptionRequestFrom:presence.from andAddToRoster:YES];
        [NSThread sleepForTimeInterval:0.1];
        [self fetchUser];
    } else if ([presence.type isEqualToString:@"unsubscribe"]) {
        [self.tool.roster removeUser:presence.from];
        [NSThread sleepForTimeInterval:0.1];
        [self fetchUser];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        UITextField *textField = [alertView textFieldAtIndex:0];
        XMPPJID *jid = [XMPPJID jidWithUser:textField.text domain:@"192.168.31.196" resource:nil];
        [self.tool.roster addUser:jid withNickname:jid.user];
        [NSThread sleepForTimeInterval:0.1];
        [self fetchUser];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UITableViewCell *)sender {
    NSIndexPath *path = [self.tableView indexPathForCell:sender];
    XMPPUserCoreDataStorageObject *contact = self.contacts[path.row];
    ChatViewController *cvc = segue.destinationViewController;
    cvc.chatJID = contact.jid;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
