//
//  OTPVerificationViewController.h
//  RideShare
//
//  Created by Dineshbabu on 14/03/16.
//  Copyright © 2016 Reddy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RSConstants.h"
#import "RSUtils.h"
#import "RSServices.h"
#import "AppDelegate.h"
@interface OTPVerificationViewController : UIViewController
@property (strong, nonatomic) IBOutlet UILabel *mobileNo;
@property (strong, nonatomic) IBOutlet UITextField *OTPField;
@property (strong, nonatomic) IBOutlet UIButton *verifyBtn;
@property (strong, nonatomic) IBOutlet UIButton *resendOTPBtn;
- (IBAction)verifyOTPAction:(id)sender;
- (IBAction)resendOTPAction:(id)sender;


//////
@property (strong, nonatomic) IBOutlet GADBannerView *googleAdBanner;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *googleAdbottomConstraint;

@end
