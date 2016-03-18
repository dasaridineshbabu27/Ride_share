//
//  HGMovingAnnotationSampleViewController.m
//  HGMovingAnnotationSample
//
//  Created by Rotem Rubnov on 14/3/2011.
//	Copyright (C) 2011 100 grams software
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//	THE SOFTWARE.
//
//
#define POSITIONKEY @"positionAnimation"
#define BOUNDSKEY @"boundsAnimation"

#define degreesToRadians(x) (M_PI * x / 180.0)
#define radiandsToDegrees(x) (x * 180.0 / M_PI)

#import "HGMovingAnnotationSampleViewController.h"
#import "HGMovingAnnotation.h"
#import "HGMovingAnnotationView.h"
#import "AppDelegate.h"
#import <SocketIOClientSwift/SocketIOClientSwift-Swift.h>
@interface HGMovingAnnotationSampleViewController ()

@property NSMutableArray *points;



@property NSString *latitude;
@property NSString *longitude;
@property NSDictionary *locationInfo;
@property NSArray *locationArr;

@property NSDictionary *receivedlocationInfo;
@property  CLLocationDegrees myLatitude ;
@property CLLocationDegrees myLongitude;
@property CLLocationCoordinate2D newCoordinate;


@property SocketIOClient *socketClient;
@property SocketIOClient *socketClientRoom;
@property NSString *scoketID;

@property HGMapPath *path;
@property NSString *pathString;
@property HGMovingAnnotation *movingObject;

@property CLLocation *currentLocation ;

@property HGMovingAnnotationView *annotationViewVehicle;
@property MKMapPoint lastReportedLocation;
@property MKMapPoint previousPoint;
@property BOOL created;
- (void) setPosition : (id) pos;

@end

@implementation HGMovingAnnotationSampleViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.currentUser = [User currentUser];
    _mapView.delegate=self;
    self.navigationItem.title = @"Ride";
    
    UIBarButtonItem *finishButton = [[UIBarButtonItem alloc] initWithTitle:@"Finish" style:UIBarButtonItemStylePlain target:self action:@selector(finishRideClicked)];
    
    UIBarButtonItem *testSend = [[UIBarButtonItem alloc] initWithTitle:@"test" style:UIBarButtonItemStylePlain target:self action:@selector(testSending)];
    
    if ([[_notification valueForKey:@"is_rider"] isEqualToString:@"0"] && [[_notification valueForKey:@"type"] isEqualToString:@"2"]  )
    {
        NSLog(@"\n RIDERRRRRRRRRRR");
        
        self.navigationItem.hidesBackButton = YES;
        self.navigationItem.rightBarButtonItem = finishButton;
        //self.navigationItem.rightBarButtonItems = @[finishButton,testSend];
   
    }
    else if ([[_notification valueForKey:@"is_rider"] isEqual:@"1"])
    {
        self.navigationItem.hidesBackButton = YES;
        self.navigationItem.rightBarButtonItem = finishButton;
        //self.navigationItem.rightBarButtonItems = @[finishButton,testSend];
        
    }
    else
    {
        self.navigationItem.hidesBackButton = NO;
        [finishButton setEnabled:NO];
    }
    
    
    NSLog(@"\n \n currentUserId=== %@",_currentUser.userId);
    NSLog(@"\n \n otherUser_id=== %@",_otherUser_id);
    NSLog(@"\n \n _ride_info=== %@",_ride_info);
    NSLog(@"\n \n _notification=== %@",_notification);
    //    NSLog(@"\n \n pickUpLocation===%f, %f",_pickUpLocation.latitude,_pickUpLocation.longitude);
    //    NSLog(@"\n \n startCoordinate===%f, %f",_startCoordinate.latitude,_startCoordinate.longitude);
    //    NSLog(@"\n \n destinationCoordinate===%f, %f",_destinationCoordinate.latitude,_destinationCoordinate.longitude);
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager requestAlwaysAuthorization];
    
    
    _created=NO;
    [self addAllPins];
    
    [self initiateClientSocket];
    
    
}
-(void)viewWillAppear:(BOOL)animated
{
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    
}

-(void)addAllPins
{
   [self addPinWithTitle:@"Origin" andCoordinate:_startCoordinate];
    [self addPinWithTitle:@"Destination" andCoordinate:_destinationCoordinate];
    [self addPinWithTitle:@"Pick Up Location" andCoordinate:_pickUpLocation];
    
    
    
}
-(void)addPinWithTitle:(NSString *)title andCoordinate:(CLLocationCoordinate2D)coordinate
{
    MKPointAnnotation *mapPin = [[MKPointAnnotation alloc] init];
    mapPin.title = title;
    mapPin.coordinate = coordinate;
    [_mapView addAnnotation:mapPin];
    
    [self showAllAnnotations];
    
    
}
-(void)showAllAnnotations
{
    MKMapRect zoomRect = MKMapRectNull;
    for (id <MKAnnotation> annotation in _mapView.annotations)
    {
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
        zoomRect = MKMapRectUnion(zoomRect, pointRect);
    }
    [_mapView setVisibleMapRect:zoomRect animated:YES];
    _mapView.camera.altitude *= 2.0;
}
- (void)testSending
{
    //Testing Scoket
    double your_latitiude_value = 8.391916;
    double your_longitude_value = 77.094315;
    CLLocation *myLocation = [[CLLocation alloc] initWithLatitude:your_latitiude_value longitude:your_longitude_value];
    [self updateLocationData:_currentLocation];
    
    [self moveVehicle];
}
-(void)moveVehicle
{
    // create the path for the moving object
    NSString *nmeaLogPath = [[NSBundle mainBundle] pathForResource:@"path" ofType:@"nmea"];
    
    HGMapPath *path = [[HGMapPath alloc] initFromFile:nmeaLogPath];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLoadPathh:) name:kPathLoadedNotification object:path];
}
- (void) didLoadPathh : (NSNotification*) notification
{
    // initialize our moving object
    HGMapPath *path = (HGMapPath*)[notification object];
    
    _movingObject = [[HGMovingAnnotation alloc] initWithMapPath:path] ; //the annotation retains its path
    
    // add the annotation to the map
    [_mapView addAnnotation:_movingObject];
    
    // zoom the map around the moving object
    MKCoordinateSpan span = MKCoordinateSpanMake(0.01, 0.01);
    
    MKCoordinateRegion region = MKCoordinateRegionMake(MKCoordinateForMapPoint(_movingObject.currentLocation), span);
    [_mapView setRegion:region animated:YES];
    
    // start moving the object
    [_movingObject start];
}





- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}





#pragma mark -
#pragma mark MKMapViewDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status ==  kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse)
    {
        [self.locationManager startUpdatingLocation];
    }
}
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    
    _currentLocation = [locations lastObject];
    _mapView.delegate = self;
     _mapView.showsUserLocation = YES;
    
    ///////Updating Location////////
    
    if ([[_notification valueForKey:@"is_rider"] isEqualToString:@"0"] && [[_notification valueForKey:@"type"] isEqualToString:@"2"]  )
    {
        NSLog(@"\n RIDERRRRRRRRRRR");
        
        [self updateLocationData:_currentLocation];
        
        //////////////
        _lastReportedLocation=MKMapPointForCoordinate(_currentLocation.coordinate);
        [_annotationViewVehicle performSelectorOnMainThread:@selector(setPosition:) withObject:[NSValue valueWithPointer:&_lastReportedLocation] waitUntilDone:YES];


    }
    else if ([[_notification valueForKey:@"is_rider"] isEqual:@"1"])
    {
        [self updateLocationData:_currentLocation];
        
        //////////////
        _lastReportedLocation=MKMapPointForCoordinate(_currentLocation.coordinate);
        [_annotationViewVehicle performSelectorOnMainThread:@selector(setPosition:) withObject:[NSValue valueWithPointer:&_lastReportedLocation] waitUntilDone:YES];
    }
    
    
    
    
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(HGMovingAnnotation*)annotation;
{
    NSString *kMovingAnnotationViewId = [NSString stringWithFormat:@"%@",annotation.title];
    NSLog(@"kMovingAnnotationViewId %@",kMovingAnnotationViewId);
    
    HGMovingAnnotationView *annotationView = (HGMovingAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:kMovingAnnotationViewId];
    
    if (!annotationView)
    {
        annotationView = [[HGMovingAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kMovingAnnotationViewId];
    }
    
    //configure the annotation view
    if ([kMovingAnnotationViewId isEqual: @"Origin"])
    {
        
        annotationView.image = [UIImage imageNamed:@"Green"];

       
    }
    else if ([kMovingAnnotationViewId isEqual: @"Destination"])
    {
        annotationView.image = [UIImage imageNamed:@"Red"];
    }
    else if ([kMovingAnnotationViewId isEqual: @"Pick Up Location"])
    {
        
        annotationView.image = [UIImage imageNamed:@"Orange"];
    }
    else if ([kMovingAnnotationViewId isEqual: @"Current Location"])
    {
        
        if ([[_notification valueForKey:@"is_rider"] isEqualToString:@"0"] && [[_notification valueForKey:@"type"] isEqualToString:@"2"]  )
        {
            NSLog(@"\n RIDERRRRRRRRRRR");
            annotationView.image = [UIImage imageNamed:@"Car_Black"];
            _annotationViewVehicle =annotationView;

        }
         else if ([[_notification valueForKey:@"is_rider"] isEqual:@"1"])
        {
            annotationView.image = [UIImage imageNamed:@"Car_Black"];
            _annotationViewVehicle =annotationView;
        }
        else
        {
            return nil;
        }

       
        //return nil;
    }
    else if ([kMovingAnnotationViewId isEqual: @"Vehicle"])
    {
        annotationView.image = [UIImage imageNamed:@"Car_Black"];
        _annotationViewVehicle =annotationView;
        _created=YES;
 
    }
  
    annotationView.mapView = mapView;
    return annotationView;
    
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

-(void)finishRide
{
  
    
    NSDictionary *infoDict = @{@"track_id" : [ _notification valueForKey:@"track_id"], @"ride_id" : [_notification valueForKey:@"ride_id"], @"to_id":[_notification valueForKey:@"from_id"]};
    
    
    [appDelegate showLoaingWithTitle:nil];
    [RSServices processFinishride:infoDict completionHandler:^(NSDictionary * response, NSError *error)
     {
         [appDelegate hideLoading];
         if (error != nil)
         {
             [RSUtils showAlertForError:error inView:self];
         }
         else if (response != nil)
         {
             if ([[response objectForKey:kResponseCode] intValue] == kRequestSuccess)
             {

                 NSLog(@"Received response  : %@", response);
                 
                 //_created=NO;
                 [self.locationManager stopUpdatingLocation];
                 [self disconnectClientSocket];
                 [self disconnectClientSocketRoom];
                 
                 UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"RideShare" message:@"Your ride finished successfully" preferredStyle:UIAlertControllerStyleAlert];
                 
                 UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                            {
                                                
                                                /////////////////
                                                
                                                UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                                                         bundle: nil];
                                                UIViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"RSHomeViewController"];
                                                
                                                [self.navigationController pushViewController:vc  animated:YES];
                                             
                                            }];
                 
                 
                 [alertController addAction:okAction];
                 
                 
                 [self presentViewController:alertController animated:YES completion:nil];
                 
             }
             else
             {
                 UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                            {
                                                [self.navigationController popViewControllerAnimated:YES];
                                            }];
                 [RSUtils showAlertWithTitle:@"Falied" message:[response objectForKey:kResponseMessage] actionOne:okAction actionTwo:nil inView:self];
                 return;
             }
         }
     }];
}
- (void)finishRideClicked
{
    NSLog(@"\n Finish button tapped");
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"RideShare" message:@"Do you want to close your ride?" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Finish" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                               {
                                   
                                   [self finishRide];
                                   
                               }];
    
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                             {
                                 [alertController dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    
    [alertController addAction:okAction];
    [alertController addAction:cancel];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
    
    
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
    //////// Real code http://192.168.0.104:3000
    NSURL* scoketURL = [[NSURL alloc] initWithString:@"http://202.153.46.234:3000"];
    self.socketClient = [[SocketIOClient alloc] initWithSocketURL:scoketURL options:@{@"log": @NO, @"forcePolling": @NO}];
    [self.socketClient connect];
    self.socketClient.reconnects = NO;
    [self joinRoom];
    
}

-(void)initiateClientSocketRoom
{
    //////// Real code
    NSURL* scoketURLRoom = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://202.153.46.234:3000/%@",[self createRoom]] ];
    NSLog(@"scoketURLRoom===%@",scoketURLRoom);
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
         NSLog(@"\n \n ROOM event:::%@ \n count:::%lu",event,event.items.count);
         
         
         //////Scoket Connected
         [ self.socketClientRoom on:@"connect" callback:^(NSArray* data, SocketAckEmitter* ack)
          {
              NSLog(@"\n \n ROOM CONNECT data====%@   SocketAckEmitter====%@ \n",data,ack.description);
              
              
              /////Scoket sendmessage
              [self.socketClientRoom on:@"sendmessage" callback:^(NSArray* data, SocketAckEmitter* ack)
               {
                   NSLog(@"\n \n ROOM SEND MESSAGE:::data====%@  SocketAckEmitter====%@ ",data,ack.description);
                   
                   if (data.count!=0)
                   {
                       _receivedlocationInfo=[data objectAtIndex:0];
                       
                       if (_currentUser.userId == [_receivedlocationInfo objectForKey:@"receiver_id"] )
                       {
                           
                           NSString *info=[NSString stringWithFormat:@"latitude=%@\nlongitude=%@\nreceiver_id=%@\nsender_id=%@",[_receivedlocationInfo objectForKey:@"latitude"],[_receivedlocationInfo objectForKey:@"longitude"],[_receivedlocationInfo objectForKey:@"receiver_id"],[_receivedlocationInfo objectForKey:@"sender_id"]];
                           NSLog(@"\n \n SUCCESS:::%@",info);
                         
                           //creating latitude and longitude for location
                           _myLatitude = [[_receivedlocationInfo objectForKey:@"latitude"] doubleValue];
                           _myLongitude = [[_receivedlocationInfo objectForKey:@"longitude"] doubleValue];
                           _newCoordinate = CLLocationCoordinate2DMake(_myLatitude, _myLongitude);
                           
                
                           if (!_created)
                           {
                               [self addPinWithTitle:@"Vehicle" andCoordinate:_newCoordinate];
                               //[self showAllAnnotations];
                           }
                           
                
                           _lastReportedLocation=MKMapPointForCoordinate(_newCoordinate);
                           [_annotationViewVehicle performSelectorOnMainThread:@selector(setPosition:) withObject:[NSValue valueWithPointer:&_lastReportedLocation] waitUntilDone:YES];
                           
                           
                       }
                       else
                       {
                           NSString *info=[NSString stringWithFormat:@"latitude=%@\nlongitude=%@\nreceiver_id=%@\nsender_id=%@",[_receivedlocationInfo objectForKey:@"latitude"],[_receivedlocationInfo objectForKey:@"longitude"],[_receivedlocationInfo objectForKey:@"receiver_id"],[_receivedlocationInfo objectForKey:@"sender_id"]];
                           NSLog(@"\n \n FAILURE:::%@",info);
                         
                       }
                       
                   }
                   else
                   {
                       
                   }
                   
               }];
              /////Scoket disconnected
              [self.socketClientRoom on:@"disconnect" callback:^(NSArray* data, SocketAckEmitter* ack)
               {
                   NSLog(@"\n \n ROOM DISCONNECT:::data====%@  SocketAckEmitter====%@ ",data,ack.description);
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

- (void) setPosition : (id) posValue;
{
    NSLog(@"set position");
    
    //extract the mapPoint from this dummy (wrapper) CGPoint struct
    MKMapPoint mapPoint = *(MKMapPoint*)[(NSValue*)posValue pointerValue];
    CLLocationCoordinate2D coord = MKCoordinateForMapPoint(mapPoint);
    
    
    ////////////////////
    CGPoint toPos;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
    {
        
        toPos = [_mapView convertCoordinate:coord toPointToView:_mapView];
    }
    
    //////////////////
    else
    {
        CGFloat zoomFactor =  _mapView.visibleMapRect.size.width / _mapView.bounds.size.width;
        toPos.x = mapPoint.x/zoomFactor;
        toPos.y = mapPoint.y/zoomFactor;
    }
    
    
    ///////////////////
    [_annotationViewVehicle setTransform:CGAffineTransformMakeRotation([self getHeadingForDirectionFromCoordinate:MKCoordinateForMapPoint(_previousPoint) toCoordinate: MKCoordinateForMapPoint(mapPoint)])];
    
    
    
    
    if (MKMapRectContainsPoint(_mapView.visibleMapRect, mapPoint))
    {
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
        
        animation.fromValue = [NSValue valueWithCGPoint:_annotationViewVehicle.center];
        animation.toValue = [NSValue valueWithCGPoint:toPos];
        animation.duration = 1.0;
        animation.delegate = self;
        animation.fillMode = kCAFillModeForwards;
        //[self.layer removeAllAnimations];
        [_annotationViewVehicle.layer addAnimation:animation forKey:POSITIONKEY];
        
//        NSLog(@"setPosition ANIMATED %x from (%f, %f) to (%f, %f)", self, self.center.x, self.center.y, toPos.x, toPos.y);
    }
    
    _annotationViewVehicle.center = toPos;
    
    _previousPoint = mapPoint;
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
        NSLog(@"\n \n ROOM NOT CONNECTED to update location.");
        //[self initiateClientSocketRoom];
    }
    
}

@end
