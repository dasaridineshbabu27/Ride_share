//
//  Services.h
//  RideShare
//
//  Created by Reddy on 19/01/16.
//  Copyright © 2016 Reddy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSServices : NSObject<NSURLSessionDataDelegate , NSURLConnectionDataDelegate>
{
    NSMutableData *webData;
}

+(void)processRegistration:(NSDictionary*)infoDict completionHandler:(void(^)(NSDictionary* , NSError*)) callback;

+(void)processLogin:(NSDictionary*)infoDict completionHandler:(void(^)(NSDictionary* , NSError*)) callback;

+ (void)processChangePassword:(NSDictionary*)infoDict completionHandler:(void(^)(NSDictionary* , NSError*)) callback;
@end
