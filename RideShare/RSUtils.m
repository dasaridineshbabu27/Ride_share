//
//  RSUtils.m
//  RideShare
//
//  Created by Reddy on 13/01/16.
//  Copyright © 2016 Reddy. All rights reserved.
//

#import "RSUtils.h"
#import "Reachability.h"

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

+ (void)showAlertWithTitle:(NSString*)title message:(NSString*)messge actionOne:(UIAlertAction*)actionOne actionTwo:(UIAlertAction*)actionTwo inView:(UIViewController*)controller
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:messge preferredStyle:UIAlertControllerStyleAlert];
    
    if (actionOne)
    {
        [alertController addAction:actionOne];
    }
    
    if (actionTwo) {
        [alertController addAction:actionTwo];
    }
    else if (actionOne == nil && actionTwo == nil)
    {
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:alertAction];
    }
    
    [controller presentViewController:alertController animated:YES completion:nil];
}

+ (void)showAlertForError:(NSError*)error inView:(UIViewController*)controller
{
    NSString *alertMsg = nil;
    switch (error.code) {
        case -1001:
            alertMsg = @"Request Timeout.";
            break;
        case -1009:
            alertMsg = @"Network Error";
        default:
            alertMsg = [NSString stringWithFormat:@"Put proper error message for : %@", error.localizedDescription];
            break;
    }
    
    [self showAlertWithTitle:@"Error" message:alertMsg actionOne:nil actionTwo:nil inView:controller];
}

+ (BOOL)isNetworkReachable
{
    CFNetDiagnosticRef dReference;
    dReference = CFNetDiagnosticCreateWithURL (NULL, (__bridge CFURLRef)[NSURL URLWithString:@""]);
    
    CFNetDiagnosticStatus status;
    status = CFNetDiagnosticCopyNetworkStatusPassively (dReference, NULL);
    
    CFRelease (dReference);
    
    if ( status == kCFNetDiagnosticConnectionUp )
    {
        NSLog (@"Connection is Available");
        return YES;
    }
    else
    {
        NSLog (@"Connection is down");
        return NO;
    }
}


+(NSDate *) toLocalTime:(NSDate*)date
{
    NSTimeZone *tz = [NSTimeZone localTimeZone];
    NSInteger seconds = [tz secondsFromGMTForDate:date];
    return [NSDate dateWithTimeInterval: seconds sinceDate: date];
}

+(NSDate *) toGlobalTime:(NSDate*)date
{
    return date;
    NSTimeZone *tz = [NSTimeZone defaultTimeZone];
    NSInteger seconds = -[tz secondsFromGMTForDate: date];
    return [NSDate dateWithTimeInterval: seconds sinceDate: date];
}

+ (NSString*)getDateStringFormDate:(NSDate*)date withFormat:(NSString*)format
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setDateFormat:@"dd:MM:YYYY HH:mm"];
    NSLog(@"%@", [dateFormatter stringFromDate:date]);
    return [dateFormatter stringFromDate:date];
}

+ (NSDate*)getDateFormDateString:(NSString*)dateString withFormat:(NSString*)format
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setDateFormat:@"dd:MM:YYYY HH:mm"];
    NSLog(@"%@", [dateFormatter dateFromString:dateString]);
    return [dateFormatter dateFromString:dateString];
}

+ (NSDate*)getDateFromDate:(NSDate*)inDate forFormat:(NSString*)format
{
        return nil;
}

+ (NSString*)getDateString:(NSString*)dateString forFormat:(NSString*)format
{
    return @"";
}

+(NSString*)getDisplayDate:(NSString*)dateString
{
    NSDateFormatter *dateFormatte = [NSDateFormatter new];
    dateFormatte.dateStyle = NSDateFormatterMediumStyle;
    dateFormatte.timeStyle = NSDateFormatterShortStyle;
    [dateFormatte setDateFormat:@"dd:MM:YYYY HH:mm"];
    NSDate *date = [dateFormatte dateFromString:@"01:02:2016 17:05"];
    dateFormatte.dateStyle = NSDateFormatterMediumStyle;
    dateFormatte.timeStyle = NSDateFormatterShortStyle;
    NSLog(@"%@", [dateFormatte stringFromDate:date]);
    return [dateFormatte stringFromDate:date];
}

@end
