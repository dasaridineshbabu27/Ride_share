//
//  RSPickupLocationPickerViewController.m
//  RideShare
//
//  Created by Reddy on 05/02/16.
//  Copyright © 2016 Reddy. All rights reserved.
//

#import "RSPickupLocationPickerViewController.h"
#import "RSUtils.h"
#import "RSServices.h"
#import "AppDelegate.h"
#import "RSConstants.h"
#import "User.h"

@interface RSPickupLocationPickerViewController ()

@end

@implementation RSPickupLocationPickerViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"Ride info is : %@", _rideData);
    addressHolder.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.4];
    self.title = @"Pick Location";
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    [locationManager requestWhenInUseAuthorization];
    [locationManager requestAlwaysAuthorization];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    [self getAddressFromCoordinate:[locations objectAtIndex:0].coordinate];
    CLLocation *location = [locations lastObject];
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude zoom:13];
    _mapViewHolder.camera = camera;
    _mapViewHolder.delegate = self;
    _mapViewHolder.myLocationEnabled = YES;
    [[_mapViewHolder settings] setMyLocationButton:YES];
    [locationManager stopUpdatingLocation];
}

- (void)mapView:(GMSMapView *)mapView
idleAtCameraPosition:(GMSCameraPosition *)position
{
    CLLocationCoordinate2D coord = position.target;
    [self getAddressFromCoordinate:coord];
}

- (void)getAddressFromCoordinate:(CLLocationCoordinate2D)coord
{
    GMSGeocoder *geoCoder = [[GMSGeocoder alloc] init];
    [geoCoder reverseGeocodeCoordinate:coord completionHandler:^(GMSReverseGeocodeResponse *response, NSError *error)
     {
         if (response != nil)
         {
             _selectedAddress = response.firstResult;
             pickUpLocation = _selectedAddress.coordinate;
             NSLog(@"Selected address is : %@", _selectedAddress);
             _addressDisplayer.text = [NSString stringWithFormat:@"%@, %@, %@, %@", _selectedAddress.thoroughfare, _selectedAddress.administrativeArea, _selectedAddress.country, _selectedAddress.postalCode];
         }
     }];
}

- (IBAction)sendPickupRequest:(id)sender
{
    NSDictionary *infoDict = @{@"from_id" : [User currentUser].userId,
                               @"to_id" : [_rideData valueForKey : @"user_id"],
                               @"type" : [NSString stringWithFormat:@"%i", PickMeUp],
                               @"ride_id" : [_rideData objectForKey:@"ride_id"],
                               @"pick_lat" : [NSString stringWithFormat:@"%f", pickUpLocation.latitude],
                               @"pick_lang" : [NSString stringWithFormat:@"%f", pickUpLocation.longitude],
                               @"pick_addr" : _addressDisplayer.text
                               };
    [appDelegate showLoaingWithTitle:@"Loading..."];
    [RSServices processRequestRideViaPush:infoDict completionHandler:^(NSDictionary *response, NSError *error)
     {
         [appDelegate hideLoading];
         NSString *alertMsg = nil;
         if (error != nil)
         {
             alertMsg = error.description;
         }
         else if (response != nil)
         {
             if ([[response objectForKey:kResponseCode] intValue] == kRequestSuccess)
             {
                 NSLog(@"Response success! with info: %@", response);
                 UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Success" message:@"Your request for Picking you up has been intimated to the other end." preferredStyle:UIAlertControllerStyleAlert];
                 
                 UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                     [self.navigationController popViewControllerAnimated:YES];
                 }];
                 [alertController addAction:okAction];
                 [self presentViewController:alertController animated:YES completion:nil];
             }
             else
             {
                 UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                 [RSUtils showAlertWithTitle:@"Falied" message:[response objectForKey:kResponseMessage] actionOne:okAction actionTwo:nil inView:self];
                 return;
             }
         }
         if (alertMsg.length != 0)
         {
             [RSUtils showAlertWithTitle:@"Alert" message:alertMsg actionOne:nil actionTwo:nil inView:self];
         }
     }];
}

@end
