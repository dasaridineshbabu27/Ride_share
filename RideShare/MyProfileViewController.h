//
//  MyProfileViewController.h
//  RideShare
//
//  Created by Reddy on 07/01/16.
//  Copyright © 2016 Reddy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideNavigationController.h"

@interface MyProfileViewController : UIViewController <SlideNavigationControllerDelegate>
{
    
}
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editBtn;
- (IBAction)editButtonAction:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *mobileNoInput;
@property (weak, nonatomic) IBOutlet UITextField *vehicleTypeInput;
@property (weak, nonatomic) IBOutlet UITextField *regNoInput;
@property (weak, nonatomic) IBOutlet UITextField *firstNameInput;
@property (weak, nonatomic) IBOutlet UITextField *lastNameInput;
@property (weak, nonatomic) IBOutlet UITextField *emailInput;
@property (weak, nonatomic) IBOutlet UITextField *passwordInput;

- (IBAction)pickProfileImageAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnPickImage;

@end
