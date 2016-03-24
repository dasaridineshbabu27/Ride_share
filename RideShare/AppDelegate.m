//
//  AppDelegate.m
//  RideShare
//
//  Created by Reddy on 04/01/16.
//  Copyright © 2016 Reddy. All rights reserved.
//

#import "AppDelegate.h"
#import "IQKeyboardManager.h"
#import "LeftMenuViewController.h"
#import "RightMenuViewController.h"
#import "SlideNavigationController.h"
#import "RSServices.h"
#import "User.h"
#import "RSUtils.h"
#import "RLLoginViewController.h"
#import "RSHomeViewController.h"

@interface AppDelegate ()
@property float yOrigin;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    // Override point for customization after application launch.
    
    
    //Google Maps
    [GMSServices provideAPIKey:GoogleMapsAPIKey];
    
    //Keyboards
    [IQKeyboardManager sharedManager].enable = YES;
    
    [self ADLocation];
    
    //iOS iADs
    //[self iAdIntegration];
    
    //iOS Google Ads
    //[self googleAdsIntegration];
    
    //LARSAd (iADs + GoogleAds,Third Party library)
    //[self LARSAdsIntegration];
    
    //Notifications Registration
    UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    
   	UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    LeftMenuViewController *leftMenu = (LeftMenuViewController*)[mainStoryboard instantiateViewControllerWithIdentifier: @"LeftMenuViewController"];
    [SlideNavigationController sharedInstance].leftMenu = leftMenu;
    
    //    RightMenuViewController *rightMenu = (RightMenuViewController*)[mainStoryboard instantiateViewControllerWithIdentifier: @"RightMenuViewController"];
    //    [SlideNavigationController sharedInstance].rightMenu = rightMenu;
    
    [SlideNavigationController sharedInstance].menuRevealAnimationDuration = .18;
    
    // Creating a custom bar button for right menu
    //    UIButton *button  = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    //    [button setImage:[UIImage imageNamed:@"gear"] forState:UIControlStateNormal];
    //    [button addTarget:[SlideNavigationController sharedInstance] action:@selector(toggleRightMenu) forControlEvents:UIControlEventTouchUpInside];
    //    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    //    [SlideNavigationController sharedInstance].rightBarButtonItem = rightBarButtonItem;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:SlideNavigationControllerDidClose object:nil queue:nil usingBlock:^(NSNotification *note)
     {
         NSString *menu = note.userInfo[@"menu"];
         // NSLog(@"Closed %@", menu);
     }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:SlideNavigationControllerDidOpen object:nil queue:nil usingBlock:^(NSNotification *note)
     {
         NSString *menu = note.userInfo[@"menu"];
         //NSLog(@"Opened %@", menu);
     }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:SlideNavigationControllerDidReveal object:nil queue:nil usingBlock:^(NSNotification *note)
     {
         NSString *menu = note.userInfo[@"menu"];
         // NSLog(@"Revealed %@", menu);
     }];
    
    
    
    //    if([[NSUserDefaults standardUserDefaults]boolForKey:@"isLoggedIn"])
    //    {
    //        //show home page here
    //        RSHomeViewController *homeController = [mainStoryboard instantiateViewControllerWithIdentifier:@"RSHomeViewController"];
    ////        UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:homeController];
    ////        self.window.rootViewController = navController;
    //
    //        [[SlideNavigationController sharedInstance] popAllAndSwitchToViewController:homeController withCompletion:nil];
    //
    //    }else{
    //        // show login view
    //
    //        RLLoginViewController *loginController = [mainStoryboard instantiateViewControllerWithIdentifier:@"RLLoginViewController"];
    ////        UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:loginController];
    ////        self.window.rootViewController = navController;
    //
    //         [[SlideNavigationController sharedInstance] popAllAndSwitchToViewController:loginController withCompletion:nil];
    //    }
    
    
    return YES;
}

-(void)ADLocation
{
    if (IS_IPHONE)
    {
        //NSLog(@"\n iPhone");
        if (IS_IPHONE_4_OR_LESS)
        {
            // NSLog(@"\n iPhone_4");
            _yOrigin=480.0;
        }
        else if (IS_IPHONE_5)
        {
            // NSLog(@"\n iPhone_5");
            _yOrigin=568.0;
        }
        else if (IS_IPHONE_6)
        {
            // NSLog(@"\n iPhone_6");
            _yOrigin=667.0;
        }
        else if (IS_IPHONE_6P)
        {
            //NSLog(@"\n iPhone_6 Plus");
            _yOrigin= 736.0;
        }
        
    } else {
        //NSLog(@"\n iPad");
    }
    NSLog(@"\n ADHeight::::%f,  yOrigin::::%f",self.topViewController.view.frame.size.height, _yOrigin);
}
- (void)application:(UIApplication*)application didRegisterUserNotificationSettings:(nonnull UIUserNotificationSettings *)notificationSettings
{
    [application registerForRemoteNotifications];
}


- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(nonnull NSError *)error
{
    NSLog(@" Error while registering for remote notifications: %@", error);
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(nonnull NSData *)deviceToken
{
    //NSLog(@"the generated device token string is : %@",deviceToken);
    
    self.deviceToken = [[[[deviceToken description]                                                    stringByReplacingOccurrencesOfString: @"<" withString: @""]stringByReplacingOccurrencesOfString: @">" withString: @""]                                                       stringByReplacingOccurrencesOfString: @" " withString: @""];
    
    NSLog(@"the generated device token string is : %@",self.deviceToken);
    [[NSUserDefaults standardUserDefaults] setObject:self.deviceToken forKey:@"device_token"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(nonnull NSDictionary *)userInfo
{
    NSLog(@"\n didReceiveRemoteNotification::::: %@",userInfo);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    //iPad Device Token::: a5846f368480ff30a7bf4ce63aed1c4d450db0af0f1b23df4400665d577c1ad2
    
    NSLog(@"\n didReceiveRemoteNotification userinfo:::::%@ \n fetchCompletionHandler:::::%@",userInfo,completionHandler);
    
    NSLog(@"\n aps::::%@ \n type::::%@",[userInfo valueForKey:@"aps"],[userInfo valueForKey:@"type"]);
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"RideShare" message:[[userInfo valueForKey:@"aps"] valueForKey:@"alert"] preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Accept" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                             {
                                 
                                 NSLog(@"Preferred Action");
                                 //Preferred Service
                                 
                             }];
    
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                         {
                             
                             NSLog(@"OK clicked!");
                             //Dismiss Alert
                             [alertController dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    
    //[alertController addAction:action];
    [alertController addAction:ok];
    
    [self.topViewController presentViewController:alertController animated:YES completion:nil];
    
    
    
    
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

-(UIView*)AdView
{
    if (!_aDView)
    {
        _aDView = [[UIView alloc] init];
        _aDView.translatesAutoresizingMaskIntoConstraints = NO;
        _aDView.backgroundColor = [UIColor redColor];
        [self.topViewController.view addSubview:_aDView];
        
        NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:_aDView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_window attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0];
        
        NSLayoutConstraint *hightConstraint = [NSLayoutConstraint constraintWithItem:_aDView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:50];
        
        NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:_aDView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_window attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
        NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:_aDView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_window attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-15];
        [_window addConstraints:@[widthConstraint, hightConstraint, centerX,bottom]];
        
    }
    return _aDView;
    
}

- (void)showAdView
{
    [self performSelectorOnMainThread:@selector(showAd) withObject:nil waitUntilDone:YES];
}

- (void)showAd
{
    self.AdView.tag = self.AdView.tag + 1;
    _aDView.hidden = NO;
    //[_window bringSubviewToFront:_aDView];
    
}
- (void)hideAdView
{
    [self performSelectorOnMainThread:@selector(hideAd) withObject:nil waitUntilDone:YES];
}

- (void)hideAd
{
    self.AdView.tag = self.AdView.tag - 1;
    if (self.AdView.tag <= 0)
    {
        [_aDView setHidden:YES];
    }
    
}

- (UIView*)loadingView
{
    if (!_loadingView)
    {
        _loadingView = [[UIView alloc] init];
        _loadingView.translatesAutoresizingMaskIntoConstraints = NO;
        _loadingView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
        [_loadingView addSubview:self.titleLable];
        [_loadingView addSubview:self.indicator];
        [_window addSubview:_loadingView];
        
        NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:_loadingView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_window attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0];
        
        NSLayoutConstraint *hightConstraint = [NSLayoutConstraint constraintWithItem:_loadingView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_window attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0];
        
        NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:_loadingView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_window attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
        
        NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:_loadingView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_window attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
        
        [_window addConstraints:@[widthConstraint, hightConstraint, centerX, centerY]];
        
        
        centerX = [NSLayoutConstraint constraintWithItem:_indicator attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_loadingView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
        
        centerY = [NSLayoutConstraint constraintWithItem:_indicator attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_loadingView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
        
        [_loadingView addConstraints:@[centerY, centerX]];
        
        centerX = [NSLayoutConstraint constraintWithItem:_titleLable attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_loadingView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
        
        centerY = [NSLayoutConstraint constraintWithItem:_titleLable attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_loadingView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:30];
        
        [_loadingView addConstraints:@[centerX, centerY
                                       ]];
    }
    return _loadingView;
}

- (UILabel*)titleLable
{
    if (!_titleLable)
    {
        _titleLable = [[UILabel alloc] init];
        _titleLable.translatesAutoresizingMaskIntoConstraints = NO;
        _titleLable.textColor = [UIColor whiteColor];
        _titleLable.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLable;
}

- (UIActivityIndicatorView*)indicator
{
    if (!_indicator)
    {
        _indicator = [[UIActivityIndicatorView alloc] init];
        _indicator.translatesAutoresizingMaskIntoConstraints = NO;
        _indicator.center = CGPointMake(_indicator.center.x, _indicator.center.y - 50);
        _indicator.hidden = NO;
    }
    return _indicator;
}

- (void)showLoaingWithTitle:(NSString*)title
{
    [self performSelectorOnMainThread:@selector(showIndicator) withObject:nil waitUntilDone:YES];
}

- (void)showIndicator
{
    self.loadingView.tag = self.loadingView.tag + 1;
    _loadingView.hidden = NO;
    [_window bringSubviewToFront:_loadingView];
    _titleLable.text = @"Loading...";
    [_indicator startAnimating];
}

- (void)hideLoading
{
    [self performSelectorOnMainThread:@selector(hideIndicator) withObject:nil waitUntilDone:YES];
}

- (void)hideIndicator
{
    self.loadingView.tag = self.loadingView.tag - 1;
    if (self.loadingView.tag <= 0)
    {
        [_loadingView setHidden:YES];
        [_indicator stopAnimating];
    }
    // NSLog(@"Hiding from AppDelegate");
}

#pragma mark - LARSAds methods
-(void)LARSAdsIntegration
{
    //LARSAd (iADs + GoogleAds,Third Party library)
    [[LARSAdController sharedManager] registerAdClass:[TOLAdAdapterGoogleAds class] withPublisherId:AdUnitId];
    [[LARSAdController sharedManager] registerAdClass:[TOLAdAdapteriAds class]];
    
    
}
#pragma mark - iAds methods
-(void)iAdIntegration
{
    //iOS iADs
    _adBanner = [[ADBannerView alloc] initWithFrame:CGRectMake(0, _yOrigin, 320, 50)];
    _adBanner.delegate = self;
    
}

-(void)iAdIntegrationwith:(ADBannerView*)iAdBanner andviewController:(UIViewController*)viewController
{
    //iOS iADs
    //_adBanner = [[ADBannerView alloc] initWithFrame:CGRectMake(0, _yOrigin, 320, 50)];
    iAdBanner.delegate = self;
}

#pragma mark - iAds Delegate methods

-(void)bannerViewWillLoadAd:(ADBannerView *)banner
{
    NSLog(@" Ad will load");

    //self.topViewController.canDisplayBannerAds = YES;
}

-(void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    NSLog(@" Ad did load");
     // NSLog(@"\n ADHeight::::%f,  yOrigin::::%f",self.topViewController.view.frame.size.height, _yOrigin);
    if (!_bannerIsVisible)
    {
        // If banner isn't part of view hierarchy, add it
        if (_adBanner.superview == nil)
        {
            [self.topViewController.view addSubview:_adBanner];
        }

        [UIView beginAnimations:@"animateAdBannerOn" context:NULL];

        // Assumes the banner view is just off the bottom of the screen.
        banner.frame = CGRectOffset(banner.frame, 0, -banner.frame.size.height-15);

        [UIView commitAnimations];

        _bannerIsVisible = YES;
    }
}

-(BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    NSLog(@" Ad Should Begin");

    return YES;
}

-(void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    NSLog(@" Ad did finish");

    [banner cancelBannerViewAction];

}
-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    NSLog(@" Ad fail Error::::%@",error);

    if (_bannerIsVisible)
    {
        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];

        // Assumes the banner view is placed at the bottom of the screen.
        banner.frame = CGRectOffset(banner.frame, 0, banner.frame.size.height+15);

        [UIView commitAnimations];

        _bannerIsVisible = NO;
    }
}

#pragma mark - Google Ads methods
-(void)googleAdsIntegration
{
    //iOS Google Ads
    NSLog(@"Google Mobile Ads SDK version: %@", [GADRequest sdkVersion]);
    GADBannerView *bannerView=[[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    //[bannerView setAdSize:kGADAdSizeBanner];
    bannerView.delegate=self;
    bannerView.adUnitID = AdUnitId;
    bannerView.rootViewController = self.topViewController;
    GADRequest *request = [GADRequest request];

//    NSString *udid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
//    udid = [udid stringByReplacingOccurrencesOfString:@"-" withString:@""];
//    NSLog(@"simulator UUID: %@", udid);
//    //46E55A9D-4398-5762-BD22-F8D351422AC2(mac)
//    //647C0579-04AA-4280-85D8-377544AEE7B6(simulator)
//    request.testDevices = @[udid,@"46E55A9D43985762BD22F8D351422AC2"];

    [bannerView loadRequest:request];
    
}
-(void)googleAdsIntegrationWith:(GADBannerView*)googleBannerView andviewController:(UIViewController*)viewController
{
   // _googleAdIsVisible=NO;
    //iOS Google Ads
    NSLog(@"Google Mobile Ads SDK version: %@", [GADRequest sdkVersion]);
    //    googleBannerView=[[GADBannerView alloc]initWithFrame:CGRectMake(0, _yOrigin, 320, 50)];
    [googleBannerView setAdSize:kGADAdSizeBanner];
    googleBannerView.delegate=self;
    googleBannerView.adUnitID = AdUnitId;
    googleBannerView.rootViewController = viewController;
    GADRequest *request = [GADRequest request];
    
    
    NSString *udid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    udid = [udid stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSLog(@"simulator UUID: %@", udid);
    //46E55A9D-4398-5762-BD22-F8D351422AC2(mac)
    //647C0579-04AA-4280-85D8-377544AEE7B6(simulator)
    request.testDevices = @[udid,@"46E55A9D43985762BD22F8D351422AC2"];
    
    [googleBannerView loadRequest:request];
    
}

#pragma mark - Google Ads Delegate methods

/// Tells the delegate an ad request loaded an ad.
- (void)adViewDidReceiveAd:(GADBannerView *)adView
{
    NSLog(@"adViewDidReceiveAd:::%@",adView);
    
    //adView.hidden=NO;
    
    adView.alpha = 0;
    [UIView animateWithDuration:1.0 animations:^{
        adView.alpha = 1;
    }];
    _googleAdIsVisible=YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateUserInterface" object:nil];
    
//    if (!_googleBannerIsVisible)
//    {
//        // If banner isn't part of view hierarchy, add it
//        if (_adBanner.superview == nil)
//        {
//            [self.topViewController.view addSubview:_adBanner];
//        }
//        
//        [UIView beginAnimations:@"animateAdBannerOn" context:NULL];
//        
//        // Assumes the banner view is just off the bottom of the screen.
//        adView.frame = CGRectOffset(adView.frame, 0, -adView.frame.size.height-15);
//        
//        [UIView commitAnimations];
//        
//        _googleBannerIsVisible = YES;
//    }
    
}

/// Tells the delegate an ad request failed.
- (void)adView:(GADBannerView *)adView
didFailToReceiveAdWithError:(GADRequestError *)error
{
    NSLog(@"adView:didFailToReceiveAdWithError: %@", [error localizedDescription]);
    //adView.hidden=YES;
    _googleAdIsVisible=NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateUserInterface" object:nil];
//    if (_googleBannerIsVisible)
//    {
//        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
//        
//        // Assumes the banner view is placed at the bottom of the screen.
//        adView.frame = CGRectOffset(adView.frame, 0, adView.frame.size.height+15);
//        
//        [UIView commitAnimations];
//        
//        _googleBannerIsVisible = NO;
//    }
    
}

/// Tells the delegate that a full screen view will be presented in response
/// to the user clicking on an ad.
- (void)adViewWillPresentScreen:(GADBannerView *)adView
{
    NSLog(@"adViewWillPresentScreen");
}

/// Tells the delegate that the full screen view will be dismissed.
- (void)adViewWillDismissScreen:(GADBannerView *)adView
{
    NSLog(@"adViewWillDismissScreen");
}

/// Tells the delegate that the full screen view has been dismissed.
- (void)adViewDidDismissScreen:(GADBannerView *)adView
{
    NSLog(@"adViewDidDismissScreen");
}

/// Tells the delegate that a user click will open another app (such as
/// the App Store), backgrounding the current app.
- (void)adViewWillLeaveApplication:(GADBannerView *)adView
{
    NSLog(@"adViewWillLeaveApplication");
}
- (UIViewController *)topViewController
{
    return [self topViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (UIViewController *)topViewController:(UIViewController *)rootViewController
{
    if (rootViewController.presentedViewController == nil) {
        return rootViewController;
    }
    
    if ([rootViewController.presentedViewController isMemberOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)rootViewController.presentedViewController;
        UIViewController *lastViewController = [[navigationController viewControllers] lastObject];
        return [self topViewController:lastViewController];
    }
    
    UIViewController *presentedViewController = (UIViewController *)rootViewController.presentedViewController;
    return [self topViewController:presentedViewController];
}

@end
