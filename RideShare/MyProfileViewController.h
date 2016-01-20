//
//  MyProfileViewController.h
//  RideShare
//
//  Created by Reddy on 07/01/16.
//  Copyright © 2016 Reddy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyProfileViewController : UIViewController
{
    
}

@property (weak, nonatomic) IBOutlet UITextField *mobileNoInput;
@property (weak, nonatomic) IBOutlet UITextField *vehicleTypeInput;
@property (weak, nonatomic) IBOutlet UITextField *regNoInput;
@property (weak, nonatomic) IBOutlet UITextField *firstNameInput;
@property (weak, nonatomic) IBOutlet UITextField *lastNameInput;
@property (weak, nonatomic) IBOutlet UITextField *emailInput;

- (IBAction)pickProfileImageAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnPickImage;

@end
