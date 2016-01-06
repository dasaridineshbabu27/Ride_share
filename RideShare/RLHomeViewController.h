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

@interface RLHomeViewController : UIViewController <CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
//    GMSMapView *mapView;
}
@property (weak, nonatomic) IBOutlet UITextField *rideCoseInput;

@property (weak, nonatomic) IBOutlet GMSMapView *mapViewHolder;
@property (weak, nonatomic) IBOutlet UIButton *btnRequest;
@property (weak, nonatomic) IBOutlet UIButton *pickTimeButton;

@property (weak, nonatomic) IBOutlet UITextField *destinationLocationInput;
@property (weak, nonatomic) IBOutlet UITextField *sourceLocationInput;
@property (weak, nonatomic) IBOutlet UIButton *btnPickup;

@property (weak, nonatomic) IBOutlet UIButton *btnPickMeUp;

- (IBAction)pickingToggleAction:(id)sender;
- (IBAction)requestAction:(id)sender;
- (IBAction)pickTimeAction:(id)sender;

@end

