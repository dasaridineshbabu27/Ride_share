//
//  RSRideInProgressViewController.m
//  RideShare
//
//  Created by Reddy on 06/02/16.
//  Copyright © 2016 Reddy. All rights reserved.
//

#import "RSRideInProgressViewController.h"
#define CLCOORDINATES_EQUAL( coord1, coord2 ) (coord1.latitude == coord2.latitude && coord1.longitude == coord2.longitude)

@interface RSRideInProgressViewController ()

@end

@implementation RSRideInProgressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    [locationManager requestWhenInUseAuthorization];
    [locationManager requestAlwaysAuthorization];
    
    [self addPinOnMapAt:_pickUpLocation];
    [self addPinOnMapAt:_destinationCoordinate];
    
    // Do any additional setup after loading the view.
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status ==  kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse)
    {
        [locationManager startUpdatingLocation];
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
    [locationManager stopUpdatingLocation];
}

- (void)addPinOnMapAt:(CLLocationCoordinate2D)coordinate
{
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = coordinate;
    marker.title = @"Origination";
    
    UIImage *markerImage = nil;
    if (CLCOORDINATES_EQUAL(_pickUpLocation, coordinate))
    {
        markerImage = [UIImage imageNamed:@"Location"];
        marker.snippet = @"Pick Up location";
    }
    else
    {
        markerImage = [UIImage imageNamed:@"map_icon"];
        marker.snippet = @"Destination";
    }
    marker.icon = markerImage;
    marker.map = _rideMapView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
