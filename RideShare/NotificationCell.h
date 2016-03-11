//
//  NotificationCell.h
//  RideShare
//
//  Created by Reddy on 05/02/16.
//  Copyright © 2016 Reddy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationCell : UITableViewCell
{
    
}

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *messageLabel;
@property (nonatomic, weak) IBOutlet UIButton *acceptButton;
@property (nonatomic, weak) IBOutlet UIButton *stratRideButton;

@property (weak, nonatomic) IBOutlet UILabel *sourceDisplay;
@property (weak, nonatomic) IBOutlet UILabel *timeDisplay;
@property (weak, nonatomic) IBOutlet UILabel *statusDisplay;
@property (weak, nonatomic) IBOutlet UILabel *destinationDisplay;

@end
