//
//  RSHistoryViewController.h
//  RideShare
//
//  Created by Reddy on 07/01/16.
//  Copyright © 2016 Reddy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideNavigationController.h"
#import "AppDelegate.h"
@interface RSHistoryViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, SlideNavigationControllerDelegate>
@property (nonatomic, strong) NSMutableArray *myRides;
@property (nonatomic, strong) NSMutableArray *ridesData;
@property (nonatomic, strong) NSMutableArray *pickUpsData;
@property (weak, nonatomic) IBOutlet UITableView *historyListview;
@property (strong, nonatomic) IBOutlet UIView *optionsView;
@property (strong, nonatomic) IBOutlet UIButton *allBtn;
@property (strong, nonatomic) IBOutlet UIButton *ridesBtn;
@property (strong, nonatomic) IBOutlet UIButton *pickUpsBtn;
- (IBAction)allAction:(id)sender;
- (IBAction)ridesAction:(id)sender;
- (IBAction)pickUpsAction:(id)sender;


//////
@property (strong, nonatomic) IBOutlet GADBannerView *googleAdBanner;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *googleAdbottomConstraint;

@end
