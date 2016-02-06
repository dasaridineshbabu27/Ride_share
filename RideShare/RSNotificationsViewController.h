//
//  RSNotificationsViewController.h
//  RideShare
//
//  Created by Reddy on 05/02/16.
//  Copyright © 2016 Reddy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideNavigationController.h"

@interface RSNotificationsViewController : UIViewController <SlideNavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate>
{
    NSArray *rideInfo;
}
@property (nonatomic, weak) IBOutlet UITableView *msgListview;
@property (nonatomic, strong) NSMutableArray *notifications;

@end
