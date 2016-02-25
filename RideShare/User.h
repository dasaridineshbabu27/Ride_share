//
//  User.h
//  RideShare
//
//  Created by Reddy on 20/01/16.
//  Copyright © 2016 Reddy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface User : NSObject
{
    
}

// Declaring user properties
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *emailId;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *vehicleType;
@property (nonatomic, strong) NSString *gender;
@property (nonatomic, strong) NSString *regNumber;
@property (nonatomic, strong) NSString *mobileNo;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) UIImage *profilePic;

// Method that gives you the current user object;
+(User*)currentUser;

- (void)saveUserDetails:(NSDictionary*)infoDict;
@end
