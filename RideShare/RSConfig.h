//
//  RSConfig.h
//  RideShare
//
//  Created by Reddy on 19/01/16.
//  Copyright © 2016 Reddy. All rights reserved.
//

#ifndef RSConfig_h
#define RSConfig_h

#define mainURL  @"http://192.168.0.100:8082/rides/controller/"

#define urlRegistration [NSString stringWithFormat:@"%@%@",mainURL, @"registeration.php"]

#define urlLogin [NSString stringWithFormat:@"%@%@",mainURL, @"login.php"]

#define urlFAQs  [NSString stringWithFormat:@"%@%@",mainURL, @"faq.php"]

#define urlChangePassword [NSString stringWithFormat:@"%@%@",mainURL, @"changePassword.php"]
#endif /* RSConfig_h */
