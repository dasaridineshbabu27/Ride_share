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

#import <SocketIOClientSwift/SocketIOClientSwift-Swift.h>


@interface RSRideInProgressViewController ()

@property NSMutableArray *points;

@property GMSCoordinateBounds *bounds;
@property CLLocationCoordinate2D updatedLocation;
@property GMSMarker *vehicleMarker;
@property NSString *scoketID;

@property NSString *latitude;
@property NSString *longitude;
@property NSDictionary *locationInfo;
@property NSArray *locationArr;
@property BOOL registered;

@property SocketIOClient *socketClient;



@end

@implementation RSRideInProgressViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //_scoketID=@"";
    self.currentUser = [User currentUser];
    UIBarButtonItem *sendButton = [[UIBarButtonItem alloc] initWithTitle:@"Finish" style:UIBarButtonItemStylePlain target:self action:@selector(finishRideClicked)];
    //sendButton.image = [UIImage imageNamed:@"Hamburger_menu"];
    self.navigationItem.rightBarButtonItem = sendButton;
    
    [self.navigationController.navigationItem setHidesBackButton:YES animated:YES];
    
    NSLog(@"\n \n otherUser_id=== %@",_otherUser_id);
    NSLog(@"\n \n pickUpLocation===%f, %f",_pickUpLocation.latitude,_pickUpLocation.longitude);
    NSLog(@"\n \n startCoordinate===%f, %f",_startCoordinate.latitude,_startCoordinate.longitude);
    NSLog(@"\n \n destinationCoordinate===%f, %f",_destinationCoordinate.latitude,_destinationCoordinate.longitude);
    self.points=[[NSMutableArray alloc]init];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager requestAlwaysAuthorization];
    
    [self focusMapToShowAllMarkers];
    //self.vehicleMarker = [[GMSMarker alloc] init];
    [self updateVehicleLocationCoordinates:self.startCoordinate];
    
    if ([RSUtils isNetworkReachable])
    {
        //////
        [self initiateClientSocket];
    }
    else
    {
        NSLog(@"\n Network problem");
    }
    
}
-(void)viewWillAppear:(BOOL)animated
{
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    [self finishRideClicked];
}
- (void)finishRideClicked
{
    NSLog(@"\n Finish button tapped");
    if (self.socketClient != nil && self.socketClient.status == SocketIOClientStatusConnected)
    {
        [self.socketClient disconnect];
        [self.socketClient removeAllHandlers];
        [self.socketClient close];
    }
    
    //    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
    //                                                             bundle: nil];
    //    UIViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"RSHomeViewController"];
    //
    //    [self.navigationController popToViewController:vc animated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)focusMapToShowAllMarkers
{
    self.bounds = [[GMSCoordinateBounds alloc] init];
    
    [self addPinOnMapAt:_startCoordinate];
    [self addPinOnMapAt:_pickUpLocation];
    [self addPinOnMapAt:_destinationCoordinate];
    
    [_rideMapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:self.bounds withPadding:0.0f]];
    
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
    
    CLLocation *location = [locations lastObject];
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude zoom:13];
    
    _rideMapView.camera = camera;
    _rideMapView.delegate = self;
    _rideMapView.myLocationEnabled = YES;
    [[_rideMapView settings] setMyLocationButton:YES];
    
    //    [self.locationManager stopUpdatingLocation];
    
    ///////Updating Location////////
    
    
    if (self.socketClient != nil && self.socketClient.status == SocketIOClientStatusConnected)
    {
        _latitude=[NSString stringWithFormat: @"%f", location.coordinate.latitude];
        _longitude =[NSString stringWithFormat: @"%f", location.coordinate.longitude];
        
        ////////////////
        _locationInfo = @{@"latitude":_latitude,@"longitude":_longitude};
        _locationArr=[NSArray arrayWithObjects:_locationInfo, nil];
        [self.socketClient emit:@"chatMessage" withItems:_locationArr];
        
    }
    else
    {
        NSLog(@"\n \n Socket NOT Connected to update location.");
        //[self initiateClientSocket];
    }
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)initiateClientSocket
{
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
    
    
    ////////
    //////// Real code
    NSURL* scoketURL = [[NSURL alloc] initWithString:@"http://192.168.0.104:3000"];
    self.socketClient = [[SocketIOClient alloc] initWithSocketURL:scoketURL options:@{@"log": @NO, @"forcePolling": @NO}];
    [self.socketClient connect];
    self.socketClient.reconnects = NO;
    [self addHandlers];
}

-(void)addHandlers
{
    
    //    ////Getting Event
    //    [self.socketClient onAny:^(SocketAnyEvent *event)
    //    {
    //         NSLog(@"\n \n socket onAny event:::%@",event);
    //         NSLog(@"\n \n socket onAny event count:::%lu",event.items.count);
    //
    //        if(event.items.count)
    //        {
    //         NSLog(@"\n \n socket onAny event Dictonary:::%@",[event.items objectAtIndex:0]);
    //
    //            ///////////////////
    //            NSString *sID=[[event.items objectAtIndex:0] valueForKey:@"id"];
    //            if (sID !=nil)
    //            {
    //                _scoketID=sID;
    //                NSLog(@"\n \n _scoketID:::%@",_scoketID);
    //            }
    //
    //        }
    //
    //
    //        //////Scoket Connected
    //        [ self.socketClient on:@"connect" callback:^(NSArray* data, SocketAckEmitter* ack)
    //         {
    //             NSLog(@"\n \n socket connected:::data====%@ \n SocketAckEmitter====%@ ",data,ack.description);
    //
    //             if( self.currentUser!= nil && _scoketID !=nil)
    //             {
    //
    //                 ///////////Register users scoket
    //                 NSDictionary *userInfo = @{@"SocketId":_scoketID, @"currentUser":self.currentUser.userId, @"otherUser":self.otherUser_id};
    //                 NSArray *userArr=[NSArray arrayWithObjects:userInfo, nil];
    //                 [self.socketClient emit:@"chatMessage" withItems:userArr];
    //
    //                 ////////// testing
    ////                 NSDictionary *sample = @{@"message":@"srinivas",@"id":@"123"};
    ////                 NSArray *items=[NSArray arrayWithObjects:sample, nil];
    ////                 [self.socketClient emit:@"send" withItems:items];
    //
    //             }
    //             else
    //             {
    //
    //                 NSLog(@"\n \n Failed to register chat since current user is nil");
    //             }
    //
    //
    //             /////Scoket disconnected
    //             [self.socketClient on:@"disconnect" callback:^(NSArray* data, SocketAckEmitter* ack)
    //              {
    //
    //                  NSLog(@"\n \n socket disconnect:::data====%@ \n SocketAckEmitter====%@ ",data,ack);
    //
    //
    //                  if( self.currentUser!= nil)
    //                  {
    //                      if (self.socketClient.status == SocketIOClientStatusClosed && [RSUtils isNetworkReachable])
    //                      {
    //                          [self initiateClientSocket];
    //                      }
    //                  }
    //
    //              }];
    //
    //
    //         }];
    //
    //
    //
    //    }];
    
    
    
    ////Getting Event
    [self.socketClient onAny:^(SocketAnyEvent *event)
     {
         NSLog(@"\n \n socket onAny event:::%@",event);
         NSLog(@"\n \n socket onAny event:::%lu",event.items.count);
         
         if(event.items.count)
         {
             NSLog(@"\n \n socket onAny event Dictonary:::%@",[event.items objectAtIndex:0]);
             
             if (!_registered)////Need to update code
             {
                 ////////Register UserID
                 _scoketID=[[event.items objectAtIndex:0] valueForKey:@"id"];
                 if (_scoketID !=nil)
                 {
                     
                     NSLog(@"\n \n _scoketID:::%@",_scoketID);
                     
                     if (self.currentUser!= nil )
                     {
                         ///////////Register users scoket
                         NSDictionary *userInfo = @{@"SocketId":_scoketID, @"currentUser":self.currentUser.userId, @"otherUser":self.otherUser_id};
                         NSArray *userArr=[NSArray arrayWithObjects:userInfo, nil];
                         [self.socketClient emit:@"chatMessage" withItems:userArr];
                     }
                     _registered = YES;
                 }
                 else
                 {
                     NSLog(@"\n \n Failed to register chat");
                 }

             }
             else
             {
                 //////update map with received data
                  NSLog(@"\n \n Update Map with Received data");
                 
                 ///////////Sample users scoket
                 NSDictionary *userInfo = @{@"user":_scoketID};
                 NSArray *userArr=[NSArray arrayWithObjects:userInfo, nil];
                 [self.socketClient emit:@"test" withItems:userArr];

             }
             
         }
         else
         {
             NSLog(@"\n \n No Event ");
         }
         
     }
     ];
    
    //////Scoket Connected
    [ self.socketClient on:@"connect" callback:^(NSArray* data, SocketAckEmitter* ack)
     {
         NSLog(@"\n \n socket connected:::data====%@ \n SocketAckEmitter====%@ ",data,ack.description);
         
         

         
     }];
    
    /////Scoket disconnected
    [self.socketClient on:@"disconnect" callback:^(NSArray* data, SocketAckEmitter* ack)
     {
         
         NSLog(@"\n \n socket disconnect:::data====%@ \n SocketAckEmitter====%@ ",data,ack);
         
         
         if( self.currentUser!= nil)
         {
             if (self.socketClient.status == SocketIOClientStatusClosed && [RSUtils isNetworkReachable])
             {
                 [self initiateClientSocket];
             }
         }
         
     }];
}

-(void)updateVehicleLocationCoordinates:(CLLocationCoordinate2D)locationCoordinates
{
    
    NSLog(@"\n \n updatedLocation===%f, %f",locationCoordinates.latitude,locationCoordinates.longitude);
    
    
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
    NSLog(@"set position");
    
    CGPoint mapPoint=[_rideMapView.projection pointForCoordinate: coordinates];
    
    CGPoint toPos;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
    {
        
        toPos = [_rideMapView.projection pointForCoordinate: coordinates];
    }
    
    CLLocationCoordinate2D currentCoordinate = [_rideMapView.projection coordinateForPoint:mapPoint];
    CLLocationCoordinate2D previousCoordinate = [_rideMapView.projection coordinateForPoint:previousPoint];
    
    
    //    [self setTransform:CGAffineTransformMakeRotation([self getHeadingForDirectionFromCoordinate:previousCoordinate toCoordinate: currentCoordinate])];
    
    
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
    
    
    NSLog(@"%f",deg);
    
    
    return degreesToRadians(deg);
    
}
@end


