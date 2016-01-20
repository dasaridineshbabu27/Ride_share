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

@implementation RSServices

+(void)processRegistration:(NSDictionary*)infoDict completionHandler:(void(^)(NSDictionary* , NSError*)) callback
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
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
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:urlChangePassword  parameters:infoDict progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        callback(responseObject, nil);
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        callback(nil, error);
    }];
}


#pragma mark- NSURLSessionDataDelegate methods

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    NSLog(@"didReceiveResponse");
}

/* Notification that a data task has become a download task.  No
 * future messages will be sent to the data task.
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didBecomeDownloadTask:(NSURLSessionDownloadTask *)downloadTask
{
        NSLog(@"didBecomeDownloadTask");
}

/*
 * Notification that a data task has become a bidirectional stream
 * task.  No future messages will be sent to the data task.  The newly
 * created streamTask will carry the original request and response as
 * properties.
 *
 * For requests that were pipelined, the stream object will only allow
 * reading, and the object will immediately issue a
 * -URLSession:writeClosedForStream:.  Pipelining can be disabled for
 * all requests in a session, or by the NSURLRequest
 * HTTPShouldUsePipelining property.
 *
 * The underlying connection is no longer considered part of the HTTP
 * connection cache and won't count against the total number of
 * connections per host.
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didBecomeStreamTask:(NSURLSessionStreamTask *)streamTask
{
        NSLog(@"didBecomeStreamTask");
}

/* Sent when data is available for the delegate to consume.  It is
 * assumed that the delegate will retain and not copy the data.  As
 * the data may be discontiguous, you should use
 * [NSData enumerateByteRangesUsingBlock:] to access it.
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
       NSLog(@"didReceiveData");
}

/* Invoke the completion routine with a valid NSCachedURLResponse to
 * allow the resulting data to be cached, or pass nil to prevent
 * caching. Note that there is no guarantee that caching will be
 * attempted for a given resource, and you should not rely on this
 * message to receive the resource data.
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
 willCacheResponse:(NSCachedURLResponse *)proposedResponse
 completionHandler:(void (^)(NSCachedURLResponse * __nullable cachedResponse))completionHandler
{
        NSLog(@"willCacheResponse");
}


@end
