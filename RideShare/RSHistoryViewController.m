//
//  RSHistoryViewController.m
//  RideShare
//
//  Created by Reddy on 07/01/16.
//  Copyright © 2016 Reddy. All rights reserved.
//

#import "RSHistoryViewController.h"
#import "UIViewController+AMSlideMenu.h"
#import "AppDelegate.h"
#import "RSConstants.h"
#import "RSUtils.h"
#import "RSServices.h"
#import "User.h"
#import "RideCell.h"

@interface RSHistoryViewController ()

@end

@implementation RSHistoryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _historyListview.allowsMultipleSelectionDuringEditing = NO;
    
    self.myRides = [[NSMutableArray alloc] init];
    self.automaticallyAdjustsScrollViewInsets = NO;
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(menuClicked)];
    leftButton.image = [UIImage imageNamed:@"Hamburger_menu"];
    self.navigationItem.leftBarButtonItem = leftButton;
    // Do any additional setup after loading the view.
    [self fetchMyHistory];
}

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
    return NO;
}

-(void)viewWillAppear:(BOOL)animated
{
    [_historyListview reloadData];
}

-(void)fetchMyHistory
{
    User *currentUser = [User currentUser];
    [appDelegate showLoaingWithTitle:@"Loading..."];
    [RSServices processFetchHistory:@{@"user_id" : currentUser.userId} completionHandler:^(NSDictionary *response, NSError *error) {
            [appDelegate hideLoading];
            NSString *alertMsg = nil;
            if (error != nil)
            {
                [RSUtils showAlertForError:error inView:self];
            }
            else if (response != nil)
            {
                if ([[response objectForKey:kResponseCode] intValue] == kRequestSuccess)
                {
                    NSLog(@"Login success! with info: %@", response);
                    NSLog(@"Received response for my ride is : %@", response);
                    [_myRides removeAllObjects];
                    [_myRides addObjectsFromArray:[response objectForKey:@"response_content"]];
                    if (_myRides.count) {
                        [_historyListview reloadData];
                    }
                }
                else
                {
                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                               {
                                                   [self.navigationController popViewControllerAnimated:YES];
                                               }];
                    [RSUtils showAlertWithTitle:@"Falied" message:[response objectForKey:kResponseMessage] actionOne:okAction actionTwo:nil inView:self];
                    return;
                }
            }
    }];
}

- (void)menuClicked
{
    [[self mainSlideMenu] openLeftMenu];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _myRides.count;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    NSLog(@"selected in %li", (long)indexPath.row);
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RideCell *cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:@"RideCell"];
    if (cell == nil)
    {
        cell = [[RideCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"RideCell"];
    }
    NSDictionary *tempRide = [_myRides objectAtIndex:indexPath.row];
    
    NSLog(@"all subviews are : %@", cell.subviews);
    NSLog(@"all subviews are : %@", cell.contentView.subviews);

    cell.sourceDisplay.text = [NSString stringWithFormat:@"Origination: %@",[tempRide valueForKey:@"oaddr"]];
    cell.destinationDisplay.text = [NSString stringWithFormat:@"Destination: %@",[tempRide valueForKey:@"daddr"]];
    NSString *dateString = [RSUtils getDisplayDate:[tempRide valueForKey:@"start_time"]];
    
    cell.timeDisplay.text = dateString;
    
    cell.statusDisplay.text = [NSString stringWithFormat:@"Status: %@",[tempRide valueForKey:@"status"]];
    
//    cell.textLabel.text = [NSString stringWithFormat:@"Transaction %li", (long)indexPath.row];
//    cell.detailTextLabel.text = @"07-01-2016";
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView reloadData];
    
//    NSDictionary *infoDict = @{@"user_id" : currentUser.userId, @"ride_id" : [[_myRides objectAtIndex:indexPath.row] valueForKey:@"ride_id"]};
    
    if ([[[_myRides objectAtIndex:indexPath.row] valueForKey:@"ride_type"] intValue] == 1)
    {
        [self cancelMyRide:[_myRides objectAtIndex:indexPath.row] forIndexPath:indexPath];
    }
    else
    {
        [self cancelPickMeUp:[_myRides objectAtIndex:indexPath.row] forIndexPath:indexPath];
    }
    
//    [RSServices processDeleteRequest:infoDict completionHandler:^(NSDictionary *response, NSError *error)
//     {
//         [appDelegate hideLoading];
//         NSString *alertMsg = nil;
//         if (error != nil)
//         {
//             alertMsg = error.description;
//         }
//         else if (response != nil)
//         {
//             if ([[response objectForKey:kResponseCode] intValue] == kRequestSuccess)
//             {
//                 NSLog(@"Delete Request success! with info: %@", response);
//                 [_myRides removeObjectAtIndex:indexPath.row];
//                 [_historyListview reloadData];
//             }
//             else
//             {
//                 UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
//                                            {
//                                                [self.navigationController popViewControllerAnimated:YES];
//                                            }];
//                 [RSUtils showAlertWithTitle:@"Falied" message:[response objectForKey:kResponseMessage] actionOne:okAction actionTwo:nil inView:self];
//                 return;
//             }
//         }
//         
//         if (alertMsg.length != 0)
//         {
//             [RSUtils showAlertWithTitle:@"History" message:alertMsg actionOne:nil actionTwo:nil inView:self];
//         }
//     }];
//    NSLog(@"Comit editing style");
}

- (void)cancelMyRide:(NSDictionary*)rideInfo forIndexPath:(NSIndexPath*)indexPath
{
    [appDelegate showLoaingWithTitle:@"Loading..."];
    NSDictionary *infoDict = @{@"user_id" : [User currentUser].userId, @"ride_id" : [rideInfo valueForKey:@"ride_id"]};
    
    [RSServices processDeleteMyRideRequest:infoDict completionHandler:^(NSDictionary *response, NSError *error)
     {
         [appDelegate hideLoading];
         NSString *alertMsg = nil;
         if (error != nil)
         {
             alertMsg = error.description;
         }
         else if (response != nil)
         {
             if ([[response objectForKey:kResponseCode] intValue] == kRequestSuccess)
             {
                 NSLog(@"Delete Request success! with info: %@", response);
                 [_myRides removeObjectAtIndex:indexPath.row];
                 [_historyListview reloadData];
             }
             else
             {
                 UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                            {
                                                [self.navigationController popViewControllerAnimated:YES];
                                            }];
                 [RSUtils showAlertWithTitle:@"Falied" message:[response objectForKey:kResponseMessage] actionOne:okAction actionTwo:nil inView:self];
                 return;
             }
         }
         
         if (alertMsg.length != 0)
         {
             [RSUtils showAlertWithTitle:@"History" message:alertMsg actionOne:nil actionTwo:nil inView:self];
         }
     }];
}

- (void)cancelPickMeUp:(NSDictionary*)rideInfo forIndexPath:(NSIndexPath*)indexPath
{
    [appDelegate showLoaingWithTitle:@"Loading..."];
    NSDictionary *infoDict = @{@"user_id" : [User currentUser].userId, @"ride_id" : [rideInfo valueForKey:@"ride_id"]};
    
    [RSServices processDeleteMyRideRequest:infoDict completionHandler:^(NSDictionary *response, NSError *error)
     {
         [appDelegate hideLoading];
         NSString *alertMsg = nil;
         if (error != nil)
         {
             alertMsg = error.description;
         }
         else if (response != nil)
         {
             if ([[response objectForKey:kResponseCode] intValue] == kRequestSuccess)
             {
                 NSLog(@"Delete Request success! with info: %@", response);
                 [_myRides removeObjectAtIndex:indexPath.row];
                 [_historyListview reloadData];
             }
             else
             {
                 UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                            {
                                                [self.navigationController popViewControllerAnimated:YES];
                                            }];
                 [RSUtils showAlertWithTitle:@"Falied" message:[response objectForKey:kResponseMessage] actionOne:okAction actionTwo:nil inView:self];
                 return;
             }
         }
         
         if (alertMsg.length != 0)
         {
             [RSUtils showAlertWithTitle:@"History" message:alertMsg actionOne:nil actionTwo:nil inView:self];
         }
     }];
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
