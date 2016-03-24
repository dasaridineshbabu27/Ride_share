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


#import "LARSAdController.h"
#import"TOLAdAdapterGoogleAds.h"
#import "TOLAdAdapteriAds.h"
#import "TOLAdAdapter.h"
#import "TOLAdViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,ADBannerViewDelegate,GADBannerViewDelegate>//
{
    
}
@property (nonatomic, strong) ADBannerView *adBanner;
@property (nonatomic) BOOL bannerIsVisible;

@property (strong, nonatomic) GADBannerView  *googleAdbanner;
@property (nonatomic) BOOL googleBannerIsVisible;
@property (nonatomic) BOOL googleAdIsVisible;

@property (nonatomic, strong) NSString *deviceToken;
@property (nonatomic) CLLocationCoordinate2D currentLocCoord;

@property (nonatomic, strong) UILabel *titleLable;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@property (nonatomic, strong) UIView *loadingView;

@property (nonatomic, strong) UIView *aDView;

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) BOOL isUserLoggedIn;

- (void)showLoaingWithTitle:(NSString*)title;
- (void)hideLoading;

-(UIView*)AdView;
- (void)showAdView;
- (void)hideAdView;

- (UIViewController *)topViewController;

-(void)iAdIntegration;
-(void)iAdIntegrationwith:(ADBannerView*)iAdBanner andviewController:(UIViewController*)viewController;

-(void)googleAdsIntegration;
-(void)googleAdsIntegrationWith:(GADBannerView*)googleBannerView andviewController:(UIViewController*)viewController;
@end

