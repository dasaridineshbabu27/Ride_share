//
//  AppDelegate.h
//  RideShare
//
//  Created by Reddy on 04/01/16.
//  Copyright © 2016 Reddy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RSConstants.h"
#import <GoogleMaps/GoogleMaps.h>
#import <SocketIOClientSwift/SocketIOClientSwift-Swift.h>
#import <iAd/iAd.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, ADBannerViewDelegate>
{
    
}
@property (nonatomic, strong) ADBannerView *adBanner;
@property (nonatomic) BOOL bannerIsVisible;

@property (nonatomic, strong) NSString *deviceToken;
@property (nonatomic) CLLocationCoordinate2D currentLocCoord;
@property (nonatomic, strong) UILabel *titleLable;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;

@property (nonatomic, strong) UIView *loadingView;
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) BOOL isUserLoggedIn;
- (void)showLoaingWithTitle:(NSString*)title;
- (void)hideLoading;
- (UIViewController *)topViewController;


@end

