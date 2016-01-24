//
//  EditViewController.m
//  UseXMPP
//
//  Created by zmx on 16/1/22.
//  Copyright © 2016年 zmx. All rights reserved.
//

#import "EditViewController.h"

@interface EditViewController ()

@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation EditViewController

- (IBAction)cancel:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)save:(id)sender {
    [self.view endEditing:YES];
    if ([self.attr isEqualToString:@"nickname"]) {
        XMPPvCardTemp *cardTemp = XMPPShareTool.cardTempModule.myvCardTemp;
        cardTemp.nickname = self.textField.text;
        [XMPPShareTool.cardTempModule updateMyvCardTemp:cardTemp];
    } else {
        XMPPvCardTemp *cardTemp = XMPPShareTool.cardTempModule.myvCardTemp;
        cardTemp.desc = self.textField.text;
        [XMPPShareTool.cardTempModule updateMyvCardTemp:cardTemp];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.textField.text = self.oldStr;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
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
