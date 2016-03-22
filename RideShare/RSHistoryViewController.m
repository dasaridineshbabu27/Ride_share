//
//  RSHistoryViewController.m
//  RideShare
//
//  Created by Reddy on 07/01/16.
//  Copyright © 2016 Reddy. All rights reserved.
//

#import "RSHistoryViewController.h"
#import "UIViewController+AMSlideMenu.h"
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
    //self.canDisplayBannerAds = YES;
    _historyListview.allowsMultipleSelectionDuringEditing = NO;
    
    self.myRides = [[NSMutableArray alloc] init];
    self.ridesData = [[NSMutableArray alloc] init];
    self.pickUpsData = [[NSMutableArray alloc] init];
    self.automaticallyAdjustsScrollViewInsets = NO;
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(menuClicked)];
    leftButton.image = [UIImage imageNamed:@"Hamburger_menu"];
    self.navigationItem.leftBarButtonItem = leftButton;
    // Do any additional setup after loading the view.
    
    _optionsView.backgroundColor=[UIColor grayColor];
    _allBtn.selected=YES;
    _allBtn.backgroundColor=[UIColor whiteColor];
    [_allBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
     [self roundCornerFor:_allBtn withRadius:CGSizeMake(15.0, 15.0) roundingCorners:(  UIRectCornerTopRight)];
    
    

    _ridesBtn.selected=NO;
    _ridesBtn.backgroundColor=[UIColor grayColor];
    [_ridesBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
     [self roundCornerFor:_ridesBtn withRadius:CGSizeMake(0.0, 0.0) roundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomRight | UIRectCornerBottomLeft)];
    

    _pickUpsBtn.selected=NO;
    _pickUpsBtn.backgroundColor=[UIColor grayColor];
    [_pickUpsBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
     [self roundCornerFor:_pickUpsBtn withRadius:CGSizeMake(0.0, 0.0) roundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomRight | UIRectCornerBottomLeft)];

    
    [self fetchMyHistory];
    
    
}
-(void)roundCornerFor:(UIView*)view withRadius:(CGSize)radius roundingCorners:(UIRectCorner)corners
{
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds byRoundingCorners:corners cornerRadii:radius];
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = view.bounds;
    maskLayer.path  = maskPath.CGPath;
    view.layer.mask = maskLayer;
    
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
                //NSLog(@"Login success! with info: %@", response);
                //NSLog(@"Received response for my ride is : %@", response);
                [_myRides removeAllObjects];
                [_ridesData removeAllObjects];
                [_pickUpsData removeAllObjects];
                
                [_myRides addObjectsFromArray:[response objectForKey:@"response_content"]];
                
                if (_myRides.count)
                {
                    for (NSDictionary *dic in _myRides)
                    {
                        if ([[dic objectForKey:@"ride_type"] isEqual:@"1"])
                        {
                            [_ridesData addObject:dic];
                        }
                        else
                        {
                            [_pickUpsData addObject:dic];
                        }
                    }
                    
                    //Sort arrays
                   _myRides = [self sortArray:_myRides];
                     _ridesData = [self sortArray:_ridesData];
                     _pickUpsData = [self sortArray:_pickUpsData];
                    
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
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (_allBtn.selected==YES)
    {
        return _myRides.count;
    }
    else if (_ridesBtn.selected==YES)
    {
        return _ridesData.count;
    }
    else if (_pickUpsBtn.selected==YES)
    {
        return _pickUpsData.count;
    }
    return 0;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    //NSLog(@"selected in %li", (long)indexPath.row);
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
    
    NSDictionary *tempRide ;
    
    if (_allBtn.selected==YES)
    {
        tempRide = [_myRides objectAtIndex:indexPath.row];
    }
    else if (_ridesBtn.selected==YES)
    {
        tempRide = [_ridesData objectAtIndex:indexPath.row];
    }
    else if (_pickUpsBtn.selected==YES)
    {
        tempRide = [_pickUpsData objectAtIndex:indexPath.row];
    }
    
    //NSDictionary *tempRide = [_myRides objectAtIndex:indexPath.row];
    
    //NSLog(@"all subviews are : %@", cell.subviews);
    //NSLog(@"all subviews are : %@", cell.contentView.subviews);
    
    cell.sourceDisplay.text = [NSString stringWithFormat:@"%@",[tempRide valueForKey:@"oaddr"]];
    cell.destinationDisplay.text = [NSString stringWithFormat:@"%@",[tempRide valueForKey:@"daddr"]];
    NSString *dateString = [RSUtils getDisplayDate:[tempRide valueForKey:@"start_time"]];
    
    cell.timeDisplay.text = dateString;
    
    if ([[tempRide valueForKey:@"status"]  isEqual: @"1"])
    {
        cell.statusDisplay.text = [NSString stringWithFormat:@"Active"];
    }
    else  if ([[tempRide valueForKey:@"status"]  isEqual: @"0"])
    {
        cell.statusDisplay.text = [NSString stringWithFormat:@"Finished"];
    }
    else  if ([[tempRide valueForKey:@"status"]  isEqual: @"2"])
    {
        cell.statusDisplay.text = [NSString stringWithFormat:@"Cancelled"];
    }
    
    
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
                 //NSLog(@"Delete Request success! with info: %@", response);
                 [_myRides removeObjectAtIndex:indexPath.row];
                 
//                 //Sort arrays
//                 _myRides = [self sortArray:_myRides];
//                 _ridesData = [self sortArray:_ridesData];
//                 _pickUpsData = [self sortArray:_pickUpsData];
                 
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
                 //NSLog(@"Delete Request success! with info: %@", response);
                 [_myRides removeObjectAtIndex:indexPath.row];
//                 //Sort arrays
//                 _myRides = [self sortArray:_myRides];
//                 _ridesData = [self sortArray:_ridesData];
//                 _pickUpsData = [self sortArray:_pickUpsData];
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

- (IBAction)allAction:(id)sender
{
    _allBtn.selected=YES;
    _allBtn.backgroundColor=[UIColor whiteColor];
    [_allBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    
    
    _ridesBtn.selected=NO;
    _ridesBtn.backgroundColor=[UIColor grayColor];
    [_ridesBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    
    _pickUpsBtn.selected=NO;
    _pickUpsBtn.backgroundColor=[UIColor grayColor];
    [_pickUpsBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [self roundCornerFor:_allBtn withRadius:CGSizeMake(15.0, 15.0) roundingCorners:(  UIRectCornerTopRight)];
    [self roundCornerFor:_ridesBtn withRadius:CGSizeMake(0.0, 0.0) roundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomRight | UIRectCornerBottomLeft)];
    [self roundCornerFor:_pickUpsBtn withRadius:CGSizeMake(0.0, 0.0) roundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomRight | UIRectCornerBottomLeft)];
    
    [_historyListview reloadData];
}

- (IBAction)ridesAction:(id)sender {
    
    
    _allBtn.selected=NO;
    _allBtn.backgroundColor=[UIColor grayColor];
    [_allBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    
    
    
    _ridesBtn.selected=YES;
    _ridesBtn.backgroundColor=[UIColor whiteColor];
    [_ridesBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    
    
    _pickUpsBtn.selected=NO;
    _pickUpsBtn.backgroundColor=[UIColor grayColor];
    [_pickUpsBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [self roundCornerFor:_allBtn withRadius:CGSizeMake(0.0, 0.0) roundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomRight | UIRectCornerBottomLeft)];
    [self roundCornerFor:_ridesBtn withRadius:CGSizeMake(15.0, 15.0) roundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight )];
    [self roundCornerFor:_pickUpsBtn withRadius:CGSizeMake(0.0, 0.0) roundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomRight | UIRectCornerBottomLeft)];
    [_historyListview reloadData];
}

- (IBAction)pickUpsAction:(id)sender {
    
    
    _allBtn.selected=NO;
    _allBtn.backgroundColor=[UIColor grayColor];
    [_allBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    
    _ridesBtn.selected=NO;
    _ridesBtn.backgroundColor=[UIColor grayColor];
    [_ridesBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    
    _pickUpsBtn.selected=YES;
    _pickUpsBtn.backgroundColor=[UIColor whiteColor];
    [_pickUpsBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    
    [self roundCornerFor:_allBtn withRadius:CGSizeMake(0.0, 0.0) roundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomRight | UIRectCornerBottomLeft)];
    [self roundCornerFor:_ridesBtn withRadius:CGSizeMake(0.0, 0.0) roundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomRight | UIRectCornerBottomLeft)];
    [self roundCornerFor:_pickUpsBtn withRadius:CGSizeMake(15.0, 15.0) roundingCorners:(UIRectCornerTopLeft )];
    [_historyListview reloadData];
}
@end
