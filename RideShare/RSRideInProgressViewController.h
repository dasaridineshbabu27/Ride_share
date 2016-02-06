//
//  RSRideInProgressViewController.h
//  RideShare
//
//  Created by Reddy on 06/02/16.
//  Copyright © 2016 Reddy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>

@interface RSRideInProgressViewController : UIViewController<CLLocationManagerDelegate, GMSMapViewDelegate>
{
    CLLocationManager *locationManager;
}

@property (nonatomic, assign) CLLocationCoordinate2D pickUpLocation;
@property (nonatomic, assign) CLLocationCoordinate2D startCoordinate;
@property (nonatomic, assign) CLLocationCoordinate2D destinationCoordinate;

@property (weak, nonatomic) IBOutlet GMSMapView *rideMapView;
@end
