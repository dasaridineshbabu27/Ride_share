//
//  ViewController.m
//  RideShare
//
//  Created by Reddy on 04/01/16.
//  Copyright © 2016 Reddy. All rights reserved.
//

#import "RLHomeViewController.h"
#import "RSConstants.h"
#import "UIViewController+AMSlideMenu.h"

@interface RLHomeViewController ()

@end
@implementation RLHomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(menuClicked)];
    leftButton.image = [UIImage imageNamed:@"Hamburger_menu"];
    self.navigationItem.leftBarButtonItem = leftButton;
    
    self.pickTimeButton.layer.borderColor = [UIColor blackColor].CGColor;
    self.pickTimeButton.layer.borderWidth = 1.0;
    self.pickTimeButton.layer.cornerRadius = 4.0;
    
    self.btnRequest.layer.borderColor = [UIColor blackColor].CGColor;
    self.btnRequest.layer.borderWidth = 1.0;
    self.btnRequest.layer.cornerRadius = 4.0;    
    
    // Do any additional setup after loading the view.
    _btnPickup.selected = YES;
    
//    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.86
//                                                            longitude:151.20
//                                                                 zoom:6];
//    _mapViewHolder.camera = camera;
//    _mapViewHolder.myLocationEnabled = YES;
//    
//    // Creates a marker in the center of the map.
//    GMSMarker *marker = [[GMSMarker alloc] init];
//    marker.position = CLLocationCoordinate2DMake(-33.86, 151.20);
//    marker.title = @"Sydney";
//    marker.snippet = @"Australia";
//    marker.map = _mapViewHolder;
    
//    NSUserDefaults *appDefaults = [NSUserDefaults standardUserDefaults];
//    BOOL isUserLoggedIn = [appDefaults boolForKey:keyIsUserLoggedIn];    
//    if (!isUserLoggedIn)
//    {
//        return;
//    }
}

- (void)menuClicked
{
    [[self mainSlideMenu] openLeftMenu];
}



-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    NSUserDefaults *appDefaults = [NSUserDefaults standardUserDefaults];
//    BOOL isUserLoggedIn = [appDefaults boolForKey:keyIsUserLoggedIn];
//    if (!isUserLoggedIn)
//    {
//        [self performSegueWithIdentifier:@"MoveToLoginSegue" sender:self];
//        return;
//    }
    
//    _mapView.delegate = self;
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    [locationManager requestWhenInUseAuthorization];
    [locationManager requestAlwaysAuthorization];
    
//    _mapView.showsUserLocation = YES;
//    [_mapView setMapType:MKMapTypeStandard];
//    [_mapView setZoomEnabled:YES];
//    [_mapView setScrollEnabled:YES];
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
    [self getAddressFromCoordinate:[locations objectAtIndex:0]];
    CLLocation *location = [locations lastObject];
    
    [GMSCameraPosition cameraWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude zoom:6];
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude zoom:10];
    _mapViewHolder.camera = camera;
    _mapViewHolder.myLocationEnabled = YES;
    
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
    marker.title = @"asdfs";
    marker.snippet = @"adfsaf";
    marker.map = _mapViewHolder;
    
    [locationManager stopUpdatingLocation];
}

- (void)getAddressFromCoordinate:(CLLocation*)location
{
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:location  completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {

        if (error == nil && [placemarks count] > 0)
        {
           CLPlacemark *placemark = [placemarks lastObject];
            
            // strAdd -> take bydefault value nil
            NSString *strAdd = nil;
            
//            if ([placemark.subThoroughfare length] != 0)
//                strAdd = placemark.subThoroughfare;
            
            if ([placemark.thoroughfare length] != 0)
            {
                // strAdd -> store value of current location
                if ([strAdd length] != 0)
                    strAdd = [NSString stringWithFormat:@"%@, %@",strAdd,[placemark thoroughfare]];
                else
                {
                    // strAdd -> store only this value,which is not null
                    strAdd = placemark.thoroughfare;
                }
            }
            
            if ([placemark.locality length] != 0)
            {
                if ([strAdd length] != 0)
                    strAdd = [NSString stringWithFormat:@"%@, %@",strAdd,[placemark locality]];
                else
                    strAdd = placemark.locality;
            }
            
            if ([placemark.administrativeArea length] != 0)
            {
                if ([strAdd length] != 0)
                    strAdd = [NSString stringWithFormat:@"%@, %@",strAdd,[placemark administrativeArea]];
                else
                    strAdd = placemark.administrativeArea;
            }
            
            if ([placemark.country length] != 0)
            {
                if ([strAdd length] != 0)
                    strAdd = [NSString stringWithFormat:@"%@, %@",strAdd,[placemark country]];
                else
                    strAdd = placemark.country;
            }

            if ([placemark.postalCode length] != 0)
            {
                if ([strAdd length] != 0)
                    strAdd = [NSString stringWithFormat:@"%@, %@",strAdd,[placemark postalCode]];
                else
                    strAdd = placemark.postalCode;
            }
            
            NSLog(@"Address is : %@", strAdd);
            _sourceLocationInput.text = strAdd;
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pickingToggleAction:(UIButton*)sender
{
    if (sender == _btnPickup)
    {
        _btnPickup.selected = YES;
        _btnPickMeUp.selected = NO;
        _rideCoseInput.hidden = NO;
    }
    else
    {
        _btnPickup.selected = NO;
        _btnPickMeUp.selected = YES;
        _rideCoseInput.hidden = YES;
    }
}

- (IBAction)pickTimeAction:(id)sender {
}
- (IBAction)requestAction:(id)sender {
}
@end
