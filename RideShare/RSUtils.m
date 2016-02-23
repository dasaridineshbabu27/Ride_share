//
//  RSUtils.m
//  RideShare
//
//  Created by Reddy on 13/01/16.
//  Copyright © 2016 Reddy. All rights reserved.
//

#import "RSUtils.h"
#import "Reachability.h"

@implementation RSUtils
// Method to remove all whitespaces from the beginning of the string.
+ (NSString*)trimWhiteSpaces:(NSString*)inputString
{
    return [inputString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

+(BOOL)isValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

+ (void)showAlertWithTitle:(NSString*)title message:(NSString*)messge actionOne:(UIAlertAction*)actionOne actionTwo:(UIAlertAction*)actionTwo inView:(UIViewController*)controller
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:messge preferredStyle:UIAlertControllerStyleAlert];
    
    if (actionOne)
    {
        [alertController addAction:actionOne];
    }
    
    if (actionTwo) {
        [alertController addAction:actionTwo];
    }
    else if (actionOne == nil && actionTwo == nil)
    {
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:alertAction];
    }
    
    [controller presentViewController:alertController animated:YES completion:nil];
}

+ (void)showAlertForError:(NSError*)error inView:(UIViewController*)controller
{
    NSString *alertMsg = nil;
    switch (error.code) {
        case -1001:
            alertMsg = @"Request Timeout.";
            break;
        case -1009:
            alertMsg = @"Network Error";
        default:
            alertMsg = [NSString stringWithFormat:@"Put proper error message for : %@", error.localizedDescription];
            break;
    }
    
    [self showAlertWithTitle:@"Error" message:alertMsg actionOne:nil actionTwo:nil inView:controller];
}

+ (BOOL)isNetworkReachable
{
    CFNetDiagnosticRef dReference;
    dReference = CFNetDiagnosticCreateWithURL (NULL, (__bridge CFURLRef)[NSURL URLWithString:@""]);
    
    CFNetDiagnosticStatus status;
    status = CFNetDiagnosticCopyNetworkStatusPassively (dReference, NULL);
    
    CFRelease (dReference);
    
    if ( status == kCFNetDiagnosticConnectionUp )
    {
        NSLog (@"Connection is Available");
        return YES;
    }
    else
    {
        NSLog (@"Connection is down");
        return NO;
    }
}


+(NSDate *) toLocalTime:(NSDate*)date
{
    NSTimeZone *tz = [NSTimeZone localTimeZone];
    NSInteger seconds = [tz secondsFromGMTForDate:date];
    return [NSDate dateWithTimeInterval: seconds sinceDate: date];
}

+(NSDate *) toGlobalTime:(NSDate*)date
{
    return date;
    NSTimeZone *tz = [NSTimeZone defaultTimeZone];
    NSInteger seconds = -[tz secondsFromGMTForDate: date];
    return [NSDate dateWithTimeInterval: seconds sinceDate: date];
}

+ (NSString*)getDateStringFormDate:(NSDate*)date withFormat:(NSString*)format
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setDateFormat:@"dd:MM:YYYY HH:mm"];
    NSLog(@"%@", [dateFormatter stringFromDate:date]);
    return [dateFormatter stringFromDate:date];
}

+ (NSDate*)getDateFormDateString:(NSString*)dateString withFormat:(NSString*)format
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setDateFormat:@"dd:MM:YYYY HH:mm"];
    NSLog(@"%@", [dateFormatter dateFromString:dateString]);
    return [dateFormatter dateFromString:dateString];
}

+ (NSDate*)getDateFromDate:(NSDate*)inDate forFormat:(NSString*)format
{
        return nil;
}

+ (NSString*)getDateString:(NSString*)dateString forFormat:(NSString*)format
{
    return @"";
}

+(NSString*)getDisplayDate:(NSString*)dateString
{
    NSDateFormatter *dateFormatte = [NSDateFormatter new];
    dateFormatte.dateStyle = NSDateFormatterMediumStyle;
    dateFormatte.timeStyle = NSDateFormatterShortStyle;
    [dateFormatte setDateFormat:@"dd:MM:YYYY HH:mm"];
    NSDate *date = [dateFormatte dateFromString:@"01:02:2016 17:05"];
    dateFormatte.dateStyle = NSDateFormatterMediumStyle;
    dateFormatte.timeStyle = NSDateFormatterShortStyle;
    NSLog(@"%@", [dateFormatte stringFromDate:date]);
    return [dateFormatte stringFromDate:date];
}

@end



/////////
//@property SIOSocket *socket;
//@property BOOL socketIsConnected;
//
//
////////////
//@property SocketIO *socketIO;
///////////
//[self socketImplementation];

////////
//[self scoketIOImplememtation];

//-(void)socketImplementation
//{
//    NSLog(@"\n\nSocket Implementation");
//
//    [SIOSocket socketWithHost: @"http://192.168.0.104:3000/" response: ^(SIOSocket *socket)
//
//     {
//         self.socket = socket;
//         __block typeof(self) weakSelf = self;
//
//         //////On Connect
//         self.socket.onConnect = ^()
//         {
//             weakSelf.socketIsConnected = YES;
//             NSLog(@"\n\nSocket CONNECT");
//         };
//
//
//         /////On Join
//         [self.socket on: @"join" callback: ^(SIOParameterArray *args)
//          {
//              NSLog(@"\n\nSocket JOIN");
//          }];
//
//
//
//         /////On Update
//         [self.socket on: @"update" callback: ^(SIOParameterArray *args)
//          {
//              NSLog(@"\n\nSocket UPDATE");
//
//          }];
//
//
//         /////On Disappear
//         [self.socket on: @"disappear" callback: ^(SIOParameterArray *args)
//          {
//              NSLog(@"\n\nSocket DISAPPEAR");
//          }];
//     }];
//
//}

//-(void)scoketIOImplememtation
//{
//    _socketIO = [[SocketIO alloc] initWithDelegate:self];
//    
//    // you can update the resource name of the handshake URL
//    // see https://github.com/pkyeck/socket.IO-objc/pull/80
//    // [socketIO setResourceName:@"whatever"];
//    
//    // if you want to use https instead of http
//    // socketIO.useSecure = YES;
//    
//    // pass cookie(s) to handshake endpoint (e.g. for auth)
//    
//    //    NSDictionary *properties = [NSDictionary dictionaryWithObjectsAndKeys:
//    //                                @"localhost", NSHTTPCookieDomain,
//    //                                @"/", NSHTTPCookiePath,
//    //                                @"auth", NSHTTPCookieName,
//    //                                @"56cdea636acdf132", NSHTTPCookieValue,
//    //                                nil];
//    //    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:properties];
//    //    NSArray *cookies = [NSArray arrayWithObjects:cookie, nil];
//    //    _socketIO.cookies = cookies;
//    
//    // connect to the socket.io server that is running locally at port 3000
//    [self.socketIO connectToHost:@"192.168.0.104" onPort:3000];
//    //dhttp://192.168.0.104:3000/
//    
//    
//}
//# pragma mark -
//# pragma mark socket.IO-objc delegate methods
//
//- (void) socketIODidConnect:(SocketIO *)socket
//{
//    NSLog(@"\n \n socket.io connected.");
//}
//
//- (void) socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet
//{
//    NSLog(@"\n \n socket.io didReceiveEvent.");
//    
//    
//    //    // test acknowledge
//    //    SocketIOCallback cb = ^(id argsData)
//    //    {
//    //        NSDictionary *response = argsData;
//    //        // do something with response
//    //        NSLog(@"ack arrived: %@", response);
//    //
//    //        // test forced disconnect
//    //        [self.socketIO disconnectForced];
//    //    };
//    //
//    //    ////////////
//    //    [self.socketIO sendMessage:@"hello back!" withAcknowledge:cb];
//    //
//    //    // test different event data types
//    //    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
//    //    [dict setObject:@"test1" forKey:@"key1"];
//    //    [dict setObject:@"test2" forKey:@"key2"];
//    //    [self.socketIO sendEvent:@"welcome" withData:dict];
//    //
//    //    ///////////
//    //    [self.socketIO sendEvent:@"welcome" withData:@"testWithString"];
//    //
//    //    ///////////
//    //    NSArray *arr = [NSArray arrayWithObjects:@"test1", @"test2", nil];
//    //    [self.socketIO sendEvent:@"welcome" withData:arr];
//    
//    
//    //////////////
//    self.updatedLocation=CLLocationCoordinate2DMake(14.88888, 134.768586967);
//    
//    [self updateVehicleLocationCoordinates:self.updatedLocation];
//    
//}
//
//
//- (void) socketIO:(SocketIO *)socket didSendMessage:(SocketIOPacket *)packet
//{
//    NSLog(@"\n \n socket.io didSendMessage.");
//}
//- (void) socketIO:(SocketIO *)socket didReceiveMessage:(SocketIOPacket *)packet
//{
//    NSLog(@"\n \n socket.io didReceiveMessage.");
//}
//- (void) socketIO:(SocketIO *)socket didReceiveJSON:(SocketIOPacket *)packet
//{
//    NSLog(@"\n \n socket.io didReceiveJSON.");
//}
//
//
//
//- (void) socketIO:(SocketIO *)socket onError:(NSError *)error
//{
//    
//    NSLog(@"\n \n socket.io onError.");
//    
//    if ([error code] == SocketIOUnauthorized)
//    {
//        NSLog(@"not authorized");
//    }
//    else
//    {
//        NSLog(@"onError() %@", error);
//    }
//}
//
//
//- (void) socketIODidDisconnect:(SocketIO *)socket disconnectedWithError:(NSError *)error
//{
//    
//    NSLog(@"\n \n socket.io disconnectedWithError.");
//    NSLog(@"socket.io disconnected. did error occur? %@", error);
//}

//    if (self.socketIsConnected)
//    {
//        [self.socket emit: @"location" args: @[
//                                               [NSString stringWithFormat: @"%f,%f", location.coordinate.latitude, location.coordinate.longitude]
//                                               ]];
//    }


//if (self.socketIO.isConnected)
//{
//    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
//    [dict setObject:[NSString stringWithFormat: @"%f", location.coordinate.latitude] forKey:@"latitude"];
//    [dict setObject:[NSString stringWithFormat: @"%f", location.coordinate.longitude] forKey:@"longitude"];
//    [self.socketIO sendEvent:@"location" withData:dict];
//    
//}
//else
//{
//    NSLog(@"\n \n socket.io NOT Connected to update location.");
//}
//
