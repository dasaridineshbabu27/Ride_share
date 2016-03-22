//
//  RSChangePwdControllerViewController.h
//  RideShare
//
//  Created by Reddy on 20/01/16.
//  Copyright © 2016 Reddy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RSServices.h"
#import "AppDelegate.h"
@interface RSChangePwdController : UIViewController
{
    RSServices *Services;    
}

@property (weak, nonatomic) IBOutlet UITextField *pwdInput;

@property (weak, nonatomic) IBOutlet UITextField *currentPwdInput;

@property (weak, nonatomic) IBOutlet UITextField *confirmNewPwdInput;
- (IBAction)changePwdAction:(id)sender;

@end
