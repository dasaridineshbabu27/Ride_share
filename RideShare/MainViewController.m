//
//  MainViewController.m
//  RideShare
//
//  Created by Reddy on 04/01/16.
//  Copyright © 2016 Reddy. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString*)segueIdentifierForIndexPathInLeftMenu:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
    {
        case 0:
            return @"HomeViewSegue";
            break;
        case 1:
            return @"PatientsViewSegue";
            break;
        case 2:
            return @"AlertsViewSegue";
            break;
        case 3:
            return @"FAQsViewSegue";
            break;
        case 4:
            return @"AboutUsViewSegue";
            break;
        case 5:
            return @"MyProfileViewSegue";
            break;
        case 6:
            return @"ContactUsViewSegue";
            break;
        case 7:
            return @"LogoutViewSegue";
            break;
        default:
            return @"AppointmentsViewSegue";
            break;
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
