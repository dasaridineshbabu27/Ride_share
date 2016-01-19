//
//  ViewController.m
//  RideShare
//
//  Created by Reddy on 04/01/16.
//  Copyright © 2016 Reddy. All rights reserved.
//

#import "RLHomeViewController.h"
#import "RSConstants.h"
#import "RSLocationPickerController.h"
#import "UIViewController+AMSlideMenu.h"
#import "AppDelegate.h"

@interface RLHomeViewController ()

@end

@implementation RLHomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[_mapViewHolder settings] setMyLocationButton:YES];    
    self.markers = [[NSMutableArray alloc] init];
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    [locationManager requestWhenInUseAuthorization];
    [locationManager requestAlwaysAuthorization];
    
    pickerHolderTopConstraint.constant = self.view.frame.size.height;
    [_timePickerHolderView updateConstraintsIfNeeded];
    
    self.title = @"Ride Share";
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(menuClicked)];
    leftButton.image = [UIImage imageNamed:@"Hamburger_menu"];
    self.navigationItem.leftBarButtonItem = leftButton;
    
    self.pickTimeButton.layer.borderColor = [UIColor blackColor].CGColor;
    self.pickTimeButton.layer.borderWidth = 1.0;
    self.pickTimeButton.layer.cornerRadius = 4.0;
    
    self.btnRequest.layer.borderColor = [UIColor blackColor].CGColor;
    self.btnRequest.layer.borderWidth = 1.0;
    self.btnRequest.layer.cornerRadius = 4.0;
    _btnPickup.selected = YES;
}

- (NSUInteger)numberOfComponentsInPickerView:(UIPickerView*)pickerView
{
    return 1;
}

- (NSUInteger)pickerView:(UIPickerView*)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 10;
}
-(NSString*)pickerView:(UIPickerView*)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return @"sdfs";
}

- (void)menuClicked
{
    [[self mainSlideMenu] openLeftMenu];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    if (delegate.isUserLoggedIn == NO)
    {
        [self performSegueWithIdentifier:@"MoveToLoginSegue" sender:self];
    }
    
//    NSUserDefaults *appDefaults = [NSUserDefaults standardUserDefaults];
//    BOOL isUserLoggedIn = [appDefaults boolForKey:keyIsUserLoggedIn];
//    if (!isUserLoggedIn)
//    {
//        [self performSegueWithIdentifier:@"MoveToLoginSegue" sender:self];
//        return;
//    }
//    _mapView.delegate = self;
    
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
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude zoom:13];
    _mapViewHolder.camera = camera;
    _mapViewHolder.myLocationEnabled = YES;
    
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
    marker.title = @"Source";
//    marker.snippet = @"adfsaf";
    marker.map = _mapViewHolder;
    
    sourceCoordinate = marker.position;
    destinationCoordinate = marker.position;
    
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

- (IBAction)pickTimeAction:(id)sender
{
    pickerHolderTopConstraint.constant = self.view.frame.size.height;
    [_timePickerHolderView layoutIfNeeded];
}

- (IBAction)showTimePicker:(id)sender
{
//    pickerHolderTopConstraint.constant = 0;
}

- (IBAction)requestAction:(id)sender
{
    if (_btnPickup.selected == YES)
    {
        NSString *alertMsg = nil;
        
        if (_sourceLocationInput.text.length == 0 )
        {
            alertMsg = @"Please choose your starting Location.";
        }
        else if (_destinationLocationInput.text.length == 0)
        {
            alertMsg = @"Please choose your Destination Location.";
        }
        if(alertMsg.length)
        {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:alertMsg preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSLog(@"Ok clicked");
            }];
            
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:^{
                NSLog(@"Presented");
            }];
            return;
        }
    }
}

- (IBAction)returnedFromLocationPicker:(UIStoryboardSegue*)segue
{
    NSLog(@"%@", segue.sourceViewController);
    
    if ([segue.sourceViewController isKindOfClass: [RSLocationPickerController class]])
    {
        RSLocationPickerController *locationPicker = (RSLocationPickerController*)[segue sourceViewController];
        NSLog(@"Selected Address is : %@",locationPicker.selectedAddress);
        if (_bntPickStartLocation.selected ==  YES)
        {
            _sourceLocationInput.text = [NSString stringWithFormat:@"%@, %@, %@, %@", locationPicker.selectedAddress.locality, locationPicker.selectedAddress.administrativeArea, locationPicker.selectedAddress.country, locationPicker.selectedAddress.postalCode];
            sourceCoordinate = locationPicker.selectedAddress.coordinate;
            [self updateMapView];
        }
        else
        {
            _destinationLocationInput.text = [NSString stringWithFormat:@"%@, %@, %@, %@", locationPicker.selectedAddress.locality, locationPicker.selectedAddress.administrativeArea, locationPicker.selectedAddress.country, locationPicker.selectedAddress.postalCode];
            destinationCoordinate = locationPicker.selectedAddress.coordinate;
            [self updateMapView];
        }
        
        _bntPickStartLocation.selected = NO;
        _btnDestionationLocation.selected = NO;
    }
}

- (void)updateMapView
{
    [self.mapViewHolder clear];
    [self.markers removeAllObjects];
    
    GMSMarker *sourceMarker = [[GMSMarker alloc] init];
    sourceMarker.position = sourceCoordinate;
    sourceMarker.title = @"Source";
    sourceMarker.map = self.mapViewHolder;
    
    GMSMarker *destMarker = [[GMSMarker alloc] init];
    destMarker.position = destinationCoordinate;
    destMarker.title = @"Destination";
//    destMarker.icon = [UIImage imageNamed:@"DestPin"];
    destMarker.map = self.mapViewHolder;
    
    [self.mapViewHolder animateToLocation:sourceCoordinate];
    [self.markers addObject:sourceMarker];
    [self.markers addObject:destMarker];
}

- (void)focusMapToShowAllMarkers
{
    CLLocationCoordinate2D myLocation = ((GMSMarker *)_markers.firstObject).position;
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:myLocation coordinate:myLocation];
    
    for (GMSMarker *marker in _markers)
    {
        bounds = [bounds includingCoordinate:marker.position];
    }
    
    [_mapViewHolder animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds withPadding:15.0f]];
}

- (IBAction)cancelTimePickAction:(id)sender
{
    pickerHolderTopConstraint.constant = self.view.frame.size.height;
}

- (IBAction)pickDestinationLocationAction:(id)sender
{
    _btnDestionationLocation.selected = YES;
}

- (IBAction)pickStartLocationAction:(id)sender
{
    _bntPickStartLocation.selected = YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [_rideCoseInput resignFirstResponder];
    [_sourceLocationInput resignFirstResponder];
    [_destinationLocationInput resignFirstResponder];
}

@end
