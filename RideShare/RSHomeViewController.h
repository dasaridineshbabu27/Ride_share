//
//  ViewController.h
//  RideShare
//
//  Created by Reddy on 04/01/16.
//  Copyright © 2016 Reddy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <GoogleMaps/GoogleMaps.h>
#import "SlideNavigationController.h"
#import "User.h"
#import "AppDelegate.h"

@interface RSHomeViewController : UIViewController <CLLocationManagerDelegate, GMSMapViewDelegate, SlideNavigationControllerDelegate>
{
    CLLocationManager *locationManager;
    CLLocationCoordinate2D sourceCoordinate, destinationCoordinate;    
    __weak IBOutlet NSLayoutConstraint *pickerHolderBottomConstraint;
//    GMSMapView *mapView;
    __weak IBOutlet NSLayoutConstraint *pickerHolderTopConstraint;
    
    BOOL canExecuteWillAppear;
    UIBarButtonItem *rightButton;
    __weak IBOutlet UIView *filterContainerView;
}
@property (nonatomic, strong) NSMutableDictionary *tempRideInfo;
@property (nonatomic, strong) User *currentUser;
@property (nonatomic, strong) NSMutableArray *dataSource;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerTrailingConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ridesHolderTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ridesHolderBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rideViewHightConstraint;

@property (weak, nonatomic) IBOutlet UIView *ridesListHolder;
@property (weak, nonatomic) IBOutlet UIView *rideView;
@property (weak, nonatomic) IBOutlet UILabel *rsLabel;
@property (weak, nonatomic) IBOutlet UITableView *ridesListView;
@property (weak, nonatomic) IBOutlet UIDatePicker *timePicker;

@property (weak, nonatomic) IBOutlet UIView *timePickerHolderView;
- (IBAction)pickTimeAction:(id)sender;

- (IBAction)pickDestinationLocationAction:(id)sender;
- (IBAction)pickStartLocationAction:(id)sender;
@property (nonatomic, strong) NSMutableArray *currentRides;
@property (nonatomic, strong) NSMutableArray *markers;
@property (weak, nonatomic) IBOutlet UIButton *btnDestionationLocation;
@property (weak, nonatomic) IBOutlet UIButton *bntPickStartLocation;

@property (weak, nonatomic) IBOutlet UITextField *rideCoseInput;
@property (weak, nonatomic) IBOutlet UITextField *destinationLocationInput;
@property (weak, nonatomic) IBOutlet UITextField *sourceLocationInput;

@property (weak, nonatomic) IBOutlet GMSMapView *mapViewHolder;
@property (weak, nonatomic) IBOutlet UIButton *btnRequest;
@property (weak, nonatomic) IBOutlet UIButton *pickTimeButton;



@property (weak, nonatomic) IBOutlet UIButton *btnPickup;
@property (weak, nonatomic) IBOutlet UIButton *btnPickMeUp;

//////
@property (strong, nonatomic) IBOutlet GADBannerView *googleAdBanner;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *googleAdbottomConstraint;


- (IBAction)pickingToggleAction:(id)sender;
- (IBAction)requestAction:(id)sender;
- (IBAction)showTimePicker:(id)sender;
- (IBAction)cancelAction:(id)sender;
- (IBAction)fetchRidesAroundMe;
@end

