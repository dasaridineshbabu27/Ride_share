//
//  RLRegistrationViewController.h
//  RideShare
//
//  Created by Reddy on 05/01/16.
//  Copyright © 2016 Reddy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RSUtils.h"

@interface RLRegistrationViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *btnFemale;

@property (weak, nonatomic) IBOutlet UIButton *btnMale;
@property (weak, nonatomic) IBOutlet UITextField *mobileNoInput;
@property (weak, nonatomic) IBOutlet UITextField *vehicleTypeInput;
@property (weak, nonatomic) IBOutlet UITextField *regNoInput;
@property (weak, nonatomic) IBOutlet UITextField *confirmEmailInput;
@property (weak, nonatomic) IBOutlet UITextField *passwordInput;
@property (weak, nonatomic) IBOutlet UITextField *firstNameInput;
@property (weak, nonatomic) IBOutlet UITextField *lastNameInput;
@property (weak, nonatomic) IBOutlet UITextField *emailInput;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordInput;
- (IBAction)pickProfileImageAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnPickImage;

- (IBAction)registerAction:(id)sender;
- (IBAction)cancelRegistration:(id)sender;

@end