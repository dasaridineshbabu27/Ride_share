//
//  ViewController.m
//  RideShare
//
//  Created by Reddy on 04/01/16.
//  Copyright © 2016 Reddy. All rights reserved.
//

#import "RSHomeViewController.h"
#import "RSConstants.h"
#import "RSLocationPickerController.h"
#import "UIViewController+AMSlideMenu.h"
#import "AppDelegate.h"
#import "RSUtils.h"
#import "User.h"
#import "RSServices.h"
#import "RideCell.h"
#import "RSPickupLocationPickerViewController.h"

@interface RSHomeViewController ()

@end

@implementation RSHomeViewController
@synthesize currentUser;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tempRideInfo = [[NSMutableDictionary alloc] init];
    
    currentUser = [User currentUser];
    self.dataSource = [[NSMutableArray alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(filterOptionSelected:) name:@"FilterOptionSelectedNotification" object:nil];
    
    _containerTrailingConstraint.constant = -200;
    [filterContainerView setNeedsLayout];
    [self.navigationController.navigationItem setHidesBackButton:YES animated:YES];
//    _rideCoseInput.text = @"0";
    canExecuteWillAppear = YES;
    _timePicker.minimumDate = [NSDate date];
    _currentRides = [[NSMutableArray alloc] init];
    [_pickTimeButton setTitle:[RSUtils getDateStringFormDate:_timePicker.date withFormat:nil] forState:UIControlStateNormal];
    _timePickerHolderView.backgroundColor = [UIColor whiteColor];
    [[_mapViewHolder settings] setMyLocationButton:YES];    
    self.markers = [[NSMutableArray alloc] init];
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    [locationManager requestWhenInUseAuthorization];
    [locationManager requestAlwaysAuthorization];
    
    pickerHolderTopConstraint.constant = self.view.frame.size.height;
    _ridesHolderTopConstraint.constant = self.view.frame.size.height;
    [_timePickerHolderView updateConstraintsIfNeeded];
    
    _mapViewHolder.delegate = self;
    
    self.title = @"Ride Share";
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(menuClicked)];
    leftButton.image = [UIImage imageNamed:@"Hamburger_menu"];
    self.navigationItem.leftBarButtonItem = leftButton;

//    rightButton = [[UIBarButtonItem alloc] initWithTitle:@"List" style:UIBarButtonItemStylePlain target:self action:@selector(listClicked:)];
//    leftButton.image = [UIImage imageNamed:@"Hamburger_menu"];
//    
//    
//    
//    UIBarButtonItem *filter = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(filterClicked:)];
//    filter.image = [UIImage imageNamed:@"Funnel.png"];
//    //[filter setBackgroundVerticalPositionAdjustment:-20.0f forBarMetrics:UIBarMetricsDefault];
//    
//    
//    
//    UIBarButtonItem *refreshBtn = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(refreshClicked:)];
//    refreshBtn.image = [UIImage imageNamed:@"refresh.png"];
//    
//    self.navigationItem.rightBarButtonItems = @[rightButton, filter, refreshBtn];
    
    
    
    self.pickTimeButton.layer.borderColor = [UIColor blackColor].CGColor;
    self.pickTimeButton.layer.borderWidth = 1.0;
    self.pickTimeButton.layer.cornerRadius = 4.0;
    
    self.rideCoseInput.layer.borderColor = [UIColor blackColor].CGColor;
    self.rideCoseInput.layer.borderWidth = 1.0;
    self.rideCoseInput.layer.cornerRadius = 4.0;
    
//    self.btnRequest.layer.borderColor = [UIColor blackColor].CGColor;
   // self.btnRequest.layer.borderWidth = 1.0;
   // self.btnRequest.layer.cornerRadius = 5.0;
    
   // _btnPickup.selected = YES;
     _rideViewHightConstraint.constant=0;
}

- (IBAction)refreshClicked:(id)sender
{
    [self fetchRidesAroundMe];
}

-(IBAction)filterClicked:(id)sender
{
    if (_containerTrailingConstraint.constant == -208)
    {
        _containerTrailingConstraint.constant = 0;
    }
    else
    {
        _containerTrailingConstraint.constant = -208;
    }
}

-(void)filterOptionSelected:(NSNotification*)notification
{
    //
    //NSLog(@"Notification Obj is : %@", notification.object);
    
    int choice = [[[notification object] valueForKey:@"item"] intValue];
    [self filterRides:choice];
    [self filterClicked:nil];
    
    return;
    
    switch (choice)
    {
        case 0:
           // NSLog(@"All Option Selected");
            [_dataSource removeAllObjects];
            
            [_dataSource addObjectsFromArray:_currentRides];
            break;
        case 1:
            //NSLog(@"Pick Ups Option Selected");
            
            for (id ride in _currentRides)
            {
                [_dataSource removeAllObjects];
                if ([[ride valueForKey:@"ride_type"] isEqualToString:@"1"])
                {
                    [_dataSource addObject:ride];
                }
            }
            break;
        case 2:
            //NSLog(@"Pick Me Ups Option Selected");
            for (id ride in _currentRides)
            {
                [_dataSource removeAllObjects];
                if ([[ride valueForKey:@"ride_type"] isEqualToString:@"2"])
                {
                    [_dataSource addObject:ride];
                }
            }
            break;
        default:
            break;
    }
    
    [self refreshMap];
    [self.ridesListView reloadData];
    [self filterClicked:nil];
}

- (void)filterRides:(int)choice
{
    [_dataSource removeAllObjects];
    if (choice == 0)
    {
        [_dataSource addObjectsFromArray:_currentRides];
    }
    else if (choice == 1)
    {
        for (id ride in _currentRides)
        {
            if ([[ride objectForKey:@"ride_type"] intValue] == 1)
            {
                [_dataSource addObject:ride];
            }
        }
    }
    else
    {
        for (id ride in _currentRides)
        {
            if ([[ride objectForKey:@"ride_type"] intValue] == 2)
            {
                [_dataSource addObject:ride];
            }
        }
    }
    
    [self refreshMap];
    [_ridesListView reloadData];
}

- (void)initiateLocationServices
{
    
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

- (IBAction)listClicked:(UIBarButtonItem*)button
{
    if ([button.title isEqualToString:@"LIST"])
    {
        [button setTitle:@"MAP"];
        _ridesHolderTopConstraint.constant = 0;
        _ridesHolderBottomConstraint.constant = 0;
        [self.view setNeedsUpdateConstraints];
        [self.view updateConstraintsIfNeeded];
        [self.view layoutIfNeeded];
    }
    else
    {
        [button setTitle:@"LIST"];
        _ridesHolderTopConstraint.constant = self.view.frame.size.height;
        _ridesHolderBottomConstraint.constant = 0;
        [self.view setNeedsUpdateConstraints];
        [self.view updateConstraintsIfNeeded];
        [self.view layoutIfNeeded];
    }
    
    //NSLog(@"%@", button.title);
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
//    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
//    
//    User *currentUser = [User currentUser];
//    if (canExecuteWillAppear)
//    {
////        [self fetchRidesAroundMe];
//    }
//    else
//    {
//        canExecuteWillAppear = YES;
//    }
    
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

#pragma mark - SlideNavigationController Methods -

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
    return NO;
}


- (IBAction)fetchRidesAroundMe
{
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    if (delegate.currentLocCoord.latitude != 0)
    {
        NSDictionary *infoDict = @{@"user_id" : [User currentUser].userId, @"lat" : [NSString stringWithFormat:@"%f", delegate.currentLocCoord.latitude], @"lang" : [NSString stringWithFormat:@"%f", delegate.currentLocCoord.longitude]};
        [appDelegate showLoaingWithTitle:nil];
        [RSServices processFetchDefaultRides:infoDict completionHandler:^(NSDictionary *response, NSError *error)
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
                     NSLog(@"All rides with info: %@", response);
                    
                     [_currentRides removeAllObjects];
                     [_currentRides addObjectsFromArray:[response objectForKey:@"response_content"]];
                    // NSLog(@"Current rides are: %@", _currentRides);
                     [self filterRides:0];
                     //TODO: Refresh maps.
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
             
             if (alertMsg.length != 0)
             {
                 [RSUtils showAlertWithTitle:@"RideShare" message:alertMsg actionOne:nil actionTwo:nil inView:self];
             }
         }];
    }
}

- (void)refreshMap
{
    [_mapViewHolder clear];
    for (int i = 0 ; i < _dataSource.count; i++)
    {
        NSDictionary *ride = [_dataSource objectAtIndex:i];
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position = CLLocationCoordinate2DMake(((NSString*)[ride objectForKey:@"olat"]).floatValue,((NSString*)[ride objectForKey:@"olang"]).floatValue);
        marker.title = @"Origination";
        
        int rideType  = [[ride valueForKey:@"ride_type"] intValue];
        UIImage *markerImage = nil;
        
        if (rideType == 1)
        {
            if ([currentUser.userId isEqualToString: [ride valueForKey:@"user_id"] ])
            {
                markerImage = [UIImage imageNamed:@"Own_ride"];
            }
            else
            {
                markerImage = [UIImage imageNamed:@"others_ride"];
            }
        }
        else
        {
            if ([currentUser.userId isEqualToString: [ride valueForKey:@"user_id"] ])
            {
                markerImage = [UIImage imageNamed:@"you_wait"];
            }
            else
            {
                markerImage = [UIImage imageNamed:@"others_wait"];
            }
        }
        marker.userData = ride;
        marker.icon = markerImage;
        marker.map = _mapViewHolder;
    }
    [_ridesListView reloadData];
}

- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker
{
    return [self annotationViewForRide: marker];
}

- (UIView*)annotationViewForRide: (GMSMarker*)marker
{
    //NSLog(@"marker user data is : %@", marker.userData);
    NSDictionary *ride = marker.userData;
    UIView *annotationView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 160)];
    annotationView.translatesAutoresizingMaskIntoConstraints = YES;
    annotationView.backgroundColor = [UIColor colorWithRed:244.0/255.0 green:244.0/255.0 blue:244.0/255.0 alpha:1.0];
    
    UILabel *riderNameDisplay = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, annotationView.frame.size.width - 20, 40)];
    riderNameDisplay.numberOfLines = 2;
    riderNameDisplay.textColor = [UIColor blueColor];
    riderNameDisplay.translatesAutoresizingMaskIntoConstraints = YES;
    riderNameDisplay.text = [NSString stringWithFormat:@"Name:%@", [ride valueForKey:@"name"]];
    riderNameDisplay.alpha = 1.0;
    riderNameDisplay.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
    [annotationView addSubview:riderNameDisplay];
    
    UILabel *originDisplay = [[UILabel alloc] initWithFrame:CGRectMake(10, 40, annotationView.frame.size.width - 20, 40)];
    originDisplay.numberOfLines = 2;
    originDisplay.textColor = riderNameDisplay.textColor;
    originDisplay.translatesAutoresizingMaskIntoConstraints = YES;
    originDisplay.text = [NSString stringWithFormat:@"Starts at:%@", [ride valueForKey:@"oaddr"]];
    originDisplay.alpha = 0.85;
    originDisplay.font = riderNameDisplay.font;
    [annotationView addSubview:originDisplay];
    
    UILabel *destinationDisplay = [[UILabel alloc] initWithFrame:CGRectMake(10, 80, annotationView.frame.size.width - 20, 40)];
    destinationDisplay.translatesAutoresizingMaskIntoConstraints = YES;
    destinationDisplay.text = [NSString stringWithFormat:@"Ends at:%@", [ride valueForKey:@"daddr"]];
    destinationDisplay.textColor = riderNameDisplay.textColor;
    destinationDisplay.font = riderNameDisplay.font;
    destinationDisplay.alpha = 0.75;
    destinationDisplay.numberOfLines = 2;
    [annotationView addSubview:destinationDisplay];
    
    UILabel *riderCost = [[UILabel alloc] initWithFrame:CGRectMake(10, 120, annotationView.frame.size.width - 20, 40)];
    riderCost.numberOfLines = 2;
    riderCost.textColor = riderNameDisplay.textColor;
    riderCost.alpha = 0.65;
    riderCost.translatesAutoresizingMaskIntoConstraints = YES;
    
    if ([[ride valueForKey:@"ride_cost"] length] == 0)
    {
        riderCost.text = @"Ride Share: NA";
    }
    else
    {
        riderCost.text = [NSString stringWithFormat:@"Share Price:Rs %i", [[ride valueForKey:@"ride_cost"] intValue]];
    }
    [annotationView addSubview:riderCost];
    riderCost.font = riderNameDisplay.font;
    annotationView.layer.cornerRadius = 10.0;
    annotationView.userInteractionEnabled = YES;
    return annotationView;
}

- (void)callToRider:(NSString*)phoneNumber
{
    NSURL *phoneUrl = [NSURL URLWithString:[@"tel://" stringByAppendingString:phoneNumber]];
                       
    if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
        [[UIApplication sharedApplication] openURL:phoneUrl];
    } else
    {
        [RSUtils showAlertWithTitle:@"Calling" message:@"Your device does't support calling." actionOne:nil actionTwo:nil inView:self];
    }
}

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker
{
    [self showOptionsViewForRideInfo:marker.userData];
}

- (void)showOptionsViewForRideInfo:(NSDictionary*)rideInfo
{
    //NSLog(@"Marker: %@", rideInfo);
    
    NSString *title = ([[rideInfo objectForKey:@"ride_type"] intValue] == 1)?@"Ride" : @"Pick Up";
    
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:title message:[NSString stringWithFormat:@"Starts at: %@",[RSUtils getDisplayDate:[rideInfo objectForKey:@"start_time"]]] preferredStyle:UIAlertControllerStyleActionSheet];
    
    
    ////Call button
    UIAlertAction *callAction = [UIAlertAction actionWithTitle:@"Call" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
    {
        ////Call button Action method
        //NSLog(@"call button tapped");
        [self callToRider:[rideInfo valueForKey:@"mobile_no"]];
    }];
    
    ////Cancel alert button
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    
    ///// Cancel Request button
    if ([currentUser.userId isEqualToString:[rideInfo objectForKey:@"user_id"] ])
    {
         NSString *cancelTitle = ([[rideInfo objectForKey:@"ride_type"] intValue] == 1)?@"Cancel Ride" : @"Cancel Pick Up";
        UIAlertAction *cancelRequest = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
        {
            //NSLog(@"Cancel Ride button tapped");
            
            if ([[rideInfo valueForKey:@"ride_type"] intValue] == 1)
            {
                [self cancelMyRide:rideInfo];
            }
            else
            {
                [self cancelPickMeUp:rideInfo];
            }
        }];
        
        
        
        if ([[rideInfo valueForKey:@"ride_type"] intValue] == PickUp)
        {
            [controller addAction:cancelAction];
            [controller addAction:cancelRequest];
        }
        else
        {
            [controller addAction:cancelAction];
            [controller addAction:cancelRequest];
        }
    }
    else
    {
//        NSString *isRider, *rideType;
//        
//        if ([[rideInfo valueForKey:@"ride_type"]   isEqual: @"1"])
//        {
//           isRider=[NSString stringWithFormat:@"%i",PickUp];
//           rideType=[NSString stringWithFormat:@"%i",PickUp];
//                
//        }
//        else
//        {
//            isRider=[NSString stringWithFormat:@"%i",PickMeUp];
//            rideType=[NSString stringWithFormat:@"%i",PickMeUp];
//        }
        
        if ([[rideInfo valueForKey:@"ride_type"] intValue] == PickUp)
        {

            UIAlertAction *raiseRequest = [UIAlertAction actionWithTitle:@"Request to PickUp You!!!" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
            {
                
                self.tempRideInfo = [rideInfo mutableCopy];
                [self performSegueWithIdentifier:@"PickUpLocationView" sender:self];
                
            }];
            
            [controller addAction:raiseRequest];
            [controller addAction:callAction];
            [controller addAction:cancelAction];
        }
        else
        {
            
           
            
            UIAlertAction *raiseRequest = [UIAlertAction actionWithTitle:@"Request to PickUp Client!!!" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
            {
                NSDictionary *infoDict = @{@"from_id" : currentUser.userId,
                                           
                                           @"is_rider":[NSString stringWithFormat:@"%i",PickMeUp],
                                           @"type" : [NSString stringWithFormat:@"%i",PickMeUp],
                                           
                                           @"to_id" : [rideInfo valueForKey : @"user_id"],
                                           @"ride_id" : [rideInfo objectForKey:@"ride_id"],
                                           @"pick_lat" : [NSString stringWithFormat:@"%@",[rideInfo valueForKey:@"olat"]],
                                           @"pick_lang" : [NSString stringWithFormat:@"%@",[rideInfo valueForKey:@"olang"]],
                                           @"pick_addr" : [NSString stringWithFormat:@"%@",[rideInfo valueForKey:@"oaddr"]]
                                           };
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
                             UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Success" message:@"Your request for picking client has been sent to the client." preferredStyle:UIAlertControllerStyleAlert];
                             
                             UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                             
                             [alertController addAction:okAction];
                             [self presentViewController:alertController animated:YES completion:nil];
                             [self refreshClicked:nil];
                         }
                         else if ([[response objectForKey:kResponseCode] intValue] == kRequestAlreadySent)
                         {
                             //NSLog(@"Response success! with info: %@", response);
                             UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Ride Share" message:@"Your request already sent." preferredStyle:UIAlertControllerStyleAlert];
                             
                              UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                             
                             [alertController addAction:okAction];
                             [self presentViewController:alertController animated:YES completion:nil];
                             [self refreshClicked:nil];
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
            }];
            [controller addAction:raiseRequest];
            [controller addAction:callAction];
            [controller addAction:cancelAction];
        }
    }
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)cancelMyRide:(NSDictionary*)rideInfo
{
    NSLog(@"\n cancelMyRide rideInfo===%@",rideInfo);
    if ([[rideInfo valueForKey:@"is_accepted"] isEqual:@"1"] && [[rideInfo valueForKey:@"is_finished"] isEqual:@"0"])
    {
         [RSUtils showAlertWithTitle:@"RideShare" message:@"Sorry unable to cancel as you accepted pick up request" actionOne:nil actionTwo:nil inView:self];
        return;
    }
    [appDelegate showLoaingWithTitle:@"Loading..."];
    NSDictionary *infoDict = @{@"user_id" : currentUser.userId, @"ride_id" : [rideInfo valueForKey:@"ride_id"]};
    
    [RSServices processDeleteMyRideRequest:infoDict completionHandler:^(NSDictionary *response, NSError *error)
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
                 NSLog(@"Delete Request success! with info: %@", response);
                 UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Success" message:@"Your ride has been cancelled successfully." preferredStyle:UIAlertControllerStyleAlert];
                 
                 UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                 [alertController addAction:okAction];
                 [self presentViewController:alertController animated:YES completion:nil];
                 
                 [self refreshClicked:nil];
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
         if (alertMsg.length != 0)
         {
             [RSUtils showAlertWithTitle:@"Cancel Ride" message:alertMsg actionOne:nil actionTwo:nil inView:self];
         }
     }];    
}

- (void)cancelPickMeUp:(NSDictionary*)rideInfo
{
    
    NSLog(@"\n cancelPickMeUp rideInfo===%@",rideInfo);
    if ([[rideInfo valueForKey:@"is_accepted"] isEqual:@"1"] && [[rideInfo valueForKey:@"is_finished"] isEqual:@"0"] )
    {
        [RSUtils showAlertWithTitle:@"RideShare" message:@"Sorry unable to cancel as you accepted ride request" actionOne:nil actionTwo:nil inView:self];
        return;
    }

    
    [appDelegate showLoaingWithTitle:@"Loading..."];
    NSDictionary *infoDict = @{@"user_id" : currentUser.userId, @"ride_id" : [rideInfo valueForKey:@"ride_id"]};
    
    [RSServices processPickMeUpDeleteRequest:infoDict completionHandler:^(NSDictionary *response, NSError *error)
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
                // NSLog(@"Delete Request success! with info: %@", response);
                 UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Success" message:@"Your PickUp has been cancelled successfully." preferredStyle:UIAlertControllerStyleAlert];
                 
                 UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                 [alertController addAction:okAction];
                 [self presentViewController:alertController animated:YES completion:nil];
                 
                 [self refreshClicked:nil];
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
         if (alertMsg.length != 0)
         {
             [RSUtils showAlertWithTitle:@"Cancel PickUp" message:alertMsg actionOne:nil actionTwo:nil inView:self];
         }
     }];
}

- (void)showCallInfo:(NSDictionary*)rideInfo
{
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Title" message:@"Information" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *callAction = [UIAlertAction actionWithTitle:@"Call" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //NSLog(@"call button tapped");
        [self callToRider:[rideInfo valueForKey:@"mobile_no"]];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [controller addAction:cancelAction];
    [controller addAction:callAction];
    
    [self presentViewController:controller animated:YES completion:nil];
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
//    [self getAddressFromCoordinate:[locations objectAtIndex:0]];
    CLLocation *location = [locations lastObject];
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    
    delegate.currentLocCoord = location.coordinate;
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude zoom:13];
    _mapViewHolder.camera = camera;
    _mapViewHolder.myLocationEnabled = YES;
    [locationManager stopUpdatingLocation];
    
//    dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
        [self fetchRidesAroundMe];
        //NSLog(@"111111-111111111-1111111-1111111");
//    });
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
            
//            if ([placemark.country length] != 0)
//            {
//                if ([strAdd length] != 0)
//                    strAdd = [NSString stringWithFormat:@"%@, %@",strAdd,[placemark country]];
//                else
//                    strAdd = placemark.country;
//            }

            if ([placemark.postalCode length] != 0)
            {
                if ([strAdd length] != 0)
                    strAdd = [NSString stringWithFormat:@"%@, %@",strAdd,[placemark postalCode]];
                else
                    strAdd = placemark.postalCode;
            }
            
            //NSLog(@"Address is : %@", strAdd);
            _sourceLocationInput.text = strAdd;
        }
    }];
}

#pragma mark- UITableView Callback methods
- (NSUInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataSource.count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    RideCell *cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:@"RideCell"];
    if (cell == nil)
    {
        cell = [[RideCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"RideCell"];
    }
    NSDictionary *tempRide = [_dataSource objectAtIndex:indexPath.row];
    
    cell.sourceDisplay.text = [tempRide valueForKey:@"oaddr"];
    cell.destinationDisplay.text = [tempRide valueForKey:@"daddr"];
    cell.timeDisplay.text = [tempRide valueForKey:@"start_time"];
    
    cell.statusDisplay.text = [NSString stringWithFormat:@"Status:%@", [tempRide valueForKey:@"status"]];
    return cell;
}

-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
//    NSLog(@"user data is : %@", [_currentRides objectAtIndex:indexPath.row]);
//    NSDictionary *rideInfo = [_currentRides objectAtIndex:indexPath.row];
//    [self callToRider:[rideInfo valueForKey:@"mobile_no"]];
    [self showOptionsViewForRideInfo:[_dataSource objectAtIndex:indexPath.row]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pickingToggleAction:(UIButton*)sender
{
    if (sender == _btnPickup)
    {
        [_btnRequest setTitle:@"CREATE RIDE" forState:UIControlStateNormal];

        _rideCoseInput.text = @"";
        _btnPickup.selected = YES;
        _btnPickMeUp.selected = NO;
        _rideCoseInput.hidden = NO;
        _rsLabel.hidden=NO;
        
    }
    else
    {
         [_btnRequest setTitle:@"REQUEST PICK UP" forState:UIControlStateNormal];
        _rideCoseInput.text = @"";
        _btnPickup.selected = NO;
        _btnPickMeUp.selected = YES;
        _rideCoseInput.hidden = YES;
         _rsLabel.hidden=YES;
       
    }
   
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    
    _rideViewHightConstraint.constant=127;
    [self.view setNeedsUpdateConstraints];
    [self.view updateConstraintsIfNeeded];
    [self.view layoutIfNeeded];
    
    
    [UIView commitAnimations];
    
}

- (IBAction)pickTimeAction:(id)sender
{
    self.navigationController.navigationBarHidden = NO;
   // NSLog(@"Date picker time is : %@", _timePicker.date);
   // NSLog(@"Actual time is : %@", [RSUtils toLocalTime:_timePicker.date]);
    [RSUtils getDateStringFormDate:_timePicker.date withFormat:nil];
    pickerHolderTopConstraint.constant = self.view.frame.size.height;
    pickerHolderBottomConstraint.constant = -self.view.frame.size.height;
    [_pickTimeButton setTitle:[RSUtils getDateStringFormDate:_timePicker.date withFormat:nil] forState:UIControlStateNormal];
    [self.view setNeedsUpdateConstraints];
    [self.view updateConstraintsIfNeeded];
    [self.view layoutIfNeeded];
}

- (IBAction)showTimePicker:(id)sender
{
    //NSLog(@"%@", _timePickerHolderView);
    pickerHolderTopConstraint.constant = -self.view.frame.size.height;
    pickerHolderBottomConstraint.constant = 0;
   // NSLog(@"%@", _timePickerHolderView);
    self.navigationController.navigationBarHidden = YES;
    [self.view setNeedsUpdateConstraints];
    [self.view updateConstraintsIfNeeded];
    [self.view layoutIfNeeded];
}
- (IBAction)cancelAction:(id)sender
{
    [self reset];
}
-(void)reset
{
    _rideViewHightConstraint.constant=0;
    _btnPickup.selected=NO;
    _btnPickMeUp.selected=NO;
    _sourceLocationInput.text=@"";
    _destinationLocationInput.text=@"";
    _rideCoseInput.text=@"";
    _timePicker.minimumDate = [NSDate date];
    [_pickTimeButton setTitle:[RSUtils getDateStringFormDate:_timePicker.date withFormat:nil] forState:UIControlStateNormal];
}
- (IBAction)requestAction:(id)sender
{
    [_rideCoseInput resignFirstResponder];
  
    NSString *rideType = (_btnPickup.selected) ? @"1" : @"2";
    NSString *is_rider;
    if ([rideType  isEqual: @"1"])
    {
        is_rider=[NSString stringWithFormat:@"%i",PickUp];
    }
    else
    {
        is_rider =[NSString stringWithFormat:@"%i",PickMeUp];
    }

    
    NSString *alertMsg = nil;
    
    NSString *startTime = [_pickTimeButton titleForState:UIControlStateNormal];
    
    if (_sourceLocationInput.text.length == 0 )
    {
        alertMsg = @"Please choose your starting Location.";
    }
    else if (_destinationLocationInput.text.length == 0)
    {
        alertMsg = @"Please choose your Destination Location.";
    }
    else if ([rideType  isEqual: @"1"] && _rideCoseInput.text.length==0)
    {
        alertMsg = @"Please enter Ride Cost.";
    }
    if(alertMsg.length)
    {
        [RSUtils showAlertWithTitle:@"Error" message:alertMsg actionOne:nil actionTwo:nil inView:self];
        return;
    }
    
   
  //    _rideViewHightConstraint.constant=0;
//    _btnPickup.selected=NO;
//    _btnPickMeUp.selected=NO;
    
    NSDictionary *infoDict = @{@"ride_type" : rideType,
                               @"is_rider":is_rider,
                               @"user_id" : currentUser.userId,
                               @"ride_cost" : _rideCoseInput.text,
                               @"start_time" : startTime,
                               @"oaddr" : _sourceLocationInput.text,
                               @"olat" : [NSString stringWithFormat:@"%f", sourceCoordinate.latitude],
                               @"olang" : [NSString stringWithFormat:@"%f", sourceCoordinate.longitude],
                               @"daddr" : _destinationLocationInput.text,
                               @"dlat" : [NSString stringWithFormat:@"%f", destinationCoordinate.latitude],
                               @"dlang" : [NSString stringWithFormat:@"%f", destinationCoordinate.longitude]
                               };
    
    //NSLog(@"Post data is : %@", infoDict);
    [appDelegate showLoaingWithTitle:@"Loading..."];
    [RSServices processMyRideRequest:infoDict completionHandler:^(NSDictionary *response, NSError *error)
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
                  NSLog(@"Received response for my ride is : %@", response);
                 [self reset];
                 
                 UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Success" message:@"Your ride request has been submitted successfully." preferredStyle:UIAlertControllerStyleAlert];
                 _rideCoseInput.text = @"";
                 UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                 [alertController addAction:okAction];
                 [self presentViewController:alertController animated:YES completion:nil];
                 //                     _rideCoseInput.text = @"0";
                 _sourceLocationInput.text = @"";
                 _destinationLocationInput.text = @"";
                 sourceCoordinate = CLLocationCoordinate2DMake(0, 0);
                 destinationCoordinate = CLLocationCoordinate2DMake(0, 0);
                
                 [_currentRides removeAllObjects];
                 [_currentRides addObjectsFromArray:[response objectForKey:@"response_content"]];
                 //NSLog(@"Current rides are: %@", _currentRides);
                 //                     [self filterRides:0];
                 [self refreshClicked:nil];
                 //TODO: Refresh maps.
             }
             else
             {
                 UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                            {
                                                //                                                    [self.navigationController popViewControllerAnimated:YES];
                                            }];
                 [RSUtils showAlertWithTitle:@"Falied" message:[response objectForKey:kResponseMessage] actionOne:okAction actionTwo:nil inView:self];
                 return;
             }
         }
         
         if (alertMsg.length != 0)
         {
             [RSUtils showAlertWithTitle:@"RideShare" message:alertMsg actionOne:nil actionTwo:nil inView:self];
         }
     }];
}

- (IBAction)returnedFromLocationPicker:(UIStoryboardSegue*)segue
{
    //NSLog(@"%@", segue.sourceViewController);
    
    if ([segue.sourceViewController isKindOfClass: [RSLocationPickerController class]])
    {
        RSLocationPickerController *locationPicker = (RSLocationPickerController*)[segue sourceViewController];
       // NSLog(@"Selected Address is : %@, %@",locationPicker.selectedAddress, locationPicker.selectedAddress.administrativeArea);
        if (_bntPickStartLocation.selected ==  YES)
        {
            _sourceLocationInput.text = [NSString stringWithFormat:@"%@, %@, %@", locationPicker.selectedAddress.thoroughfare, locationPicker.selectedAddress.locality, locationPicker.selectedAddress.administrativeArea];
            sourceCoordinate = locationPicker.selectedAddress.coordinate;
            [self updateMapView];
        }
        else
        {
            _destinationLocationInput.text = [NSString stringWithFormat:@"%@, %@, %@", locationPicker.selectedAddress.thoroughfare, locationPicker.selectedAddress.locality, locationPicker.selectedAddress.administrativeArea];
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

- (IBAction)pickDestinationLocationAction:(id)sender
{
    _btnDestionationLocation.selected = YES;
    canExecuteWillAppear = NO;
}

- (IBAction)pickStartLocationAction:(id)sender
{
    _bntPickStartLocation.selected = YES;
    canExecuteWillAppear = NO;
}

- (IBAction)cancelPickTime:(id)sender
{
    self.navigationController.navigationBarHidden = NO;
    pickerHolderTopConstraint.constant = self.view.frame.size.height;
    pickerHolderBottomConstraint.constant = -self.view.frame.size.height;
    
    [self.view setNeedsUpdateConstraints];
    [self.view updateConstraintsIfNeeded];
    [self.view layoutIfNeeded];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [_rideCoseInput resignFirstResponder];
    [_sourceLocationInput resignFirstResponder];
    [_destinationLocationInput resignFirstResponder];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id destViewController = segue.destinationViewController;
    if ([destViewController isKindOfClass:[RSPickupLocationPickerViewController class]])
    {
        ((RSPickupLocationPickerViewController*)destViewController).rideData = self.tempRideInfo;
    }
}

@end
