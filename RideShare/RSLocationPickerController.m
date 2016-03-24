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
   // self.canDisplayBannerAds = YES;
    
    addressHolder.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.4];
    self.title = @"Pick Location";    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    [locationManager requestWhenInUseAuthorization];
    [locationManager requestAlwaysAuthorization];
    
//    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(menuClicked)];
//    leftButton.image = [UIImage imageNamed:@"Hamburger_menu"];
//    self.navigationItem.leftBarButtonItem = leftButton;
    
    ////Ads
    (appDelegate).googleAdIsVisible=NO;
    [self updateUserInterface:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateUserInterface:)
                                                 name:@"updateUserInterface" object:nil];
}
-(void)integrateAds
{
    //iAds Implementation
    //[appDelegate iAdIntegration];
    //[appDelegate iAdIntegrationwith:<#(ADBannerView *)#> andviewController:self];
    
    
    //Google Ads Implementation
    //[appDelegate googleAdsIntegration];
    [appDelegate googleAdsIntegrationWith:self.googleAdBanner andviewController:self];
    
    //LARSAd Implementation
    //[[LARSAdController sharedManager] addAdContainerToView:self.view withParentViewController:self];
    //[[LARSAdController sharedManager] addAdContainerToViewInViewController:self];
    
}
-(void)updateUserInterface:(NSNotification *)notification
{
    if ((appDelegate).googleAdIsVisible)
    {
        _googleAdBanner.hidden=NO;
        _googleAdbottomConstraint.constant=0;
    }
    else
    {
        _googleAdBanner.hidden=YES;
        _googleAdbottomConstraint.constant=-50;
    }
    [self.view layoutIfNeeded];
}
-(void)viewWillAppear:(BOOL)animated
{
    [self integrateAds];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateUserInterface" object:nil];
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
             //NSLog(@"Selected address is : %@", _selectedAddress);
             _addressDisplayer.text = [NSString stringWithFormat:@"%@, %@, %@", _selectedAddress.thoroughfare, _selectedAddress.locality, _selectedAddress.administrativeArea];
         }
     }];
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
