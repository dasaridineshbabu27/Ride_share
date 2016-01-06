//
//  RSLocationPickerController.m
//  RideShare
//
//  Created by Reddy on 05/01/16.
//  Copyright © 2016 Reddy. All rights reserved.
//

#import "RSLocationPickerController.h"
#import "UIViewController+AMSlideMenu.h"

@interface RSLocationPickerController ()

@end

@implementation RSLocationPickerController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    [locationManager requestWhenInUseAuthorization];
    [locationManager requestAlwaysAuthorization];
    
//    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(menuClicked)];
//    leftButton.image = [UIImage imageNamed:@"Hamburger_menu"];
//    self.navigationItem.leftBarButtonItem = leftButton;
}

- (void)menuClicked
{
    [[self mainSlideMenu] openLeftMenu];
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
    
    [GMSCameraPosition cameraWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude zoom:6];
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude zoom:10];
    _mapViewHolder.camera = camera;
    _mapViewHolder.delegate = self;
    _mapViewHolder.myLocationEnabled = YES;
    
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
    marker.title = @"asdfs";
    marker.snippet = @"adfsaf";
    marker.map = _mapViewHolder;
    
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
            GMSAddress *address = response.firstResult;
             NSLog(@"Selected address is : %@", address);
             _addressDisplayer.text = [NSString stringWithFormat:@"%@, %@, %@, %@, %@", address.lines, address.locality, address.administrativeArea, address.country, address.postalCode];
         }
     }];
//    {
//        
//        if (error == nil && [placemarks count] > 0)
//        {
//            CLPlacemark *placemark = [placemarks lastObject];
//            
//            // strAdd -> take bydefault value nil
//            NSString *strAdd = nil;
//            
//            //            if ([placemark.subThoroughfare length] != 0)
//            //                strAdd = placemark.subThoroughfare;
//            
//            if ([placemark.thoroughfare length] != 0)
//            {
//                // strAdd -> store value of current location
//                if ([strAdd length] != 0)
//                    strAdd = [NSString stringWithFormat:@"%@, %@",strAdd,[placemark thoroughfare]];
//                else
//                {
//                    // strAdd -> store only this value,which is not null
//                    strAdd = placemark.thoroughfare;
//                }
//            }
//            
//            if ([placemark.locality length] != 0)
//            {
//                if ([strAdd length] != 0)
//                    strAdd = [NSString stringWithFormat:@"%@, %@",strAdd,[placemark locality]];
//                else
//                    strAdd = placemark.locality;
//            }
//            
//            if ([placemark.administrativeArea length] != 0)
//            {
//                if ([strAdd length] != 0)
//                    strAdd = [NSString stringWithFormat:@"%@, %@",strAdd,[placemark administrativeArea]];
//                else
//                    strAdd = placemark.administrativeArea;
//            }
//            
//            if ([placemark.country length] != 0)
//            {
//                if ([strAdd length] != 0)
//                    strAdd = [NSString stringWithFormat:@"%@, %@",strAdd,[placemark country]];
//                else
//                    strAdd = placemark.country;
//            }
//            
//            if ([placemark.postalCode length] != 0)
//            {
//                if ([strAdd length] != 0)
//                    strAdd = [NSString stringWithFormat:@"%@, %@",strAdd,[placemark postalCode]];
//                else
//                    strAdd = placemark.postalCode;
//            }
//            _addressDisplayer.text = strAdd;
//            NSLog(@"Address is : %@", strAdd);            
//        }
//    }];
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
