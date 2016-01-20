//
//  RSUtils.h
//  RideShare
//
//  Created by Reddy on 13/01/16.
//  Copyright © 2016 Reddy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface RSUtils : NSObject

+(NSString*)trimWhiteSpaces:(NSString*)inputString;
+(BOOL)isValidEmail:(NSString *)checkString;
+ (void)showAlertWithTitle:(NSString*)title message:(NSString*)messge action:(NSString*)action inView:(UIViewController*)controller;
@end
