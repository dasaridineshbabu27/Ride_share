//
//  RSLocationPickerController.h
//  RideShare
//
//  Created by Reddy on 05/01/16.
//  Copyright © 2016 Reddy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <GoogleMaps/GoogleMaps.h>
#import "AppDelegate.h"
@interface RSLocationPickerController : UIViewController <CLLocationManagerDelegate, GMSMapViewDelegate>
{
    CLLocationManager *locationManager;
    __weak IBOutlet UIView *addressHolder;
}
@property (weak, nonatomic) IBOutlet UILabel *addressDisplayer;

@property (weak, nonatomic) IBOutlet GMSMapView *mapViewHolder;

@property (nonatomic, retain) GMSAddress *selectedAddress;

//////
@property (strong, nonatomic) IBOutlet GADBannerView *googleAdBanner;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *googleAdbottomConstraint;

@end

