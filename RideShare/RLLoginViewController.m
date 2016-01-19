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

@implementation RLLoginViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    
    void (^simpleBlock)(int) = ^(int a)
    {
        NSLog(@"This is a block: %i", a);
    };
    
    simpleBlock(10);
    
    int (^sumBlock)(int, int) = ^(int a, int b){
        return a+b;
    };
    
    int sum = sumBlock(10,29);
    
    NSLog(@"sum is : %i",sum );
    
    
    void (^ablock)(int) = ^(int a){
        NSLog(@"Block called from method");
    };
    
    [self methodWithInt:10 completionHandler:ablock];
    
    // Do any additional setup after loading the view, typically from a nib.
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
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Login" message:alertMsg preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
        }];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }

    
    NSDictionary *infoDict  = @{@"email" : _userNameImput.text,
                                @"password" : _passwordInput.text
                                };
    [RSServices processLogin:infoDict completionHandler:^(NSData *response, NSError *error)
     {
         if (error)
         {
             NSLog(@"Error is : %@",error);
         }
         else
         {
             NSLog(@"Login success");
             [self dismissViewControllerAnimated:YES completion:nil];
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
