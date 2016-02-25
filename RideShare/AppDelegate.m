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

@interface AppDelegate ()

@property BOOL registered;
@property NSString *scoketID;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    // Override point for customization after application launch.
    [GMSServices provideAPIKey:GoogleMapsAPIKey];
    [IQKeyboardManager sharedManager].enable = YES;
    
   	UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    
    LeftMenuViewController *leftMenu = (LeftMenuViewController*)[mainStoryboard
                                                                 instantiateViewControllerWithIdentifier: @"LeftMenuViewController"];
    
    RightMenuViewController *rightMenu = (RightMenuViewController*)[mainStoryboard
                                                                    instantiateViewControllerWithIdentifier: @"RightMenuViewController"];
    
    [SlideNavigationController sharedInstance].rightMenu = rightMenu;
    [SlideNavigationController sharedInstance].leftMenu = leftMenu;
    [SlideNavigationController sharedInstance].menuRevealAnimationDuration = .18;
    
    // Creating a custom bar button for right menu
    UIButton *button  = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [button setImage:[UIImage imageNamed:@"gear"] forState:UIControlStateNormal];
    [button addTarget:[SlideNavigationController sharedInstance] action:@selector(toggleRightMenu) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    [SlideNavigationController sharedInstance].rightBarButtonItem = rightBarButtonItem;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:SlideNavigationControllerDidClose object:nil queue:nil usingBlock:^(NSNotification *note) {
        NSString *menu = note.userInfo[@"menu"];
        NSLog(@"Closed %@", menu);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:SlideNavigationControllerDidOpen object:nil queue:nil usingBlock:^(NSNotification *note) {
        NSString *menu = note.userInfo[@"menu"];
        NSLog(@"Opened %@", menu);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:SlideNavigationControllerDidReveal object:nil queue:nil usingBlock:^(NSNotification *note) {
        NSString *menu = note.userInfo[@"menu"];
        NSLog(@"Revealed %@", menu);
    }];
    
    UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    
    return YES;
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
    NSLog(@"the generated device token string is : %@",deviceToken);
    
    self.deviceToken = [[[[deviceToken description]                                                    stringByReplacingOccurrencesOfString: @"<" withString: @""]stringByReplacingOccurrencesOfString: @">" withString: @""]                                                       stringByReplacingOccurrencesOfString: @" " withString: @""];
    
    NSLog(@"the generated device token string is : %@",self.deviceToken);
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(nonnull NSDictionary *)userInfo
{
    NSLog(@"Push received with user info: %@", userInfo);
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Title" message:@"Someone expecting ride from you." preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *acceptAction = [UIAlertAction actionWithTitle:@"Accept Request" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"Accepting Ride");
    }];
    
    UIAlertAction *ignoreAction = [UIAlertAction actionWithTitle:@"Ignore" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"Ignore clicked!");
    }];
    
    [alertController addAction:acceptAction];
    [alertController addAction:ignoreAction];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    NSLog(@"didReceiveRemoteNotification : fetchCompletionHandler");
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
    NSLog(@"Hiding from AppDelegate");
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

-(void)initiateClientSocket
{
    //////// Real code
    NSURL* scoketURL = [[NSURL alloc] initWithString:@"http://192.168.0.104:3000"];
    self.socketClient = [[SocketIOClient alloc] initWithSocketURL:scoketURL options:@{@"log": @NO, @"forcePolling": @NO}];
    [self.socketClient connect];
    self.socketClient.reconnects = YES;
    [self addHandlers];
}

-(void)addHandlers
{
    
    ////Getting Event
    [self.socketClient onAny:^(SocketAnyEvent *event)
     {
         NSLog(@"\n \n socket event:::%@ /n count:::%lu",event,event.items.count);
         
         if(event.items.count)
         {
             NSLog(@"\n \n socket event first Object :::%@",[event.items objectAtIndex:0]);
             
             if (!_registered)
             {
                 ////////Register UserID
                 _scoketID=[[event.items objectAtIndex:0] valueForKey:@"id"];
                 if (_scoketID !=nil)
                 {
                     
                     NSLog(@"\n \n _scoketID:::%@",_scoketID);
                     
                     if ([User currentUser]!= nil )
                     {
                         ///////////Register users scoket
                         NSArray *userArrr=[NSArray arrayWithObjects: [User currentUser].userId,_scoketID,@"1",nil];
                         [self.socketClient emit:@"register" withItems:userArrr];
                     }
                     _registered = YES;
                 }
                 else
                 {
                     NSLog(@"\n \n Failed to register chat");
                 }
                 
             }
             else
             {
                 //////update map with received data
                 NSLog(@"\n \n Update Map with Received data");
                 
             }
             
         }
         else
         {
             NSLog(@"\n \n No Event ");
         }
         
     }
     ];
    
    //////Scoket Connected
    [ self.socketClient on:@"connect" callback:^(NSArray* data, SocketAckEmitter* ack)
     {
         NSLog(@"\n \n socket connected:::data====%@ \n SocketAckEmitter====%@ ",data,ack.description);
         
         
     }];
    
    /////Scoket disconnected
    [self.socketClient on:@"disconnect" callback:^(NSArray* data, SocketAckEmitter* ack)
     {
         
         NSLog(@"\n \n socket disconnect:::data====%@ \n SocketAckEmitter====%@ ",data,ack);
         
         
         if( [User currentUser]!= nil)
         {
             if (self.socketClient.status == SocketIOClientStatusClosed && [RSUtils isNetworkReachable])
             {
                 [self initiateClientSocket];
             }
         }
         
     }];
}

- (void)disconnectClientSocket
{
    NSLog(@"\n Finish button tapped");
    if (self.socketClient != nil && self.socketClient.status == SocketIOClientStatusConnected)
    {
        [self.socketClient disconnect];
        [self.socketClient removeAllHandlers];
        [self.socketClient close];
    }
    
}


@end
