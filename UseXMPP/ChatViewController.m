//
//  ChatViewController.m
//  UseXmpp
//
//  Created by zmx on 16/1/21.
//  Copyright © 2016年 zmx. All rights reserved.
//

#import "ChatViewController.h"
#import "ChatCell.h"
#import "XMPPTool.h"
#import "XMPPFramework.h"
@interface ChatViewController () <XMPPStreamDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UITextField *textField;

@property (weak, nonatomic) IBOutlet UIView *sendView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

@property (nonatomic, strong) XMPPTool *tool;

@property (nonatomic, strong) NSArray *messages;

@end

@implementation ChatViewController

- (IBAction)send:(id)sender {
    [self.view endEditing:YES];
    XMPPMessage *message = [[XMPPMessage alloc] initWithName:@"message"];
    [message addAttributeWithName:@"to" stringValue:self.chatJID.bare];
    [message addAttributeWithName:@"type" stringValue:@"chat"];
    [message addBody:self.textField.text];
    [self.tool.stream sendElement:message];
    [NSThread sleepForTimeInterval:0.1];
    [self fetchMessage];
    self.textField.text = nil;
}

- (XMPPTool *)tool {
    if (_tool == nil) {
        _tool = [XMPPTool sharedTool];
    }
    return _tool;
}

- (void)changeKeyboardFrame:(NSNotification *)noti {
    CGFloat duration = [noti.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect rect = [(NSValue *)noti.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.bottomConstraint.constant = [UIScreen mainScreen].bounds.size.height - rect.origin.y;
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
    }];
    if (self.messages.count > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:self.messages.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.chatJID.user;
    
    self.tableView.estimatedRowHeight = 100;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeKeyboardFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    [self.tool.stream addDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    
    [self fetchMessage];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    self.tabBarController.tabBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    self.tabBarController.tabBar.hidden = NO;
}

- (void)fetchMessage {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSManagedObjectContext *context = self.tool.messageArchivingCoreData.mainThreadManagedObjectContext;
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"XMPPMessageArchiving_Message_CoreDataObject"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bareJidStr = %@", self.chatJID.bare];
        request.predicate = predicate;
        NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
        request.sortDescriptors = @[descriptor];
        self.messages = [context executeFetchRequest:request error:nil];
        [self.tableView reloadData];
        if (self.messages.count > 0) {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:self.messages.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
    });
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return self.messages.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XMPPMessageArchiving_Message_CoreDataObject *message = self.messages[indexPath.row];
    NSString *ID = message.isOutgoing ?@"me" : @"other";
    ChatCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    cell.avatarView.image = [UIImage imageWithData:[self.tool.cardAvatarModule photoDataForJID:message.isOutgoing ?self.tool.stream.myJID : self.chatJID]];
    cell.messageLabel.text = message.body;
    cell.usernameLabel.text = self.chatJID.user;
    return cell;
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
    [NSThread sleepForTimeInterval:0.1];
    [self fetchMessage];
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
