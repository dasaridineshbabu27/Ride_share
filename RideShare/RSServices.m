//
//  Services.m
//  RideShare
//
//  Created by Reddy on 19/01/16.
//  Copyright © 2016 Reddy. All rights reserved.
//

#import "RSServices.h"
#import "RSConfig.h"
#import <AFNetworking/AFNetworking.h>
#import "RSUtils.h"

@implementation RSServices

+(void)processRegistration:(NSDictionary*)infoDict imageData:(NSData*)imageData completionHandler:(void(^)(NSDictionary* , NSError*)) callback
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSLog(@"processRegistration url: %@", urlRegistration);
    NSLog(@"post data is:%@", infoDict);
    
    [manager GET:urlRegistration  parameters:infoDict progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        callback(responseObject, nil);
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        callback(nil, error);
    }];
}

+(void)processLogin:(NSDictionary*)infoDict completionHandler:(void(^)(NSDictionary* , NSError*)) callback
{
//    NSLog(@"processLogin url: %@", urlLogin);
//    NSLog(@"post data is:%@", infoDict);
//    
//    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
//    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlLogin]];
//    
//    NSString * params =@"email=dnreddy890@gmail.com&password=Password";
//    [request setHTTPMethod:@"POST"];
//    [request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
//
//    NSURLSessionDataTask *dTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        NSLog(@"Data is : %@",data);
//        NSString *dataString = [[NSString alloc] initWithUTF8String:[data bytes]];
//        NSLog(@"Data string is : %@", dataString);
//    }];
//    [dTask resume];
    
//   if (![RSUtils isNetworkReachable])
//   {
//       [RSUtils showAlertWithTitle:@"Network Error" message:@"Please check your internet connectivity." actionOne:nil actionTwo:nil inView:];
//       return;
//   }
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:urlLogin  parameters:infoDict progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        callback(responseObject, nil);
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        callback(nil, error);
    }];
}

+ (void)processChangePassword:(NSDictionary*)infoDict completionHandler:(void(^)(NSDictionary* , NSError*)) callback
{
    NSLog(@"processChangePassword url: %@", urlChangePassword);
    NSLog(@"post data is:%@", infoDict);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:urlChangePassword  parameters:infoDict progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        callback(responseObject, nil);
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        callback(nil, error);
    }];
}

+ (void)processUpdateProfile:(NSDictionary*)infoDict completionHandler:(void(^)(NSDictionary* , NSError*)) callback
{
    NSLog(@"processUpdateProfile url: %@", urlChangePassword);
    NSLog(@"post data is:%@", infoDict);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:urlChangePassword  parameters:infoDict progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        callback(responseObject, nil);
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        callback(nil, error);
    }];
}

+ (void)processMyRideRequest:(NSDictionary*)infoDict completionHandler:(void(^)(NSDictionary* , NSError*)) callback
{
    NSLog(@"processUpdateProfile url: %@", urlMyRideRequest);
    NSLog(@"post data is:%@", infoDict);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    if ([[infoDict valueForKey:@"ride_type"] isEqualToString:@"2"])
    {
        [self processPickMeUpRequest:infoDict completionHandler:callback];
        return;
    }
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager POST:urlMyRideRequest  parameters:infoDict progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        callback(responseObject, nil);
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        callback(nil, error);
    }];
}

+ (void)processPickMeUpRequest:(NSDictionary*)infoDict completionHandler:(void(^)(NSDictionary* , NSError*)) callback
{
    NSLog(@"processPickMeUpRequest url: %@", urlPmuRequest);
    NSLog(@"post data is:%@", infoDict);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSError * err;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:infoDict options:0 error:&err];
    NSString * myString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [manager POST:urlPmuRequest  parameters:infoDict progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        callback(responseObject, nil);
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        callback(nil, error);
    }];
}

+ (void)processFetchHistory:(NSDictionary*)infoDict completionHandler:(void(^)(NSDictionary* , NSError*)) callback
{
    NSLog(@"processFetchHistory url: %@", urlFetchHistory);
    NSLog(@"post data is:%@", infoDict);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSLog(@"url is : %@", urlFetchHistory);
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager POST:urlFetchHistory  parameters:infoDict
         progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        callback(responseObject, nil);
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        callback(nil, error);
    }];
}

+ (void)processDeleteRequest:(NSDictionary*)infoDict completionHandler:(void(^)(NSDictionary* , NSError*)) callback
{
    NSLog(@"processDeleteRequest url: %@", urlDeleteRequest);
    NSLog(@"post data is:%@", infoDict);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:urlDeleteRequest  parameters:infoDict progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        callback(responseObject, nil);
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        callback(nil, error);
    }];
}

+ (void)processForgotPassword:(NSDictionary*)infoDict completionHandler:(void(^)(NSDictionary* , NSError*)) callback
{
    NSLog(@"processForgotPassword url: %@", urlForgotPassword);
    NSLog(@"post data is:%@", infoDict);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:urlForgotPassword  parameters:infoDict progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        callback(responseObject, nil);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        callback(nil, error);
    }];
}

+ (void)processFetchDefaultRides:(NSDictionary*)infoDict completionHandler:(void(^)(NSDictionary* , NSError*)) callback
{
    NSLog(@"processFetchDefaultRides url: %@", urlFetchDefaultRides);
    NSLog(@"post data is:%@", infoDict);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];      
    [manager POST:urlFetchDefaultRides  parameters:infoDict progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        callback(responseObject, nil);
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        callback(nil, error);
    }];
}

+ (void)processRegisterDeviceForPush:(NSDictionary*)infoDict completionHandler:(void(^)(NSDictionary* , NSError*)) callback
{
    NSLog(@"processFetchDefaultRides url: %@", urlRegisterDeviceForPush);
    NSLog(@"post data is:%@", infoDict);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager POST:urlRegisterDeviceForPush  parameters:infoDict progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        callback(responseObject, nil);
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        callback(nil, error);
    }];
}

+ (void)processRequestRideViaPush:(NSDictionary*)infoDict completionHandler:(void(^)(NSDictionary* , NSError*)) callback
{
    NSLog(@"processFetchDefaultRides url: %@", urlRequestViaPush);
    NSLog(@"post data is:%@", infoDict);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager POST:urlRequestViaPush  parameters:infoDict progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        callback(responseObject, nil);
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        callback(nil, error);
    }];
}

+ (void)processFetchNotifications:(NSDictionary*)infoDict completionHandler:(void(^)(NSDictionary* , NSError*)) callback
{
    NSLog(@"processFetchDefaultRides url: %@", urlRequestNotifications);
    NSLog(@"post data is:%@", infoDict);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager POST:urlRequestNotifications  parameters:infoDict progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        callback(responseObject, nil);
        
    } failure:^(NSURLSessionTask *operation, NSError *error)
    {
        NSLog(@"Error: %@", error);
        callback(nil, error);
    }];
}

@end
