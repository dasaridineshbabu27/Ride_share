//
//  RSConfig.h
//  RideShare
//
//  Created by Reddy on 19/01/16.
//  Copyright © 2016 Reddy. All rights reserved.
//

#ifndef RSConfig_h
#define RSConfig_h

#define baseURL  @"http://192.168.0.100:8082/rides/controller/"


#define urlRegistration [NSString stringWithFormat:@"%@%@",baseURL, @"registeration.php"]

#define urlLogin [NSString stringWithFormat:@"%@%@",baseURL, @"login.php"]


#endif /* RSConfig_h */
