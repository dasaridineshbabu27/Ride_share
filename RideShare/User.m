//
//  User.m
//  RideShare
//
//  Created by Reddy on 20/01/16.
//  Copyright © 2016 Reddy. All rights reserved.
//

#import "User.h"

@implementation User
+(User*)currentUser
{
    static User *currentUser = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        currentUser = [[self alloc] init];
    });    
    return currentUser;
}

- (void)saveUserDetails:(NSDictionary*)infoDict
{
    self.firstName = [infoDict valueForKey:@"First name"];
    self.lastName = [infoDict valueForKey:@"Last name"];
//    self.password = [infoDict valueForKey:@""];
    self.mobileNo = [infoDict valueForKey:@"Mobile Number"];
    self.gender = [infoDict valueForKey:@"Gender"];
    self.emailId = [infoDict valueForKey:@"Email"];
    self.vehicleType = [infoDict valueForKey:@"Vehicle_type"];
    self.regNumber = [infoDict valueForKey:@"Registration Number"];
    self.userId = [infoDict valueForKey:@"user_id"];
    
    NSLog(@"USer details to save is : %@", infoDict);
}

@end
