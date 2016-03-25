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
     //self.canDisplayBannerAds = YES;
    if (IS_IPHONE)
    {
        //NSLog(@"\n iPhone");
        if (IS_IPHONE_4_OR_LESS)
        {
           // NSLog(@"\n iPhone_4");
            _rigisterBottomConstraint.constant=10;
            _logoBottomConstraint.constant=2;
        }
        else if (IS_IPHONE_5)
        {
           // NSLog(@"\n iPhone_5");
            _rigisterBottomConstraint.constant=30;
             _logoBottomConstraint.constant=30;
        }
        else if (IS_IPHONE_6)
        {
           // NSLog(@"\n iPhone_6");
            _rigisterBottomConstraint.constant=40;
             _logoBottomConstraint.constant=70;
        }
        else if (IS_IPHONE_6P)
        {
            //NSLog(@"\n iPhone_6 Plus");
            _rigisterBottomConstraint.constant=50;
             _logoBottomConstraint.constant=80;
        }

    } else {
        //NSLog(@"\n iPad");
    }
    
}
-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
    
    
       //Comment on Producation
    [_passwordInput setText:@"password"];
    [_userNameImput setText:@"dasaridineshbabu27@gmail.com"];
    
}

- (void)hide
{
    //NSLog(@"Hiding from login");
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
    
    NSString *deviceToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"device_token"];
    NSDictionary *infoDict;
    if (deviceToken != nil) {
       infoDict  = @{@"email" : _userNameImput.text,
                                    @"password" : _passwordInput.text,
                                    @"device_id":deviceToken
                                    };

    } else {
       infoDict  = @{@"email" : _userNameImput.text,
                                    @"password" : _passwordInput.text,
                                    };

    }
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
                 //NSLog(@"Login success! with info: %@", response);
                 
                 
//                 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                     [self getProfileImageWith:[response valueForKey:@"user_id"]];
//                 });
                 
                 
                 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                     // call the same method on a background thread
                      [self getProfileImageWith:[response valueForKey:@"user_id"]];
                     
                     dispatch_async(dispatch_get_main_queue(), ^{
                        // update UI on the main thread
                     });
                     
                 });
                 
                 User *currentUser = [User currentUser];
                 [currentUser saveUserDetails:response];
                 currentUser.password = _passwordInput.text;
                 _userNameImput.text = @"";
                 _passwordInput.text = @"";
                 
                ////Socket
                //[appDelegate initiateClientSocket];
                 
                 [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"isLoggedIn"];
                 [[NSUserDefaults standardUserDefaults]synchronize];
                 
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
-(void)getProfileImageWith:(NSString*)userID
{
    NSDictionary *infoDict  = @{@"user_id" : userID};
    //[appDelegate showLoaingWithTitle:@"Loading..."];
    
    [RSServices getProfileImageWithUserID:infoDict completionHandler:^(NSDictionary *response, NSError *error)
     {
         //[appDelegate hideLoading];
         NSString *alertMsg = nil;
         if (error != nil)
         {
             [RSUtils showAlertForError:error inView:self];
         }
         else if (response != nil)
         {
             if ([[response objectForKey:kResponseCode] intValue] == kRequestSuccess)
             {
                // NSLog(@"\n profile image success! with info: %@", response);
                
                 User *currentUser = [User currentUser];
//                 NSData* data = [[response valueForKey:@"profile_pic"] dataUsingEncoding:NSUTF8StringEncoding];
//                  NSLog(@"\n profile image success! with data: %@", data);
//                 currentUser.profilePic= [UIImage imageWithData: data];
                 
                 NSURL *url = [NSURL URLWithString:[response valueForKey:@"profile_pic"]];
                 NSData *imgData = [NSData dataWithContentsOfURL:url];
                 UIImage *img = [[UIImage alloc] initWithData:imgData];
                  currentUser.profilePic= img;
                
             }
             else
             {
               // NSLog(@"\n profile image success! with info: %@", [response objectForKey:kResponseMessage] );
             }
         }
         
         if (alertMsg.length != 0)
         {
              //NSLog(@"\n profile image Failure! with info: %@", alertMsg);
         }
     }];

}
- (void)registerDeviceForPush
{
    if ((appDelegate).deviceToken.length != 0)
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
