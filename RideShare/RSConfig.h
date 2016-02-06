//
//  RSConfig.h
//  RideShare
//
//  Created by Reddy on 19/01/16.
//  Copyright © 2016 Reddy. All rights reserved.
//

#ifndef RSConfig_h
#define RSConfig_h

// External
#define mainURL  @"http://202.153.46.238:8082/rides/controller/"

//#define mainURL  @"http://192.168.0.100:8082/rides/controller/"

#define urlRegistration [NSString stringWithFormat:@"%@%@",mainURL, @"registeration.php"]

#define urlLogin [NSString stringWithFormat:@"%@%@",mainURL, @"login.php"]

#define urlFAQs  [NSString stringWithFormat:@"%@%@",mainURL, @"faq.php"]

#define urlChangePassword [NSString stringWithFormat:@"%@%@",mainURL, @"changePassword.php"]

#define  urlUpdateProfile [NSString stringWithFormat:@"%@%@",mainURL, @"editProfile.php"]

#define  urlForgotPassword [NSString stringWithFormat:@"%@%@",mainURL, @"forgetpassword.php"]

#define  urlMyRideRequest [NSString stringWithFormat:@"%@%@",mainURL, @"myride.php"]

#define  urlPmuRequest [NSString stringWithFormat:@"%@%@",mainURL, @"pickup.php"]

#define  urlFetchHistory [NSString stringWithFormat:@"%@%@",mainURL, @"myridelist.php"]

#define  urlDeleteRequest [NSString stringWithFormat:@"%@%@",mainURL, @"deletemyride.php"]

#define urlFetchDefaultRides [NSString stringWithFormat:@"%@%@",mainURL, @"allrides.php"]

#define urlRegisterDeviceForPush  [NSString stringWithFormat:@"%@%@",mainURL, @"update_device.php"]

#define urlRequestViaPush  [NSString stringWithFormat:@"%@%@",mainURL, @"simplepush.php"]

#define urlRequestNotifications [NSString stringWithFormat:@"%@%@",mainURL, @"mynotifications.php"]

#define urlRequestAcceptRide [NSString stringWithFormat:@"%@%@",mainURL, @"accept_ride.php"]

#endif /* RSConfig_h */
