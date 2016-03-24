//
//  RSConstants.m
//  RideShare
//
//  Created by Reddy on 06/01/16.
//  Copyright © 2016 Reddy. All rights reserved.
//

#define GoogleMapsAPIKey @"AIzaSyCf3EGm2PxKWUfiFlz2uFHlM7M3b9Pj7fE"
#define publisherIdd @"pub-9958110825614857"
#define AdUnitId @"ca-app-pub-9958110825614857/8896670921"

#define GoogleMapsServerKey @"AIzaSyCpqdTrZ6n2_YyPDVFG1SSiem4Ji7tOtAw"

#define appDelegate (AppDelegate*)[UIApplication sharedApplication].delegate

#define kResponseCode @"response_code"
#define kResponseMessage @"response_message"

#define kRequestSuccess 100
#define kRequestAlreadySent 103


#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

enum RideType
{
    PickUp = 1,
    PickMeUp = 2
};