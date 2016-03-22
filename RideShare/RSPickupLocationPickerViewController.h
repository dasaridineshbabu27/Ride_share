//
//  RSPickupLocationPickerViewController.h
//  RideShare
//
//  Created by Reddy on 05/02/16.
//  Copyright © 2016 Reddy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <GoogleMaps/GoogleMaps.h>
#import "AppDelegate.h"
@interface RSPickupLocationPickerViewController : UIViewController <CLLocationManagerDelegate, GMSMapViewDelegate>
{
    CLLocationManager *locationManager;
    CLLocationCoordinate2D pickUpLocation;
    __weak IBOutlet UIView *addressHolder;
}


@property (nonatomic, strong) NSDictionary *rideData;

@property (weak, nonatomic) IBOutlet UILabel *addressDisplayer;

@property (weak, nonatomic) IBOutlet GMSMapView *mapViewHolder;

@property (nonatomic, retain) GMSAddress *selectedAddress;

- (IBAction)sendPickupRequest:(NSDictionary*)rideInfo;

@end
