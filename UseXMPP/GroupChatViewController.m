//
//  GroupChatViewController.m
//  UseXmpp
//
//  Created by zmx on 16/1/21.
//  Copyright © 2016年 zmx. All rights reserved.
//

#import "GroupChatViewController.h"
#import "ChatCell.h"
#import "XMPPFramework.h"
#import "XMPPTool.h"
#import "RoomTool.h"

@interface GroupChatViewController () <UITableViewDataSource, XMPPStreamDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIView *sendView;

@property (weak, nonatomic) IBOutlet UITextField *textField;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

@property (nonatomic, strong) XMPPTool *tool;

@property (nonatomic, strong) NSArray *messages;

@property (nonatomic, strong) NSMutableDictionary *realJIDs;

@end

@implementation GroupChatViewController

- (IBAction)send:(id)sender {
    [self.view endEditing:YES];
    XMPPMessage *message = [[XMPPMessage alloc] initWithName:@"message"];
    [message addAttributeWithName:@"to" stringValue:self.roomJID.bare];
    [message addAttributeWithName:@"type" stringValue:@"groupchat"];
    [message addBody:self.textField.text];
    [self.tool.stream sendElement:message];
    [NSThread sleepForTimeInterval:0.1];
    [self fetchMessage];
    self.textField.text = nil;
}

- (NSMutableDictionary *)realJIDs {
    if (_realJIDs == nil) {
        _realJIDs = [NSMutableDictionary dictionary];
    }
    return _realJIDs;
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
    // Do any additional setup after loading the view.
    self.title = self.roomJID.user;
    
    self.tableView.estimatedRowHeight = 100;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeKeyboardFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    [[RoomTool sharedTool] joinOrCreateRoomWithJID:self.roomJID];
    
    [self fetchReadJID];
    
    [self fetchMessage];
    
    [self.tool.stream addDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
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

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
    [NSThread sleepForTimeInterval:0.1];
    [self fetchMessage];
}

- (void)fetchReadJID {
    NSManagedObjectContext *context = self.tool.roomCoreDataStorage.mainThreadManagedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"XMPPRoomOccupantCoreDataStorageObject"];
    NSArray *occupants = [context executeFetchRequest:request error:nil];
    for (XMPPRoomOccupantCoreDataStorageObject *occupant in occupants) {
        self.realJIDs[occupant.jidStr] = occupant.realJID;
    }
}

- (void)fetchMessage {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSManagedObjectContext *context = self.tool.roomCoreDataStorage.mainThreadManagedObjectContext;
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"XMPPRoomMessageCoreDataStorageObject"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"roomJIDStr = %@", self.roomJID.bare];
        request.predicate = predicate;
        NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"localTimestamp" ascending:YES];
        request.sortDescriptors = @[descriptor];
        self.messages = [context executeFetchRequest:request error:nil];
        [self.tableView reloadData];
        if (self.messages.count > 0) {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:self.messages.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
    });
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XMPPRoomMessageCoreDataStorageObject *message = self.messages[indexPath.row];
    NSString *ID = message.isFromMe ?@"me" : @"other";
    ChatCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    XMPPJID *realJID = self.realJIDs[message.jidStr];
    cell.avatarView.image = [UIImage imageWithData:[self.tool.cardAvatarModule photoDataForJID:realJID]];
    cell.messageLabel.text = message.message.body;
    cell.usernameLabel.text = realJID.user;
    return cell;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
