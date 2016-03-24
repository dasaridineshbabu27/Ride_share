//
//  OTPVerificationViewController.m
//  RideShare
//
//  Created by Dineshbabu on 14/03/16.
//  Copyright © 2016 Reddy. All rights reserved.
//

#import "OTPVerificationViewController.h"
#import "User.h"
@interface OTPVerificationViewController ()

@property User *currentUser;
@end

@implementation OTPVerificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //self.canDisplayBannerAds = YES;
    // Do any additional setup after loading the view.
    
      _currentUser = [User currentUser];
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.title=@"OTP Verification";
    
    ////Ads
    (appDelegate).googleAdIsVisible=NO;
    [self updateUserInterface:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateUserInterface:)
                                                 name:@"updateUserInterface" object:nil];
}
-(void)integrateAds
{
    //iAds Implementation
    //[appDelegate iAdIntegration];
    //[appDelegate iAdIntegrationwith:<#(ADBannerView *)#> andviewController:self];
    
    
    //Google Ads Implementation
    //[appDelegate googleAdsIntegration];
    [appDelegate googleAdsIntegrationWith:self.googleAdBanner andviewController:self];
    
    //LARSAd Implementation
    //[[LARSAdController sharedManager] addAdContainerToView:self.view withParentViewController:self];
    //[[LARSAdController sharedManager] addAdContainerToViewInViewController:self];
    
}
-(void)updateUserInterface:(NSNotification *)notification
{
    if ((appDelegate).googleAdIsVisible)
    {
        _googleAdBanner.hidden=NO;
        _googleAdbottomConstraint.constant=0;
    }
    else
    {
        _googleAdBanner.hidden=YES;
        _googleAdbottomConstraint.constant=-50;
    }
    [self.view layoutIfNeeded];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated
{
    [self integrateAds];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateUserInterface" object:nil];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)verifyOTPAction:(id)sender {
    
    if (_OTPField.text.length !=0)
    {
        [appDelegate showLoaingWithTitle:nil];
        [RSServices processVerifyOTP:@{@"userid" : _currentUser.userId, @"otp":_OTPField.text} completionHandler:^(NSDictionary * response, NSError * error)
         {
             [appDelegate hideLoading];
             NSString *alertMsg = nil;
             if (error != nil)
             {
                 alertMsg = error.description;
             }
             else if (response != nil)
             {
                 if ([[response objectForKey:kResponseCode] intValue] == kRequestSuccess)
                 {
                     //NSLog(@"OTP Verification success! with info: %@", response);
                     
                     UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                                {
                                                    //[self.navigationController popViewControllerAnimated:YES];
                                                }];
                     [RSUtils showAlertWithTitle:@"OTP Verification" message:@"Mobile Number Verified Successfully" actionOne:okAction actionTwo:nil inView:self];
                 }
                 else
                 {
                     UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                     
                     [RSUtils showAlertWithTitle:@"OTP Verification" message:[response objectForKey:kResponseMessage] actionOne:okAction actionTwo:nil inView:self];
                     return;
                 }
             }
             if (alertMsg.length != 0)
             {
                 [RSUtils showAlertWithTitle:@"OTP Verification" message:alertMsg actionOne:nil actionTwo:nil inView:self];
             }
         }];
    }
    else
    {
        [RSUtils showAlertWithTitle:@"OTP Verification" message:@"Please enter OTP" actionOne:nil actionTwo:nil inView:self];
    }
}


- (IBAction)resendOTPAction:(id)sender {
    
    [appDelegate showLoaingWithTitle:nil];
    [RSServices processResendOTPforUserID:@{@"userid" : _currentUser.userId} completionHandler:^(NSDictionary * response, NSError * error)
     {
         [appDelegate hideLoading];
         NSString *alertMsg = nil;
         if (error != nil)
         {
             alertMsg = error.description;
         }
         else if (response != nil)
         {
             if ([[response objectForKey:kResponseCode] intValue] == kRequestSuccess)
             {
                 //NSLog(@"OTP Verification success! with info: %@", response);
                 
                 UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                            {
                                                //[self.navigationController popViewControllerAnimated:YES];
                                            }];
                 [RSUtils showAlertWithTitle:@"Resend OTP" message:@"New OPT code sent successfully" actionOne:okAction actionTwo:nil inView:self];
             }
             else
             {
                 UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                 
                 [RSUtils showAlertWithTitle:@"Resend OTP" message:[response objectForKey:kResponseMessage] actionOne:okAction actionTwo:nil inView:self];
                 return;
             }
         }
         if (alertMsg.length != 0)
         {
             [RSUtils showAlertWithTitle:@"Resend OTP" message:alertMsg actionOne:nil actionTwo:nil inView:self];
         }
     }];

}
@end
