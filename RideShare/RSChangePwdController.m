//
//  RSChangePwdControllerViewController.m
//  RideShare
//
//  Created by Reddy on 20/01/16.
//  Copyright © 2016 Reddy. All rights reserved.
//

#import "RSChangePwdController.h"
#import "RSUtils.h"
#import "User.h"
#import "RSConstants.h"

@interface RSChangePwdController ()

@end

@implementation RSChangePwdController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)changePwdAction:(id)sender
{
    NSString *alertMsg = nil;
    
    if ([RSUtils trimWhiteSpaces:_currentPwdInput.text].length == 0 || [RSUtils trimWhiteSpaces:_pwdInput.text].length == 0 || [RSUtils trimWhiteSpaces:_confirmNewPwdInput.text].length == 0)
    {
        alertMsg = @"Fields must not be empty.";
    }
    else if (![[RSUtils trimWhiteSpaces:_pwdInput.text] isEqualToString:[RSUtils trimWhiteSpaces:_confirmNewPwdInput.text]])
    {
        alertMsg = @"New password and confirm passwords are mismatch.";
    }
    else if ([[RSUtils trimWhiteSpaces:_currentPwdInput.text] isEqualToString:[RSUtils trimWhiteSpaces:_pwdInput.text]])
    {
        alertMsg = @"Old password and New passwords must not be same.";
    }
    
    if (alertMsg.length)
    {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Change Password" message:alertMsg preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                       {
                                           
                                       }];
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
    }
    else
    {
        NSDictionary *infoDict = @{@"user_id" : [User currentUser].userId,
                                   @"old_password" : [RSUtils trimWhiteSpaces:_currentPwdInput.text],
                                   @"new_password": [RSUtils trimWhiteSpaces:_pwdInput.text],
                                   @"confirm_password" : [RSUtils trimWhiteSpaces:_confirmNewPwdInput.text]
                                       };
        
         [RSServices processChangePassword:infoDict completionHandler:^(NSDictionary * response, NSError *error) {
                 NSString *alertMsg = nil;
                 if (error != nil)
                 {
                     alertMsg = error.description;
                 }
                 else if (response != nil)
                 {
                     if ([[response objectForKey:kResponseCode] intValue] == kRequestSuccess)
                     {
                         NSLog(@"Password Changed with: %@", response);
                         [self.navigationController popViewControllerAnimated:YES];
                     }
                     else
                     {
                         UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Change Password" message:[response objectForKey:kResponseMessage] preferredStyle:UIAlertControllerStyleAlert];
                         
                         UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                         {
                          
                         }];
                         [alertController addAction:okAction];
                         [self presentViewController:alertController animated:YES completion:nil];
                         return;
                     }
                 }
         }];
    }
}

@end
