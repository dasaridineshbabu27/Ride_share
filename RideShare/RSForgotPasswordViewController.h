//
//  RSForgotPasswordViewController.h
//  RideShare
//
//  Created by Reddy on 22/01/16.
//  Copyright © 2016 Reddy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
@interface RSForgotPasswordViewController : UIViewController
{
    
}
@property (weak, nonatomic) IBOutlet UITextField *emailInput;
- (IBAction)submitAction:(id)sender;

@end
