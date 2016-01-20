//
//  RSUtils.m
//  RideShare
//
//  Created by Reddy on 13/01/16.
//  Copyright © 2016 Reddy. All rights reserved.
//

#import "RSUtils.h"
@implementation RSUtils
// Method to remove all whitespaces from the beginning of the string.
+ (NSString*)trimWhiteSpaces:(NSString*)inputString
{
    return [inputString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

+(BOOL)isValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

+ (void)showAlertWithTitle:(NSString*)title message:(NSString*)messge action:(NSString*)action inView:(UIViewController*)controller
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:messge preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:action style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:alertAction];
    [controller presentViewController:alertController animated:YES completion:nil];
}

@end
