//
//  RSHistoryViewController.h
//  RideShare
//
//  Created by Reddy on 07/01/16.
//  Copyright © 2016 Reddy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideNavigationController.h"

@interface RSHistoryViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, SlideNavigationControllerDelegate>
@property (nonatomic, strong) NSMutableArray *myRides;
@property (weak, nonatomic) IBOutlet UITableView *historyListview;

@end
