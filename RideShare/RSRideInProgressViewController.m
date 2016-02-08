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

@interface RSRideInProgressViewController ()

@property NSMutableArray *points;

@property GMSCoordinateBounds *bounds;
@property CLLocationCoordinate2D updatedLocation;
@property GMSMarker *vehicleMarker;

/////////
@property SIOSocket *socket;
@property BOOL socketIsConnected;


//////////
@property SocketIO *socketIO;



@end

@implementation RSRideInProgressViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
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
    
    /////////
    //[self socketImplementation];
    
    ////////
    [self scoketIOImplememtation];
    
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
    
//    if (self.socketIsConnected)
//    {
//        [self.socket emit: @"location" args: @[
//                                               [NSString stringWithFormat: @"%f,%f", location.coordinate.latitude, location.coordinate.longitude]
//                                               ]];
//    }
    
    
    if (self.socketIO.isConnected)
    {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:[NSString stringWithFormat: @"%f", location.coordinate.latitude] forKey:@"latitude"];
        [dict setObject:[NSString stringWithFormat: @"%f", location.coordinate.longitude] forKey:@"longitude"];
        [self.socketIO sendEvent:@"location" withData:dict];
        
    }
    else
    {
         NSLog(@"\n \n socket.io NOT Connected to update location.");
    }
   

}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//-(void)socketImplementation
//{
//    NSLog(@"\n\nSocket Implementation");
//    
//    [SIOSocket socketWithHost: @"http://192.168.0.100:8082/rides/chat/" response: ^(SIOSocket *socket)
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

-(void)scoketIOImplememtation
{
    _socketIO = [[SocketIO alloc] initWithDelegate:self];
    
    // you can update the resource name of the handshake URL
    // see https://github.com/pkyeck/socket.IO-objc/pull/80
    // [socketIO setResourceName:@"whatever"];
    
    // if you want to use https instead of http
    // socketIO.useSecure = YES;
    
    // pass cookie(s) to handshake endpoint (e.g. for auth)
    
//    NSDictionary *properties = [NSDictionary dictionaryWithObjectsAndKeys:
//                                @"localhost", NSHTTPCookieDomain,
//                                @"/", NSHTTPCookiePath,
//                                @"auth", NSHTTPCookieName,
//                                @"56cdea636acdf132", NSHTTPCookieValue,
//                                nil];
//    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:properties];
//    NSArray *cookies = [NSArray arrayWithObjects:cookie, nil];
//    _socketIO.cookies = cookies;
    
    // connect to the socket.io server that is running locally at port 3000
    [self.socketIO connectToHost:@"http://192.168.0.100:8082/rides/chat/" onPort:3000];
    
}
# pragma mark -
# pragma mark socket.IO-objc delegate methods

- (void) socketIODidConnect:(SocketIO *)socket
{
    NSLog(@"\n \n socket.io connected.");
}

- (void) socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet
{
    NSLog(@"\n \n socket.io didReceiveEvent.");
    
    
//    // test acknowledge
//    SocketIOCallback cb = ^(id argsData)
//    {
//        NSDictionary *response = argsData;
//        // do something with response
//        NSLog(@"ack arrived: %@", response);
//        
//        // test forced disconnect
//        [self.socketIO disconnectForced];
//    };
//    
//    ////////////
//    [self.socketIO sendMessage:@"hello back!" withAcknowledge:cb];
//    
//    // test different event data types
//    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
//    [dict setObject:@"test1" forKey:@"key1"];
//    [dict setObject:@"test2" forKey:@"key2"];
//    [self.socketIO sendEvent:@"welcome" withData:dict];
//    
//    ///////////
//    [self.socketIO sendEvent:@"welcome" withData:@"testWithString"];
//    
//    ///////////
//    NSArray *arr = [NSArray arrayWithObjects:@"test1", @"test2", nil];
//    [self.socketIO sendEvent:@"welcome" withData:arr];
    
    
    //////////////
    self.updatedLocation=CLLocationCoordinate2DMake(14.88888, 134.768586967);
    
    [self updateVehicleLocationCoordinates:self.updatedLocation];
    
}


- (void) socketIO:(SocketIO *)socket didSendMessage:(SocketIOPacket *)packet
{
    NSLog(@"\n \n socket.io didSendMessage.");
}
- (void) socketIO:(SocketIO *)socket didReceiveMessage:(SocketIOPacket *)packet
{
    NSLog(@"\n \n socket.io didReceiveMessage.");
}
- (void) socketIO:(SocketIO *)socket didReceiveJSON:(SocketIOPacket *)packet
{
    NSLog(@"\n \n socket.io didReceiveJSON.");
}



- (void) socketIO:(SocketIO *)socket onError:(NSError *)error
{
    
    NSLog(@"\n \n socket.io onError.");
    
    if ([error code] == SocketIOUnauthorized)
    {
        NSLog(@"not authorized");
    }
    else
    {
        NSLog(@"onError() %@", error);
    }
}


- (void) socketIODidDisconnect:(SocketIO *)socket disconnectedWithError:(NSError *)error
{
    
    NSLog(@"\n \n socket.io disconnectedWithError.");
    NSLog(@"socket.io disconnected. did error occur? %@", error);
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


