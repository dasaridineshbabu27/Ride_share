//
//  RLRegistrationViewController.h
//  RideShare
//
//  Created by Reddy on 05/01/16.
//  Copyright © 2016 Reddy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RLRegistrationViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *confirmEmailInput;
@property (weak, nonatomic) IBOutlet UITextField *passwordInput;
@property (weak, nonatomic) IBOutlet UITextField *firstNameInput;
@property (weak, nonatomic) IBOutlet UITextField *lastNameInput;
@property (weak, nonatomic) IBOutlet UITextField *emailInput;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordInput;

- (IBAction)registerAction:(id)sender;
- (IBAction)cancelRegistration:(id)sender;

@end