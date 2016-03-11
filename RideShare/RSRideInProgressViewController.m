//
//  RSRideInProgressViewController.m
//  RideShare
//
//  Created by Reddy on 06/02/16.
//  Copyright © 2016 Reddy. All rights reserved.
//

#import "RSRideInProgressViewController.h"
#define CLCOORDINATES_EQUAL( coord1, coord2 ) (coord1.latitude == coord2.latitude && coord1.longitude == coord2.longitude)
#define degreesToRadians(x) (M_PI * x / 180.0)
#define radiandsToDegrees(x) (x * 180.0 / M_PI)
#define POSITIONKEY @"positionAnimation"
#import "AppDelegate.h"
#import <SocketIOClientSwift/SocketIOClientSwift-Swift.h>
#import "HGMovingAnnotationSampleViewController.h"


@interface RSRideInProgressViewController ()

@property NSMutableArray *points;

@property GMSCoordinateBounds *bounds;
@property CLLocationCoordinate2D updatedLocation;
@property GMSMarker *vehicleMarker;


@property NSString *latitude;
@property NSString *longitude;
@property NSDictionary *locationInfo;
@property NSArray *locationArr;

@property NSDictionary *receivedlocationInfo;
@property  CLLocationDegrees myLatitude ;
@property CLLocationDegrees myLongitude;
@property CLLocationCoordinate2D newCoordinate;

@property BOOL registered;
@property SocketIOClient *socketClient;
@property SocketIOClient *socketClientRoom;
@property NSString *scoketID;



@end

@implementation RSRideInProgressViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.currentUser = [User currentUser];
    
    self.navigationItem.title = @"Ride";
    UIBarButtonItem *sendButton = [[UIBarButtonItem alloc] initWithTitle:@"Finish" style:UIBarButtonItemStylePlain target:self action:@selector(finishRideClicked)];
    //self.navigationItem.rightBarButtonItem = sendButton;
    
    
    UIBarButtonItem *testSend = [[UIBarButtonItem alloc] initWithTitle:@"test" style:UIBarButtonItemStylePlain target:self action:@selector(testSend)];
    self.navigationItem.rightBarButtonItems = @[sendButton,testSend];
    
    
    self.navigationItem.hidesBackButton = YES;
    
    
//    NSLog(@"\n \n currentUserId=== %@",_currentUser.userId);
//    NSLog(@"\n \n otherUser_id=== %@",_otherUser_id);
//    NSLog(@"\n \n _ride_info=== %@",_ride_info);
//    NSLog(@"\n \n _notification=== %@",_notification);
    
    //    NSLog(@"\n \n pickUpLocation===%f, %f",_pickUpLocation.latitude,_pickUpLocation.longitude);
    //    NSLog(@"\n \n startCoordinate===%f, %f",_startCoordinate.latitude,_startCoordinate.longitude);
    //    NSLog(@"\n \n destinationCoordinate===%f, %f",_destinationCoordinate.latitude,_destinationCoordinate.longitude);
    self.points=[[NSMutableArray alloc]init];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager requestAlwaysAuthorization];
    
    [self focusMapToShowAllMarkers];
    self.vehicleMarker = [[GMSMarker alloc] init];
    [self updateVehicleLocationCoordinates:self.startCoordinate];
    
    
    
    
    if ([RSUtils isNetworkReachable])
    {
        [self initiateClientSocket];
    }
    else
    {
       // NSLog(@"\n Network problem");
    }
    
}
-(void)viewWillAppear:(BOOL)animated
{
    //self.navigationController.navigationBarHidden = NO;
}
-(void)viewWillDisappear:(BOOL)animated
{
    
}

- (void)disconnectClientSocket
{
    
    if (self.socketClient != nil && self.socketClient.status == SocketIOClientStatusConnected)
    {
        [self.socketClient disconnect];
        [self.socketClient removeAllHandlers];
        [self.socketClient close];
    }
    
}

- (void)disconnectClientSocketRoom
{
    
    if (self.socketClientRoom != nil && self.socketClientRoom.status == SocketIOClientStatusConnected)
    {
        [self.socketClientRoom disconnect];
        [self.socketClientRoom removeAllHandlers];
        [self.socketClientRoom close];
    }
    
}
- (void)finishRideClicked
{
   // NSLog(@"\n Finish button tapped");
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"RideShare" message:@"Do you want to close your ride?" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                               {
                                   [self.locationManager stopUpdatingLocation];
                                   [self disconnectClientSocket];
                                   [self disconnectClientSocketRoom];
                                   
                                   UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                                            bundle: nil];
                                   UIViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"RSHomeViewController"];
                                   
                                   [self.navigationController pushViewController:vc  animated:YES];
                                   //[self presentViewController:vc animated:YES completion:nil];
                                   //[self.navigationController popViewControllerAnimated:YES];
                               }];
    
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                             {
                                 [alertController dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    
    [alertController addAction:okAction];
    [alertController addAction:cancel];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
    
    
}

-(void)focusMapToShowAllMarkers
{
    self.bounds = [[GMSCoordinateBounds alloc] init];
    
    [self addPinOnMapAt:_startCoordinate];
    [self addPinOnMapAt:_pickUpLocation];
    [self addPinOnMapAt:_destinationCoordinate];
    
    [_rideMapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:self.bounds withPadding:40.0f]];
    
}
- (void)addPinOnMapAt:(CLLocationCoordinate2D)coordinate
{
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = coordinate;
    //marker.title = @"Origination";
    
    UIImage *markerImage = nil;
    
    if (CLCOORDINATES_EQUAL(_pickUpLocation, coordinate))
    {
        markerImage = [UIImage imageNamed:@"Location"];
        marker.snippet = @"Pick Up location";
    }
    else if (CLCOORDINATES_EQUAL(_destinationCoordinate, coordinate))
    {
        markerImage = [UIImage imageNamed:@"map_icon"];
        marker.snippet = @"Destination";
    }
    else
    {
        markerImage = [UIImage imageNamed:@"Car_Black"];
        marker.snippet = @"Vehicle Location";
        vehicleMarker=marker;
    }
    marker.icon = markerImage;
    marker.map = _rideMapView;
    
    self.bounds = [self.bounds includingCoordinate:marker.position];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status ==  kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse)
    {
        [self.locationManager startUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    
    CLLocation *currentLocation = [locations lastObject];
    //    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:currentLocation.coordinate.latitude longitude:currentLocation.coordinate.longitude zoom:13];
    //    _rideMapView.camera = camera;
    
    _rideMapView.delegate = self;
    _rideMapView.myLocationEnabled = YES;
    [[_rideMapView settings] setMyLocationButton:YES];
    
    
    ///////Updating Location////////
    if ([[_notification valueForKey:@"is_rider"] isEqual:@"1"])
    {
        [self updateLocationData:currentLocation];
    }
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString*)createRoom
{
    //    NSString *room=[NSString stringWithFormat:@"%@join%@",self.currentUser.userId,_otherUser_id];
    //    return room;
    return [_ride_info objectForKey:@"ride_id"];
}
-(void)joinRoom
{
    NSArray *room=[NSArray arrayWithObjects: [self createRoom], nil];
    [self.socketClient emit:@"groupConnect" withItems:room];
    
    /////////
    [self initiateClientSocketRoom];
    [self disconnectClientSocket];
    
}
-(void)initiateClientSocket
{
    //////// Real code
    NSURL* scoketURL = [[NSURL alloc] initWithString:@"http://192.168.0.104:3000"];
    self.socketClient = [[SocketIOClient alloc] initWithSocketURL:scoketURL options:@{@"log": @NO, @"forcePolling": @NO}];
    [self.socketClient connect];
    self.socketClient.reconnects = NO;
    [self joinRoom];
    //[self addHandlers];
}

-(void)initiateClientSocketRoom
{
    //////// Real code
    NSURL* scoketURLRoom = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://192.168.0.104:3000/%@",[self createRoom]] ];
    //NSLog(@"scoketURLRoom===%@",scoketURLRoom);
    self.socketClientRoom = [[SocketIOClient alloc] initWithSocketURL:scoketURLRoom options:@{@"log": @NO, @"forcePolling": @NO}];
    [self.socketClientRoom connect];
    self.socketClientRoom.reconnects = NO;
    [self addHandlersRoom];
}

-(void)addHandlersRoom
{
    ////Getting Event
    [self.socketClientRoom onAny:^(SocketAnyEvent *event)
     {
         //NSLog(@"\n \n ROOM event:::%@ \n count:::%lu",event,event.items.count);
         
         
         //////Scoket Connected
         [ self.socketClientRoom on:@"connect" callback:^(NSArray* data, SocketAckEmitter* ack)
          {
              //NSLog(@"\n \n ROOM CONNECT data====%@   SocketAckEmitter====%@ \n",data,ack.description);
              
              
              /////Scoket sendmessage
              [self.socketClientRoom on:@"sendmessage" callback:^(NSArray* data, SocketAckEmitter* ack)
               {
                  // NSLog(@"\n \n ROOM SEND MESSAGE:::data====%@  SocketAckEmitter====%@ ",data,ack.description);
                   
                   if (data.count!=0)
                   {
                       _receivedlocationInfo=[data objectAtIndex:0];
                       
                       if (_currentUser.userId == [_receivedlocationInfo objectForKey:@"receiver_id"] )
                       {
                           
                           //creating latitude and longitude for location
                           _myLatitude = [[_receivedlocationInfo objectForKey:@"latitude"] doubleValue];
                           _myLongitude = [[_receivedlocationInfo objectForKey:@"longitude"] doubleValue];
                           _newCoordinate = CLLocationCoordinate2DMake(_myLatitude, _myLongitude);
                           //[self updateVehicleLocationCoordinates:_newCoordinate];
                           [self setPosition:_newCoordinate];
                           
                           NSString *info=[NSString stringWithFormat:@"latitude=%@\nlongitude=%@\nreceiver_id=%@\nsender_id=%@",[_receivedlocationInfo objectForKey:@"latitude"],[_receivedlocationInfo objectForKey:@"longitude"],[_receivedlocationInfo objectForKey:@"receiver_id"],[_receivedlocationInfo objectForKey:@"sender_id"]];
                           //NSLog(@"\n \n SUCCESS:::%@",info);
                           //[RSUtils showAlertWithTitle:@"Success" message:info actionOne:nil actionTwo:nil inView:self];
                           
                       }
                       else
                       {
                           NSString *info=[NSString stringWithFormat:@"latitude=%@\nlongitude=%@\nreceiver_id=%@\nsender_id=%@",[_receivedlocationInfo objectForKey:@"latitude"],[_receivedlocationInfo objectForKey:@"longitude"],[_receivedlocationInfo objectForKey:@"receiver_id"],[_receivedlocationInfo objectForKey:@"sender_id"]];
                           //NSLog(@"\n \n FAILURE:::%@",info);
                           //[RSUtils showAlertWithTitle:@"Falure" message:info actionOne:nil actionTwo:nil inView:self];
                       }
                       
                   }
                   else
                   {
                       
                   }
                   
               }];
              /////Scoket disconnected
              [self.socketClientRoom on:@"disconnect" callback:^(NSArray* data, SocketAckEmitter* ack)
               {
                   //NSLog(@"\n \n ROOM DISCONNECT:::data====%@  SocketAckEmitter====%@ ",data,ack.description);
                   if( self.currentUser!= nil)
                   {
                       if (self.socketClientRoom.status == SocketIOClientStatusClosed && [RSUtils isNetworkReachable])
                       {
                           [self initiateClientSocketRoom];
                       }
                   }
                   
               }];
              
              
          }];
         
         
         
     }];
}
-(void)addHandlers
{
    ////Getting Event
    [self.socketClient onAny:^(SocketAnyEvent *event)
     {
         //NSLog(@"\n \n SOCKET event:::%@ \n count:::%lu",event,event.items.count);
         
         
         //////Scoket Connected
         [ self.socketClient on:@"connect" callback:^(NSArray* data, SocketAckEmitter* ack)
          {
              //NSLog(@"\n \n SOCKET CONNECT data====%@   SocketAckEmitter====%@ \n",data,ack.observationInfo);
              
              NSArray *room=[NSArray arrayWithObjects: [self createRoom], nil];
              [self.socketClient emit:@"groupConnect" withItems:room];
              
              /////////
              [self initiateClientSocketRoom];
              [self disconnectClientSocket];
              
              
              /////Scoket disconnected
              [self.socketClient on:@"disconnect" callback:^(NSArray* data, SocketAckEmitter* ack)
               {
                   //NSLog(@"\n \n SOCKET DISCONNECT:::data====%@  SocketAckEmitter====%@ ",data,ack.description);
                   if( self.currentUser!= nil)
                   {
                       if (self.socketClient.status == SocketIOClientStatusClosed && [RSUtils isNetworkReachable])
                       {
                           // [self initiateClientSocket];
                       }
                   }
                   
               }];
              
              
          }];
         
         
         
     }];
    
    
    //    ////Getting Event
    //    [self.socketClient onAny:^(SocketAnyEvent *event)
    //     {
    //          NSLog(@"\n \n socket event:::%@ \n count:::%u",event,event.items.count);
    //         if(event.items.count)
    //         {
    //             NSLog(@"\n \n socket event first Object :::%@",[event.items objectAtIndex:0]);
    //
    //             if (!_registered)////Need to update code
    //             {
    //                 ////////Register UserID
    //                 _scoketID=[[event.items objectAtIndex:0] valueForKey:@"id"];
    //                 if (_scoketID !=nil)
    //                 {
    //
    //                     NSLog(@"\n \n _scoketID:::%@",_scoketID);
    //
    //                     if (self.currentUser!= nil )
    //                     {
    //
    //                         ///////////Register users scoket
    //                         NSArray *userArrr=[NSArray arrayWithObjects: self.currentUser.userId,_scoketID,@"1",nil];
    //                         [self.socketClient emit:@"register" withItems:userArrr];
    //                     }
    //                     _registered = YES;
    //                 }
    //                 else
    //                 {
    //                     NSLog(@"\n \n Failed to register chat");
    //                 }
    //
    //             }
    //             else
    //             {
    //                 //////update map with received data
    //                  NSLog(@"\n \n Update Map with Received data");
    //             }
    //
    //         }
    //         else
    //         {
    //             NSLog(@"\n \n No Event ");
    //         }
    //
    //     }
    //     ];
    //
    //    //////Scoket Connected
    //    [ self.socketClient on:@"connect" callback:^(NSArray* data, SocketAckEmitter* ack)
    //     {
    //         NSLog(@"\n \n socket connected:::data====%@ \n SocketAckEmitter====%@ ",data,ack.description);
    //
    //
    //     }];
    //
    //    /////Scoket disconnected
    //    [self.socketClient on:@"disconnect" callback:^(NSArray* data, SocketAckEmitter* ack)
    //     {
    //
    //         NSLog(@"\n \n socket disconnect:::data====%@ \n SocketAckEmitter====%@ ",data,ack);
    //
    //
    //         if( self.currentUser!= nil)
    //         {
    //             if (self.socketClient.status == SocketIOClientStatusClosed && [RSUtils isNetworkReachable])
    //             {
    //                 [self initiateClientSocket];
    //             }
    //         }
    //
    //     }];
}

-(void)updateLocationData:(CLLocation*)currentLocation
{
    ///////Updating Location//////// (appDelegate)
    if (self.socketClientRoom != nil && self.socketClientRoom.status == SocketIOClientStatusConnected)
    {
        
        _latitude=[NSString stringWithFormat: @"%f", currentLocation.coordinate.latitude];
        _longitude =[NSString stringWithFormat: @"%f", currentLocation.coordinate.longitude];
        
        _locationInfo = @{@"sender_id":self.currentUser.userId,@"receiver_id":self.otherUser_id ,@"latitude":_latitude,@"longitude":_longitude};
        _locationArr=[NSArray arrayWithObjects: _locationInfo, nil];
        [self.socketClientRoom emit:@"sendmessage" withItems:_locationArr];
        
    }
    else
    {
        //NSLog(@"\n \n ROOM NOT CONNECTED to update location.");
        //[self initiateClientSocketRoom];
    }
    
}


-(void)updateVehicleLocationCoordinates:(CLLocationCoordinate2D)locationCoordinates
{
    
   // NSLog(@"\n \n updatedLocation===%f, %f",locationCoordinates.latitude,locationCoordinates.longitude);
    
    
    if (self.vehicleMarker == nil)
    {
        //self.vehicleMarker = [[GMSMarker alloc] init];
        //self.vehicleMarker.position = locationCoordinates;
        
        self.vehicleMarker = [GMSMarker markerWithPosition:locationCoordinates];
        self.vehicleMarker.icon = [UIImage imageNamed:@"Car_Black"];
        self.vehicleMarker.map = _rideMapView;
    }
    else
    {
        [CATransaction begin];
        [CATransaction setAnimationDuration:2.0];
        self.vehicleMarker.position = locationCoordinates;
        [CATransaction commit];
    }
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


//- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
//{
//
//    NSString *pointString=[NSString    stringWithFormat:@"%f,%f",newLocation.coordinate.latitude,newLocation.coordinate.longitude];
//    [self.points addObject:pointString];
//
//    GMSMutablePath *path = [GMSMutablePath path];
//    for (int i=0; i<self.points.count; i++)
//    {
//        NSArray *latlongArray = [[self.points   objectAtIndex:i]componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
//
//        [path addLatitude:[[latlongArray objectAtIndex:0] doubleValue] longitude:[[latlongArray objectAtIndex:1] doubleValue]];
//    }
//
//    if (self.points.count>2)
//    {
//        GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
//        polyline.strokeColor = [UIColor blueColor];
//        polyline.strokeWidth = 5.f;
//        polyline.map = _rideMapView;
//        self.view = _rideMapView;
//    }}


- (void) setPosition : (CLLocationCoordinate2D)coordinates
{
    //NSLog(@"set position");
    
    CGPoint mapPoint=[_rideMapView.projection pointForCoordinate: coordinates];
    
    CGPoint toPos;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
    {
        
        toPos = [_rideMapView.projection pointForCoordinate: coordinates];
    }
    
    CLLocationCoordinate2D currentCoordinate = [_rideMapView.projection coordinateForPoint:mapPoint];
    CLLocationCoordinate2D previousCoordinate = [_rideMapView.projection coordinateForPoint:previousPoint];
    
    
    // [self setTransform:CGAffineTransformMakeRotation([self getHeadingForDirectionFromCoordinate:previousCoordinate toCoordinate: currentCoordinate])];
    
    
    CGPoint vehicleMarkerPoint=[_rideMapView.projection pointForCoordinate: vehicleMarker.position];
    
    if ([_rideMapView.projection containsCoordinate:currentCoordinate])
    {
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
        
        animation.fromValue = [NSValue valueWithCGPoint:vehicleMarkerPoint];
        animation.toValue = [NSValue valueWithCGPoint:toPos];
        animation.duration = 1.0;
        animation.delegate = self;
        animation.fillMode = kCAFillModeForwards;
        //[self.layer removeAllAnimations];
        [vehicleMarker.layer addAnimation:animation forKey:POSITIONKEY];
        
        //NSLog(@"setPosition ANIMATED %x from (%f, %f) to (%f, %f)", self, self.center.x, self.center.y, toPos.x, toPos.y);
    }
    
    vehicleMarkerPoint = toPos;
    CLLocationCoordinate2D vehicleMarkerCoordinate = [_rideMapView.projection coordinateForPoint:vehicleMarkerPoint];
    [vehicleMarker setPosition:vehicleMarkerCoordinate];
    
    previousPoint = mapPoint;
}

- (float)getHeadingForDirectionFromCoordinate:(CLLocationCoordinate2D)fromLoc toCoordinate:(CLLocationCoordinate2D)toLoc
{
    float fLat = degreesToRadians(fromLoc.latitude);
    float fLng = degreesToRadians(fromLoc.longitude);
    float tLat = degreesToRadians(toLoc.latitude);
    float tLng = degreesToRadians(toLoc.longitude);
    
    float degree = atan2(sin(tLng-fLng)*cos(tLat), cos(fLat)*sin(tLat)-sin(fLat)*cos(tLat)*cos(tLng-fLng));
    
    float deg  = radiandsToDegrees(degree);
    
    
   // NSLog(@"%f",deg);
    
    
    return degreesToRadians(deg);
    
}

//-(void)initiateClientSocket
//{
//    //////// Real code
//    NSURL* scoketURL = [[NSURL alloc] initWithString:@"http://192.168.0.104:3000"];
//    self.socketClient = [[SocketIOClient alloc] initWithSocketURL:scoketURL options:@{@"log": @NO, @"forcePolling": @NO}];
//    [self.socketClient connect];
//    self.socketClient.reconnects = YES;
//    [self addHandlers];
//}
/////////////
///////////// Testing Sample
//    NSURL* url = [[NSURL alloc] initWithString:@"http://192.168.0.104:3000"];
//     self.scoketClient = [[SocketIOClient alloc] initWithSocketURL:url options:@{@"log": @YES, @"forcePolling": @YES}];
//
//    [ self.scoketClient on:@"connect" callback:^(NSArray* data, SocketAckEmitter* ack)
//    {
//        NSLog(@"socket connected");
//    }];
//
//    [ self.scoketClient on:@"currentAmount" callback:^(NSArray* data, SocketAckEmitter* ack)
//    {
//        double cur = [[data objectAtIndex:0] floatValue];
//
//        [ self.scoketClient emitWithAck:@"canUpdate" withItems:@[@(cur)]](0, ^(NSArray* data)
//        {
//            [ self.scoketClient emit:@"update" withItems:@[@{@"amount": @(cur + 2.50)}]];
//        });
//
//        [ack with:@[@"Got your currentAmount, ", @"dude"]];
//    }];
//
//    [ self.scoketClient connect];



//////Getting Event
//[self.socketClient onAny:^(SocketAnyEvent *event)
// {
//     NSLog(@"\n \n socket event:::%@ \n count:::%u",event,event.items.count);
//
//     if(event.items.count)
//     {
//         NSLog(@"\n \n socket onAny event Dictonary:::%@",[event.items objectAtIndex:0]);
//
//         ///////////////////
//         id eventObject=[event.items objectAtIndex:0];
//         if ([eventObject isKindOfClass:[NSDictionary class]] )
//         {
//             _scoketID=[[event.items objectAtIndex:0] valueForKey:@"id"];
//
//             if (_scoketID !=nil)
//             {
//                 NSLog(@"\n \n _scoketID:::%@",_scoketID);
//             }
//
//         }
//
//
//     }
//
//
//     //////Scoket Connected
//     [ self.socketClient on:@"connect" callback:^(NSArray* data, SocketAckEmitter* ack)
//      {
//          NSLog(@"\n \n CONNECT data====%@   SocketAckEmitter====%@ \n",data,ack.description);
//
//          if( self.currentUser!= nil && _scoketID !=nil)
//          {
//              ///////////Register users scoket
//              NSArray *userArrr=[NSArray arrayWithObjects: self.currentUser.userId,_scoketID,@"1",nil];
//              [self.socketClient emit:@"register" withItems:userArrr];
//
//          }
//          else
//          {
//
//              NSLog(@"\n \n Failed to register chat since current user is nil");
//          }
//
//          /////Scoket disconnected
//          [self.socketClient on:@"updatedata" callback:^(NSArray* data, SocketAckEmitter* ack)
//           {
//               NSLog(@"\n \n UPDATEDATA:::data====%@  SocketAckEmitter====%@ ",data,ack);
//           }];
//
//          /////Scoket disconnected
//          [self.socketClient on:@"disconnect" callback:^(NSArray* data, SocketAckEmitter* ack)
//           {
//               NSLog(@"\n \n  DISCONNECT:::data====%@  SocketAckEmitter====%@ ",data,ack);
//               if( self.currentUser!= nil)
//               {
//                   if (self.socketClient.status == SocketIOClientStatusClosed && [RSUtils isNetworkReachable])
//                   {
//                       [self initiateClientSocket];
//                   }
//               }
//
//           }];
//
//
//      }];
//
//
//
// }];

- (void)testSend
{
    //Testing Scoket
    double your_latitiude_value = 8.391916;
    double your_longitude_value = 77.094315;
    CLLocation *myLocation = [[CLLocation alloc] initWithLatitude:your_latitiude_value longitude:your_longitude_value];
    [self updateLocationData:myLocation];
    
    //////Navigating
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    HGMovingAnnotationSampleViewController *myVC = (HGMovingAnnotationSampleViewController *)[storyboard instantiateViewControllerWithIdentifier:@"myViewCont"];
    
    myVC.otherUser_id=_otherUser_id;
    myVC.ride_info=_ride_info;
    myVC.notification=_notification;
    
    myVC.pickUpLocation=_pickUpLocation;
    myVC.startCoordinate=_startCoordinate;
    myVC.destinationCoordinate=_destinationCoordinate;
    
    [self.navigationController  pushViewController:myVC animated:YES];
    
}
@end


