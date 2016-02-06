//
//  RSNotificationsViewController.m
//  RideShare
//
//  Created by Reddy on 05/02/16.
//  Copyright © 2016 Reddy. All rights reserved.
//

#import "RSNotificationsViewController.h"
#import "RSServices.h"
#import "RSUtils.h"
#import "RSConfig.h"
#import "AppDelegate.h"
#import "User.h"
#import "NotificationCell.h"

@interface RSNotificationsViewController ()

@end

@implementation RSNotificationsViewController
@synthesize notifications;

- (void)viewDidLoad {
    [super viewDidLoad];
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
    [notificationCell.acceptButton addTarget:self action:@selector(acceptButtonAction) forControlEvents:UIControlEventTouchUpInside];

    [notificationCell.acceptButton addTarget:self action:@selector(startButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [notificationCell.stratRideButton setHidden:YES];
    return notificationCell;
}

- (void)acceptButtonAction
{
    NSLog(@"Accept button tapped.");
}

- (void)startButtonAction
{
    NSLog(@"Start ride button tapped.");
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
