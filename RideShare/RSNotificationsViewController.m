//
//  RSNotificationsViewController.m
//  RideShare
//
//  Created by Reddy on 05/02/16.
//  Copyright © 2016 Reddy. All rights reserved.
//

#import "RSNotificationsViewController.h"
#import "RSRideInProgressViewController.h"

#import "RSServices.h"
#import "RSUtils.h"
#import "RSConfig.h"
#import "AppDelegate.h"
#import "User.h"
#import "NotificationCell.h"
#import "User.h"

@interface RSNotificationsViewController ()

@end

@implementation RSNotificationsViewController
@synthesize notifications;

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.automaticallyAdjustsScrollViewInsets = NO;
    rideInfo = [[NSArray alloc] init];
    
    _msgListview.allowsMultipleSelectionDuringEditing = NO;
    self.navigationItem.title = @"Notifications";
    
    [self.navigationController.navigationItem setHidesBackButton:YES animated:YES];
    
    notifications = [[NSMutableArray alloc] init];
    [self fetchMessages];
    
    // Do any additional setup after loading the view.
}

- (void)fetchMessages
{
    [appDelegate showLoaingWithTitle:nil];
    [RSServices processFetchNotifications:@{@"user_id" : [[User currentUser] userId]} completionHandler:^(NSDictionary * response, NSError *error)
     {
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
                 [notifications removeAllObjects];
                 [notifications addObjectsFromArray:[response objectForKey:@"response_content"]];
                 rideInfo = [response objectForKey:@"ride_info"];                 
                 if (notifications.count)
                 {
                     [_msgListview reloadData];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return notifications.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NotificationCell *notificationCell = nil;
    static NSString *cellIdentifier = @"NotificationCell";
    notificationCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (notificationCell == nil) {
        notificationCell = [[NotificationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSDictionary *message = [notifications objectAtIndex:indexPath.row];
    
    notificationCell.nameLabel.text = [message objectForKey:@"name"];
    notificationCell.messageLabel.text = [message objectForKey:@"message"];
    [notificationCell.acceptButton addTarget:self action:@selector(acceptButtonAction:) forControlEvents:UIControlEventTouchUpInside];

    notificationCell.acceptButton.tag = indexPath.row;
    notificationCell.stratRideButton.tag = indexPath.row;
    [notificationCell.acceptButton addTarget:self action:@selector(startButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    if ([[message valueForKey:@"is_accepted"] intValue] == 1)
    {
        notificationCell.acceptButton.hidden = YES;
        notificationCell.stratRideButton.hidden = NO;
    }
    else
    {
        notificationCell.acceptButton.hidden = NO;
        notificationCell.stratRideButton.hidden = YES;
    }
    return notificationCell;
}

- (void)acceptButtonAction:(UIButton*)acceptButton
{
    NSLog(@"Accept button tapped.: %@", acceptButton);
    
    NSDictionary *infoDict = @{@"track_id" : [[notifications objectAtIndex:acceptButton.tag] valueForKey:@"track_id"], @"ride_id" : [[notifications objectAtIndex:acceptButton.tag] valueForKey:@"ride_id"]};
    [RSServices processAcceptRide:infoDict completionHandler:^(NSDictionary * response, NSError *error)
     {
         [appDelegate hideLoading];
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
                 [notifications removeAllObjects];
                 [notifications addObjectsFromArray:[response objectForKey:@"response_content"]];
                 rideInfo = [response objectForKey:@"ride_info"];
                 if (notifications.count)
                 {
                     [_msgListview reloadData];
                 }
             }
             else
             {
                 UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                            {
//                                                [self.navigationController popViewControllerAnimated:YES];
                                            }];
                 [RSUtils showAlertWithTitle:@"Falied" message:[response objectForKey:kResponseMessage] actionOne:okAction actionTwo:nil inView:self];
                 return;
             }
         }
     }];
}

- (void)startButtonAction
{
    NSLog(@"Start ride button tapped: %@", rideInfo);
    
    int trackId = [[[notifications objectAtIndex:0]valueForKey:@"track_id"] intValue];
    
    [RSServices processStartRide:@{@"track_id" : [NSString stringWithFormat:@"%i", trackId], @"user_id": [User currentUser].userId}  completionHandler:^(NSDictionary *response, NSError *error) {
                   [appDelegate hideLoading];
                   if (error != nil)
                   {
                       [RSUtils showAlertForError:error inView:self];
                   }
                   else if (response != nil)
                   {
                       if ([[response objectForKey:kResponseCode] intValue] == kRequestSuccess)
                       {
                           NSLog(@"Received response for my ride is : %@", response);
                       }
                       else
                       {
                           UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                           
                           [RSUtils showAlertWithTitle:@"Falied" message:[response objectForKey:kResponseMessage] actionOne:okAction actionTwo:nil inView:self];
                           return;
                       }
                   }
               }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Table View cell selected at index: %li", (long)indexPath.row);
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
    return NO;
}

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[RSRideInProgressViewController class]])
    {
        RSRideInProgressViewController *rideViewController = segue.destinationViewController;
        
        NSLog(@"ride info is : %@", rideInfo);
        NSLog(@"Notifications: %@", notifications);
        
        rideViewController.pickUpLocation = CLLocationCoordinate2DMake([[[notifications objectAtIndex:0] valueForKey:@"pick_lat"] floatValue], [[[notifications objectAtIndex:0] valueForKey:@"pick_lang"] floatValue]);
        
        rideViewController.startCoordinate = CLLocationCoordinate2DMake([[[rideInfo objectAtIndex:0] valueForKey:@"olat"] floatValue], [[[rideInfo objectAtIndex:0] valueForKey:@"olang"] floatValue]);
        
        rideViewController.destinationCoordinate = CLLocationCoordinate2DMake([[[rideInfo objectAtIndex:0]valueForKey:@"dlat"] floatValue], [[[rideInfo objectAtIndex:0] valueForKey:@"dlang"] floatValue]);
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
