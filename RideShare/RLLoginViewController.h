//
//  RLLoginViewController.h
//  RideShare
//
//  Created by Reddy on 05/01/16.
//  Copyright © 2016 Reddy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface RLLoginViewController : UIViewController
{

}
- (IBAction)loginAction:(id)sender;
- (IBAction)rememberMeAction:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *userNameImput;
@property (weak, nonatomic) IBOutlet UITextField *passwordInput;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rigisterBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoBottomConstraint;
- (IBAction)genderToggleAction:(UIButton*)sender;
@end
