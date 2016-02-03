//
//  RideCell.h
//  RideShare
//
//  Created by Reddy on 27/01/16.
//  Copyright © 2016 Reddy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RideCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *sourceDisplay;
@property (weak, nonatomic) IBOutlet UILabel *timeDisplay;
@property (weak, nonatomic) IBOutlet UILabel *statusDisplay;

@property (weak, nonatomic) IBOutlet UILabel *destinationDisplay;
@end
