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

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    
}
@property (nonatomic, strong) UILabel *titleLable;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;

@property (nonatomic, strong) UIView *loadingView;
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) BOOL isUserLoggedIn;
- (void)showLoaingWithTitle:(NSString*)title;
- (void)hideLoading;
- (void)showAlertWithTitle:(NSString*)title message:(NSString*)messge action:(NSString*)action;
@end

