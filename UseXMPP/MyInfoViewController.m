//
//  MyInfoViewController.m
//  UseXmpp
//
//  Created by zmx on 16/1/20.
//  Copyright © 2016年 zmx. All rights reserved.
//

#import "MyInfoViewController.h"
#import "XMPPTool.h"
#import "XMPPFramework.h"
#import "EditInfoViewController.h"

@interface MyInfoViewController () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *avatarView;

@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;

@property (weak, nonatomic) IBOutlet UILabel *jidLabel;

@property (weak, nonatomic) IBOutlet UILabel *desLabel;

@end

@implementation MyInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.avatarView.layer.cornerRadius = 30;
    self.avatarView.layer.masksToBounds = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    XMPPvCardTemp *tmp = [XMPPTool sharedTool].cardTempModule.myvCardTemp;
    self.avatarView.image = [UIImage imageWithData:tmp.photo];
    self.nicknameLabel.text = tmp.nickname;
    self.jidLabel.text = [XMPPTool sharedTool].stream.myJID.bare;
    self.desLabel.text = tmp.desc;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UITableViewCell *)sender {
    EditInfoViewController *evc = segue.destinationViewController;
    evc.oldStr = ((UILabel *)[sender viewWithTag:100]).text;
    evc.identifier = sender.reuseIdentifier;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"修改头像" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"从相册选择", nil];
        [actionSheet showInView:self.view];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0: {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            picker.delegate = self;
            [self presentViewController:picker animated:YES completion:nil];
            
            break;
        }
            
        case 1: {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            picker.delegate = self;
            [self presentViewController:picker animated:YES completion:nil];
            
            break;
        }
            
        default:
            break;
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary<NSString *,id> *)editingInfo {
    [picker dismissViewControllerAnimated:YES completion:nil];
    self.avatarView.image = image;
    XMPPvCardTemp *tmp = [XMPPTool sharedTool].cardTempModule.myvCardTemp;
    tmp.photo = UIImageJPEGRepresentation(image, 0.1);
    [[XMPPTool sharedTool].cardTempModule updateMyvCardTemp:tmp];
}

@end
