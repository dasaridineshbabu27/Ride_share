//
//  RSNotificationsViewController.m
//  RideShare
//
//  Created by Reddy on 05/02/16.
//  Copyright © 2016 Reddy. All rights reserved.
//

#import "RSNotificationsViewController.h"
#import "RSRideInProgressViewController.h"
#import "HGMovingAnnotationSampleViewController.h"

#import "RSServices.h"
#import "RSUtils.h"
#import "RSConfig.h"
#import "AppDelegate.h"
#import "User.h"
#import "NotificationCell.h"
#import "User.h"

@interface RSNotificationsViewController ()
@property  User  *currentUser;
@end

@implementation RSNotificationsViewController
@synthesize notifications;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    _currentUser= [User currentUser];
    _rideInfo = [[NSMutableArray alloc] init];
    
    notifications = [[NSMutableArray alloc] init];
    self.ridesData = [[NSMutableArray alloc] init];
    self.pickUpsData = [[NSMutableArray alloc] init];
    
    _msgListview.allowsMultipleSelectionDuringEditing = NO;
    self.navigationItem.title = @"Notifications";
    
    [self.navigationController.navigationItem setHidesBackButton:YES animated:YES];
    
    _optionsViewN.backgroundColor=[UIColor grayColor];
    _allBtnN.selected=YES;
    _allBtnN.backgroundColor=[UIColor whiteColor];
    [_allBtnN setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [self roundCornerFor:_allBtnN withRadius:CGSizeMake(15.0, 15.0) roundingCorners:(  UIRectCornerTopRight)];
    
    
    _ridesBtnN.selected=NO;
    _ridesBtnN.backgroundColor=[UIColor grayColor];
    [_ridesBtnN setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self roundCornerFor:_ridesBtnN withRadius:CGSizeMake(0.0, 0.0) roundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomRight | UIRectCornerBottomLeft)];
    
    
    _pickUpsBtnN.selected=NO;
    _pickUpsBtnN.backgroundColor=[UIColor grayColor];
    [_pickUpsBtnN setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self roundCornerFor:_pickUpsBtnN withRadius:CGSizeMake(0.0, 0.0) roundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomRight | UIRectCornerBottomLeft)];
    
    [self fetchMessages];
    
    // Do any additional setup after loading the view.
}
-(void)roundCornerFor:(UIView*)view withRadius:(CGSize)radius roundingCorners:(UIRectCorner)corners
{
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds byRoundingCorners:corners cornerRadii:radius];
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = view.bounds;
    maskLayer.path  = maskPath.CGPath;
    view.layer.mask = maskLayer;
    
}
-(NSMutableArray*)sortArray:(NSMutableArray*)mutableArray
{
    
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"start_time"
                                                 ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSArray *array = [NSArray arrayWithArray:mutableArray];
    NSArray *sortedArray = [array sortedArrayUsingDescriptors:sortDescriptors];
    
    NSMutableArray*  myNewArray = [NSMutableArray arrayWithArray:sortedArray];
    
    return myNewArray;
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
                 
                  NSLog(@"\n Received response for Notifications is : %@", response);
                 
                 [_rideInfo removeAllObjects];
                 [notifications removeAllObjects];
                 [_ridesData removeAllObjects];
                 [_pickUpsData removeAllObjects];
                 
                 
                 
                 if (response.count)
                 {
                     [notifications addObjectsFromArray:[response objectForKey:@"response_content"]];
                     [_rideInfo addObjectsFromArray:[response objectForKey:@"ride_info"]];
                     
                
                     
                     for (NSDictionary *dic in notifications)
                     {
                         if ([[dic objectForKey:@"is_rider"] isEqualToString:@"0"] && [[dic objectForKey:@"type"] isEqualToString:@"2"]  )
                         {
                             NSLog(@"\n RIDERRRRRRRRRRR");
                             [_ridesData addObject:dic];
                         }
                         
                         
                        else if ([[dic objectForKey:@"is_rider"] isEqual:@"1"])
                         {
                             [_ridesData addObject:dic];
                         }
                         else
                         {
                             [_pickUpsData addObject:dic];
                         }
                     }
                     
                     //Sort arrays
                     notifications = [self sortArray:notifications];
                     _rideInfo = [self sortArray:_rideInfo];
                     _ridesData = [self sortArray:_ridesData];
                     _pickUpsData = [self sortArray:_pickUpsData];
                     
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
    if (_allBtnN.selected==YES)
    {
        return notifications.count;
    }
    else if (_ridesBtnN.selected==YES)
    {
        return _ridesData.count;
    }
    else if (_pickUpsBtnN.selected==YES)
    {
        return _pickUpsData.count;
    }
    return 0;
    
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NotificationCell *notificationCell = nil;
    static NSString *cellIdentifier = @"NotificationCell";
    notificationCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (notificationCell == nil) {
        notificationCell = [[NotificationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    //////////////////////////////
    NSDictionary *message = [notifications objectAtIndex:indexPath.row];
    notificationCell.nameLabel.text = [message objectForKey:@"name"];
    notificationCell.messageLabel.text = [NSString stringWithFormat:@"%@",[message objectForKey:@"message"]];
    
    notificationCell.acceptButton.tag = indexPath.row;
    [notificationCell.acceptButton addTarget:self action:@selector(acceptButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    notificationCell.stratRideButton.tag = indexPath.row;
    [notificationCell.stratRideButton addTarget:self action:@selector(startButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    ////////////////////////////
    NSDictionary *rideInfo = [_rideInfo objectAtIndex:indexPath.row];
    notificationCell.sourceDisplay.text = [NSString stringWithFormat:@"%@",[rideInfo valueForKey:@"oaddr"]];
    notificationCell.destinationDisplay.text = [NSString stringWithFormat:@"%@",[rideInfo valueForKey:@"daddr"]];
    NSString *dateString = [RSUtils getDisplayDate:[rideInfo valueForKey:@"start_time"]];
    notificationCell.timeDisplay.text =[NSString stringWithFormat:@"%@",dateString];
    
    
    //////////////////////////
    /////////////////////////
    if ([[message valueForKey:@"is_rider"] intValue] == 1 )
    {
       // NSLog(@"\n RIDER");
        //Rider
        if ([[message valueForKey:@"type"] intValue] == 1)
        {
            //NSLog(@"\n RIDE TYPE::::%@",[message valueForKey:@"type"]);
            //Ride
            if ([[message valueForKey:@"is_accepted"] intValue] == 1)
            {
                
               // NSLog(@"\n ACCEPTED");
                notificationCell.acceptButton.hidden = YES;
                notificationCell.stratRideButton.hidden = NO;
                
                if ([[message valueForKey:@"is_start"] intValue] == 1)
                {
                   // NSLog(@"\n STARTED");
                    [notificationCell.stratRideButton setTitle:@"In Progress" forState:UIControlStateNormal];
                    [notificationCell.stratRideButton setUserInteractionEnabled:YES];
                }
                else
                {
                   // NSLog(@"\n NOT STARTED");
                    [notificationCell.stratRideButton setTitle:@"Start" forState:UIControlStateNormal];
                    [notificationCell.stratRideButton setUserInteractionEnabled:YES];

                }
            }
            else
            {
                //NSLog(@"\n NOT ACCEPTED");
                notificationCell.acceptButton.hidden = NO;
                notificationCell.stratRideButton.hidden = YES;
                [notificationCell.acceptButton setTitle:@"Accept" forState:UIControlStateNormal];
            }
            
        }
        else
        {
            //NSLog(@"\n RIDE TYPE::::%@",[message valueForKey:@"type"]);
            
            
            
        }
        
    }
    else
    {
        
       // NSLog(@"\n NOT RIDER");
        //Non Rider
        
        if ([[message valueForKey:@"type"] intValue] == 1)
        {
            //Ride
           // NSLog(@"\n RIDE TYPE::::%@",[message valueForKey:@"type"]);
            if ([[message valueForKey:@"is_accepted"] intValue] == 1)
            {
                
               // NSLog(@"\n ACCEPTED");
                notificationCell.acceptButton.hidden = YES;
                notificationCell.stratRideButton.hidden = NO;
                
                if ([[message valueForKey:@"is_start"] intValue] == 1)
                {
                    //NSLog(@"\n STARTED");
                    [notificationCell.stratRideButton setTitle:@"In Progress" forState:UIControlStateNormal];
                    [notificationCell.stratRideButton setUserInteractionEnabled:YES];
                }
                else
                {
                    //NSLog(@"\n NOT STARTED");
                    [notificationCell.stratRideButton setTitle:@"Accepted" forState:UIControlStateNormal];
                    [notificationCell.stratRideButton setUserInteractionEnabled:NO];
                    
                }
            }
            else
            {
                //NSLog(@"\n NOT ACCEPTED");
                notificationCell.acceptButton.hidden = NO;
                notificationCell.stratRideButton.hidden = YES;
                [notificationCell.acceptButton setTitle:@"Waiting" forState:UIControlStateNormal];
                [notificationCell.acceptButton setUserInteractionEnabled:NO];
            }


            
        }
        else
        {
            //Non Ride
            //NSLog(@"\n RIDE TYPE::::%@",[message valueForKey:@"type"]);
            if ([[message valueForKey:@"is_accepted"] intValue] == 1)
            {
                //NSLog(@"\n ACCEPTED");
                notificationCell.acceptButton.hidden = YES;
                notificationCell.stratRideButton.hidden = NO;
                if ([[message valueForKey:@"is_start"] intValue] == 1)
                {
                   // NSLog(@"\n STARTED");
                    [notificationCell.stratRideButton setTitle:@"In Progress" forState:UIControlStateNormal];
                    [notificationCell.stratRideButton setUserInteractionEnabled:YES];
                }
                else
                {
                   // NSLog(@"\n NOT STARTED");
                    if ( [_currentUser.userId isEqualToString:[rideInfo valueForKey:@"user_id"]])
                    {
                        [notificationCell.stratRideButton setTitle:@"Accepted" forState:UIControlStateNormal];
                        [notificationCell.stratRideButton setUserInteractionEnabled:NO];
                    }
                    else
                    {
                        
                        [notificationCell.stratRideButton setTitle:@"Start" forState:UIControlStateNormal];
                        [notificationCell.stratRideButton setUserInteractionEnabled:YES];
                    }
                    
                }
                
            }
            else
            {
                //NSLog(@"\n NOT ACCEPTED");
                notificationCell.acceptButton.hidden = NO;
                notificationCell.stratRideButton.hidden = YES;
                [notificationCell.acceptButton setTitle:@"Accept" forState:UIControlStateNormal];
                //[notificationCell.acceptButton setUserInteractionEnabled:NO];
                
            }

            
            
            
        }
    }
    
    
    if ([[message valueForKey:@"is_finish"] intValue] == 1)
    {
        notificationCell.acceptButton.hidden = YES;
        notificationCell.stratRideButton.hidden = NO;
        
        [notificationCell.stratRideButton setTitle:@"Finished" forState:UIControlStateNormal];
        [notificationCell.stratRideButton setUserInteractionEnabled:NO];
    }
    
    
    
    return notificationCell;
}

- (void)acceptButtonAction:(UIButton*)acceptButton
{
   // NSLog(@"Accept button tapped.: %@", acceptButton);
    
    NSDictionary *infoDict = @{@"track_id" : [[notifications objectAtIndex:acceptButton.tag] valueForKey:@"track_id"], @"ride_id" : [[notifications objectAtIndex:acceptButton.tag] valueForKey:@"ride_id"],@"to_id":[[notifications objectAtIndex:acceptButton.tag] valueForKey:@"from_id"]};
    
    
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
                 NSLog(@"\n Received response for AcceptRide is : %@", response);
         
                 
                 [_rideInfo removeAllObjects];
                 [notifications removeAllObjects];
                 [_ridesData removeAllObjects];
                 [_pickUpsData removeAllObjects];
                 
                 
                 if (response.count)
                 {
                     [notifications addObjectsFromArray:[response objectForKey:@"response_content"]];
                     [_rideInfo addObjectsFromArray:[response objectForKey:@"ride_info"]];
                     
                     for (NSDictionary *dic in notifications)
                     {
                         
                         if ([[dic objectForKey:@"is_rider"] isEqualToString:@"0"] && [[dic objectForKey:@"type"] isEqualToString:@"2"]  )
                         {
                             NSLog(@"\n RIDERRRRRRRRRRR");
                             [_ridesData addObject:dic];
                         }
                      
                         else if ([[dic objectForKey:@"is_rider"] isEqual:@"1"])
                         {
                             [_ridesData addObject:dic];
                         }
                         else
                         {
                             [_pickUpsData addObject:dic];
                         }
                         
                         //Sort arrays
                         notifications = [self sortArray:notifications];
                         _rideInfo = [self sortArray:_rideInfo];
                         _ridesData = [self sortArray:_ridesData];
                         _pickUpsData = [self sortArray:_pickUpsData];
                         
                         [_msgListview reloadData];
                         
                     }
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

- (void)startButtonAction:(UIButton*)startButton
{
   NSLog(@"Start ride button tapped: %@", _rideInfo);
    
    //int trackId = [[[notifications objectAtIndex:0]valueForKey:@"track_id"] intValue];
    
    
    if ([startButton.titleLabel.text isEqualToString:@"In Progress"])
    {
         //[self performSegueWithIdentifier:@"rideProgressSegue" sender:startButton];
        return;
    }
    
    NSDictionary *infoDict = @{@"track_id" : [[notifications objectAtIndex:startButton.tag] valueForKey:@"track_id"], @"ride_id" : [[notifications objectAtIndex:startButton.tag] valueForKey:@"ride_id"],@"to_id":[[notifications objectAtIndex:startButton.tag] valueForKey:@"from_id"]};
    
    [RSServices processStartRide:infoDict  completionHandler:^(NSDictionary *response, NSError *error)
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
                  NSLog(@"\n Received response for StartRide is : %@", response);
                 
                 [_rideInfo removeAllObjects];
                 [notifications removeAllObjects];
                 [_ridesData removeAllObjects];
                 [_pickUpsData removeAllObjects];
                 
                 if (response.count)
                 {
                     [notifications addObjectsFromArray:[response objectForKey:@"response_content"]];
                     [_rideInfo addObjectsFromArray:[response objectForKey:@"ride_info"]];
                     
                     for (NSDictionary *dic in notifications)
                     {
                         if ([[dic objectForKey:@"is_rider"] isEqualToString:@"0"] && [[dic objectForKey:@"type"] isEqualToString:@"2"]  )
                         {
                             NSLog(@"\n RIDERRRRRRRRRRR");
                             [_ridesData addObject:dic];
                         }
                         
                          else if ([[dic objectForKey:@"is_rider"] isEqual:@"1"])
                         {
                             [_ridesData addObject:dic];
                         }
                         else
                         {
                             [_pickUpsData addObject:dic];
                         }
                         
                         //Sort arrays
                         notifications = [self sortArray:notifications];
                         _rideInfo = [self sortArray:_rideInfo];
                         _ridesData = [self sortArray:_ridesData];
                         _pickUpsData = [self sortArray:_pickUpsData];
                         
                         [_msgListview reloadData];
                         
                     }
                 }
                 
                 
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
   // NSLog(@"Table View cell selected at index: %li", (long)indexPath.row);
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
    //    if ([segue.destinationViewController isKindOfClass:[RSRideInProgressViewController class]])
    //    {
    //        RSRideInProgressViewController *rideViewController = segue.destinationViewController;
    //
    //        NSLog(@"ride info is : %@", rideInfo);
    //        NSLog(@"Notifications: %@", notifications);
    //
    //
    //          rideViewController.otherUser_id= [[notifications objectAtIndex:[sender tag]] valueForKey:@"from_id"];
    //
    //        rideViewController.ride_info=[rideInfo objectAtIndex:[sender tag]];
    //        rideViewController.notification=[notifications objectAtIndex:[sender tag]];
    //
    //        rideViewController.pickUpLocation = CLLocationCoordinate2DMake([[[notifications objectAtIndex:[sender tag]] valueForKey:@"pick_lat"] floatValue], [[[notifications objectAtIndex:[sender tag]] valueForKey:@"pick_lang"] floatValue]);
    //
    //
    //        rideViewController.startCoordinate = CLLocationCoordinate2DMake([[[rideInfo objectAtIndex:[sender tag]] valueForKey:@"olat"] floatValue], [[[rideInfo objectAtIndex:[sender tag]] valueForKey:@"olang"] floatValue]);
    //
    //        rideViewController.destinationCoordinate = CLLocationCoordinate2DMake([[[rideInfo objectAtIndex:[sender tag]]valueForKey:@"dlat"] floatValue], [[[rideInfo objectAtIndex:[sender tag]] valueForKey:@"dlang"] floatValue]);
    //    }
    
    
    //if ([segue.destinationViewController isKindOfClass:[HGMovingAnnotationSampleViewController class]])
        
    if ([[segue identifier] isEqualToString:@"rideProgressSegue"])
    {
        HGMovingAnnotationSampleViewController *rideViewController = segue.destinationViewController;
        
       // NSLog(@"ride info is : %@", _rideInfo);
       // NSLog(@"Notifications: %@", notifications);
        
        
        rideViewController.otherUser_id= [[notifications objectAtIndex:[sender tag]] valueForKey:@"from_id"];
        
        rideViewController.ride_info=[_rideInfo objectAtIndex:[sender tag]];
        rideViewController.notification=[notifications objectAtIndex:[sender tag]];
        
        rideViewController.pickUpLocation = CLLocationCoordinate2DMake([[[notifications objectAtIndex:[sender tag]] valueForKey:@"pick_lat"] floatValue], [[[notifications objectAtIndex:[sender tag]] valueForKey:@"pick_lang"] floatValue]);
        
        
        rideViewController.startCoordinate = CLLocationCoordinate2DMake([[[_rideInfo objectAtIndex:[sender tag]] valueForKey:@"olat"] floatValue], [[[_rideInfo objectAtIndex:[sender tag]] valueForKey:@"olang"] floatValue]);
        
        rideViewController.destinationCoordinate = CLLocationCoordinate2DMake([[[_rideInfo objectAtIndex:[sender tag]]valueForKey:@"dlat"] floatValue], [[[_rideInfo objectAtIndex:[sender tag]] valueForKey:@"dlang"] floatValue]);
    }
    
}


- (IBAction)allActionN:(id)sender
{
    _allBtnN.selected=YES;
    _allBtnN.backgroundColor=[UIColor whiteColor];
    [_allBtnN setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    
    
    _ridesBtnN.selected=NO;
    _ridesBtnN.backgroundColor=[UIColor grayColor];
    [_ridesBtnN setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    
    _pickUpsBtnN.selected=NO;
    _pickUpsBtnN.backgroundColor=[UIColor grayColor];
    [_pickUpsBtnN setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [self roundCornerFor:_allBtnN withRadius:CGSizeMake(15.0, 15.0) roundingCorners:(  UIRectCornerTopRight)];
    [self roundCornerFor:_ridesBtnN withRadius:CGSizeMake(0.0, 0.0) roundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomRight | UIRectCornerBottomLeft)];
    [self roundCornerFor:_pickUpsBtnN withRadius:CGSizeMake(0.0, 0.0) roundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomRight | UIRectCornerBottomLeft)];
    
    [_msgListview reloadData];
}

- (IBAction)ridesActionN:(id)sender {
    
    
    _allBtnN.selected=NO;
    _allBtnN.backgroundColor=[UIColor grayColor];
    [_allBtnN setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    
    
    
    _ridesBtnN.selected=YES;
    _ridesBtnN.backgroundColor=[UIColor whiteColor];
    [_ridesBtnN setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    
    
    _pickUpsBtnN.selected=NO;
    _pickUpsBtnN.backgroundColor=[UIColor grayColor];
    [_pickUpsBtnN setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [self roundCornerFor:_allBtnN withRadius:CGSizeMake(0.0, 0.0) roundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomRight | UIRectCornerBottomLeft)];
    [self roundCornerFor:_ridesBtnN withRadius:CGSizeMake(15.0, 15.0) roundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight )];
    [self roundCornerFor:_pickUpsBtnN withRadius:CGSizeMake(0.0, 0.0) roundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomRight | UIRectCornerBottomLeft)];
    [_msgListview reloadData];
}

- (IBAction)pickUpsActionN:(id)sender {
    
    
    _allBtnN.selected=NO;
    _allBtnN.backgroundColor=[UIColor grayColor];
    [_allBtnN setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    
    _ridesBtnN.selected=NO;
    _ridesBtnN.backgroundColor=[UIColor grayColor];
    [_ridesBtnN setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    
    _pickUpsBtnN.selected=YES;
    _pickUpsBtnN.backgroundColor=[UIColor whiteColor];
    [_pickUpsBtnN setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    
    [self roundCornerFor:_allBtnN withRadius:CGSizeMake(0.0, 0.0) roundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomRight | UIRectCornerBottomLeft)];
    [self roundCornerFor:_ridesBtnN withRadius:CGSizeMake(0.0, 0.0) roundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomRight | UIRectCornerBottomLeft)];
    [self roundCornerFor:_pickUpsBtnN withRadius:CGSizeMake(15.0, 15.0) roundingCorners:(UIRectCornerTopLeft )];
    [_msgListview reloadData];
}

@end


