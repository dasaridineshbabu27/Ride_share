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
{
    
}
+(NSString*)trimWhiteSpaces:(NSString*)inputString;

+(BOOL)isValidEmail:(NSString *)checkString;

+ (void)showAlertWithTitle:(NSString*)title message:(NSString*)messge actionOne:(UIAlertAction*)actionOne actionTwo:(UIAlertAction*)actionTwo inView:(UIViewController*)controller;

// Shows generic error message for corresponding error code.
+ (void)showAlertForError:(NSError*)error inView:(UIViewController*)controller;

+ (BOOL)isNetworkReachable;

+(NSDate *) toLocalTime:(NSDate*)date;

+(NSDate *) toGlobalTime:(NSDate*)date;

+ (NSString*)getDateStringFormDate:(NSDate*)date withFormat:(NSString*)format;

+ (NSDate*)getDateFormDateString:(NSString*)dateString withFormat:(NSString*)format;

+ (NSDate*)getDateFromDate:(NSDate*)inDate forFormat:(NSString*)format;

+ (NSString*)getDateString:(NSString*)dateString forFormat:(NSString*)format;

+(NSString*)getDisplayDate:(NSString*)dateString;

@end
