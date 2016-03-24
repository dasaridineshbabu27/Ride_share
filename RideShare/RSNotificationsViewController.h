//
//  RSNotificationsViewController.h
//  RideShare
//
//  Created by Reddy on 05/02/16.
//  Copyright © 2016 Reddy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideNavigationController.h"
#import "AppDelegate.h"
@interface RSNotificationsViewController : UIViewController <SlideNavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate>
{
    
}
@property (nonatomic, weak) IBOutlet UITableView *msgListview;


@property (nonatomic, strong) NSMutableArray  *rideInfo;

@property (nonatomic, strong) NSMutableArray *notifications;
@property (nonatomic, strong) NSMutableArray *ridesData;
@property (nonatomic, strong) NSMutableArray *pickUpsData;


@property (strong, nonatomic) IBOutlet UIView *optionsViewN;
@property (strong, nonatomic) IBOutlet UIButton *allBtnN;
@property (strong, nonatomic) IBOutlet UIButton *ridesBtnN;
@property (strong, nonatomic) IBOutlet UIButton *pickUpsBtnN;
- (IBAction)allActionN:(id)sender;
- (IBAction)ridesActionN:(id)sender;
- (IBAction)pickUpsActionN:(id)sender;


//////
@property (strong, nonatomic) IBOutlet GADBannerView *googleAdBanner;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *googleAdbottomConstraint;

@end
