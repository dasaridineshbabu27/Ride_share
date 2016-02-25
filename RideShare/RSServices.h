//
//  Services.h
//  RideShare
//
//  Created by Reddy on 19/01/16.
//  Copyright © 2016 Reddy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSServices : NSObject<NSURLSessionDataDelegate, NSURLSessionDelegate>
{
    NSMutableData *webData;
}

+(void)processRegistration:(NSDictionary*)infoDict  completionHandler:(void(^)(NSDictionary* , NSError*)) callback;

+(void)uploadProfileImageWithUserID:(NSDictionary*)parameters imageData:(NSData*)imageData  completionHandler:(void(^)(NSDictionary* , NSError*)) callback;

+(void)processLogin:(NSDictionary*)infoDict completionHandler:(void(^)(NSDictionary* , NSError*)) callback;

+(void)getProfileImageWithUserID:(NSDictionary*)parameters completionHandler:(void(^)(NSDictionary* , NSError*)) callback;

+ (void)processChangePassword:(NSDictionary*)infoDict completionHandler:(void(^)(NSDictionary* , NSError*)) callback;

+ (void)processUpdateProfile:(NSDictionary*)infoDict completionHandler:(void(^)(NSDictionary* , NSError*)) callback;

+ (void)processMyRideRequest:(NSDictionary*)infoDict completionHandler:(void(^)(NSDictionary* , NSError*)) callback;

+ (void)processPickMeUpRequest:(NSDictionary*)infoDict completionHandler:(void(^)(NSDictionary* , NSError*)) callback;

+ (void)processFetchHistory:(NSDictionary*)infoDict completionHandler:(void(^)(NSDictionary* , NSError*)) callback;

+ (void)processDeleteMyRideRequest:(NSDictionary*)infoDict completionHandler:(void(^)(NSDictionary* , NSError*)) callback;

+ (void)processForgotPassword:(NSDictionary*)infoDict completionHandler:(void(^)(NSDictionary* , NSError*)) callback;

+ (void)processFetchDefaultRides:(NSDictionary*)infoDict completionHandler:(void(^)(NSDictionary* , NSError*)) callback;

+ (void)processRegisterDeviceForPush:(NSDictionary*)info completionHandler:(void(^)(NSDictionary* , NSError*)) callback;

+ (void)processRequestRideViaPush:(NSDictionary*)info completionHandler:(void(^)(NSDictionary* , NSError*)) callback;

+ (void)processFetchNotifications:(NSDictionary*)info completionHandler:(void(^)(NSDictionary* , NSError*)) callback;

+ (void)processAcceptRide:(NSDictionary*)infoDict completionHandler:(void(^)(NSDictionary* , NSError*)) callback;

+ (void)processStartRide:(NSDictionary*)infoDict completionHandler:(void(^)(NSDictionary* , NSError*)) callback;

+ (void)processFinishride:(NSDictionary*)infoDict completionHandler:(void(^)(NSDictionary* , NSError*)) callback;


@end
