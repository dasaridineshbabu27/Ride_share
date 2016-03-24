//
//  RSRideInProgressViewController.h
//  RideShare
//
//  Created by Reddy on 06/02/16.
//  Copyright © 2016 Reddy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import "User.h"
#import "RSUtils.h"
#import "AppDelegate.h"

@interface RSRideInProgressViewController : UIViewController<CLLocationManagerDelegate, GMSMapViewDelegate>
{
    CGPoint previousPoint;
    GMSMarker *vehicleMarker;
}
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) CLLocationCoordinate2D pickUpLocation;
@property (nonatomic, assign) CLLocationCoordinate2D startCoordinate;
@property (nonatomic, assign) CLLocationCoordinate2D destinationCoordinate;
@property (nonatomic, strong) User *currentUser;
@property (nonatomic, strong) NSString *otherUser_id;
@property (nonatomic, strong) NSDictionary *ride_info;
@property (nonatomic, strong) NSDictionary *notification;
@property (weak, nonatomic) IBOutlet GMSMapView *rideMapView;


//////
@property (strong, nonatomic) IBOutlet GADBannerView *googleAdBanner;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *googleAdbottomConstraint;

@end
