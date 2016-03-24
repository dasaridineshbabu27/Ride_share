//
//  RSFAQsViewController.h
//  RideShare
//
//  Created by Reddy on 07/01/16.
//  Copyright © 2016 Reddy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideNavigationController.h"
#import "AppDelegate.h"
@interface RSFAQsViewController : UIViewController <UIWebViewDelegate, SlideNavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *contentLoader;


//////
@property (strong, nonatomic) IBOutlet GADBannerView *googleAdBanner;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *googleAdbottomConstraint;

@end
