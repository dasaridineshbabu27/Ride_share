//
//  RLLoginViewController.m
//  RideShare
//
//  Created by Reddy on 05/01/16.
//  Copyright © 2016 Reddy. All rights reserved.
//

#import "RLLoginViewController.h"
#import "AppDelegate.h"
#import "RSConstants.h"
#import "RSUtils.h"
#import "RSServices.h"
#import "User.h"

@implementation RLLoginViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([RSUtils isNetworkReachable])
    {
        NSLog(@"Reachable");
    }
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)viewWillAppear:(BOOL)animated
{
//    self.navigationController.navigationBarHidden = YES;

    if ([RSUtils isNetworkReachable]) {
        NSLog(@"Reachable");
    }
}

- (void)hide
{
    NSLog(@"Hiding from login");
    [RSUtils showAlertWithTitle:@"Title" message:@"Message" actionOne:nil actionTwo:nil inView:self];
}

- (void)methodWithInt:(int)a completionHandler:(void(^)(int)) aBlock
{
    aBlock(10);
}


- (void)methodWithFloat:(float)a completionHandler:(void(^)(int)) aBlock
{
    aBlock(10);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginAction:(id)sender
{
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    delegate.isUserLoggedIn = YES;
    [_passwordInput resignFirstResponder];
    [_userNameImput resignFirstResponder];
    
    NSString *alertMsg = nil;
    if ([RSUtils trimWhiteSpaces:_userNameImput.text].length == 0 || ![RSUtils isValidEmail:_userNameImput.text])
    {
        alertMsg = @"Please enter a valid Username.";
    }
    else if ([RSUtils trimWhiteSpaces:_passwordInput.text].length == 0)
    {
        alertMsg = @"Please enter password";
    }
    if (alertMsg)
    {
        [RSUtils showAlertWithTitle:@"Login" message:alertMsg actionOne:nil actionTwo:nil inView:self];
        return;
    }
    
    NSDictionary *infoDict  = @{@"email" : _userNameImput.text,
                                @"password" : _passwordInput.text
                                };
    [appDelegate showLoaingWithTitle:@"Loading..."];
    [RSServices processLogin:infoDict completionHandler:^(NSDictionary *response, NSError *error)
     {
         [appDelegate hideLoading];
         NSString *alertMsg = nil;
         if (error != nil)
         {
             [RSUtils showAlertForError:error inView:self];
         }
         else if (response != nil)
         {
             if ([[response objectForKey:kResponseCode] intValue] == kRequestSuccess)
             {
                 NSLog(@"Login success! with info: %@", response);
                 User *currentUser = [User currentUser];
                 [currentUser saveUserDetails:response];
                 _userNameImput.text = @"";
                 _passwordInput.text = @"";
                 [self performSegueWithIdentifier:@"ShowHomeViewSegue" sender:self];
             }
             else
             {
                 UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Login" message:[response objectForKey:kResponseMessage] preferredStyle:UIAlertControllerStyleAlert];
                 
                 UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                            {
                                                [self.navigationController popViewControllerAnimated:YES];
                                            }];
                 [alertController addAction:okAction];
                 [self presentViewController:alertController animated:YES completion:nil];
                 return;
             }
         }
         
         if (alertMsg.length != 0)
         {
             [RSUtils showAlertWithTitle:@"Regisrtation" message:alertMsg actionOne:nil actionTwo:nil inView:self];
         }
     }];
}

- (void)registerDeviceForPush
{
    [RSServices processRegisterDeviceForPush:@{@"deviceToekn" :     (appDelegate).deviceToken} completionHandler:^(NSDictionary *response, NSError *error) {
        if (error == nil)
        {
            NSLog(@" Registered device with device token : %@", (appDelegate).deviceToken);
        }
        else
        {
            NSLog(@"Failed to register the device for push: %@", error);
        }
    }];
}

- (IBAction)rememberMeAction:(UIButton*)sender
{
    if (sender.selected == YES)
    {
        sender.selected = NO;
    }
    else
    {
        sender.selected = YES;
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [_userNameImput resignFirstResponder];
    [_passwordInput resignFirstResponder];
}

@end
