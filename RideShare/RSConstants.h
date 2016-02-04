//
//  RSConstants.m
//  RideShare
//
//  Created by Reddy on 06/01/16.
//  Copyright © 2016 Reddy. All rights reserved.
//

#define GoogleMapsAPIKey @"AIzaSyCf3EGm2PxKWUfiFlz2uFHlM7M3b9Pj7fE"

#define GoogleMapsServerKey @"AIzaSyCpqdTrZ6n2_YyPDVFG1SSiem4Ji7tOtAw"

#define appDelegate (AppDelegate*)[UIApplication sharedApplication].delegate

#define kResponseCode @"response_code"
#define kResponseMessage @"response_message"

#define kRequestSuccess 100

enum RideType
{
    PickUp,
    PickMeUp
};