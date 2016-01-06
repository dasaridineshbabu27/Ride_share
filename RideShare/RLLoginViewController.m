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

@implementation RLLoginViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginAction:(id)sender
{
//    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:keyIsUserLoggedIn];    
    [self dismissViewControllerAnimated:YES completion:nil];
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
