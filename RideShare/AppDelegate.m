//
//  AppDelegate.m
//  RideShare
//
//  Created by Reddy on 04/01/16.
//  Copyright © 2016 Reddy. All rights reserved.
//

#import "AppDelegate.h"
#import "IQKeyboardManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [GMSServices provideAPIKey:GoogleMapsAPIKey];
    [IQKeyboardManager sharedManager].enable = YES;
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (UIView*)loadingView
{
    if (!_loadingView)
    {
        _loadingView = [[UIView alloc] initWithFrame:[appDelegate window].bounds];
        _loadingView.translatesAutoresizingMaskIntoConstraints = NO;
        _loadingView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
        [_loadingView addSubview:self.titleLable];
        [_loadingView addSubview:self.indicator];
    }
    return _loadingView;
}


- (UILabel*)titleLable
{
    if (!_titleLable)
    {
        _titleLable = [[UILabel alloc] initWithFrame:[appDelegate window].bounds];
        _titleLable.translatesAutoresizingMaskIntoConstraints = NO;
        _titleLable.textColor = [UIColor whiteColor];
        _titleLable.textAlignment = NSTextAlignmentCenter;
        _titleLable.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    }
    return _titleLable;
}

- (UIActivityIndicatorView*)indicator
{
    if (!_indicator)
    {
        _indicator = [[UIActivityIndicatorView alloc] init];
        _loadingView.translatesAutoresizingMaskIntoConstraints = NO;
        _indicator.center = _loadingView.center;
        _indicator.hidden = NO;
    }
    return _indicator;
}

- (void)showLoaingWithTitle:(NSString*)title
{
    self.loadingView.tag = self.loadingView.tag + 1;
    [[appDelegate window] addSubview:self.loadingView];
    _titleLable.text = @"Loading...";
    [_indicator startAnimating];
    
    NSLog(@"Showing from AppDelegate");
}

- (void)hideLoading
{
    self.loadingView.tag = self.loadingView.tag - 1;
    if (self.loadingView.tag == 0)
    {
        [self.loadingView removeFromSuperview];
        [_indicator stopAnimating];
    }
    NSLog(@"Hiding from AppDelegate");
}


@end
