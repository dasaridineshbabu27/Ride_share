//
//  MenuViewController.m
//  SlideMenu
//
//  Created by Aryan Gh on 4/24/13.
//  Copyright (c) 2013 Aryan Ghassemi. All rights reserved.
//

#import "LeftMenuViewController.h"
#import "SlideNavigationContorllerAnimatorFade.h"
#import "SlideNavigationContorllerAnimatorSlide.h"
#import "SlideNavigationContorllerAnimatorScale.h"
#import "SlideNavigationContorllerAnimatorScaleAndFade.h"
#import "SlideNavigationContorllerAnimatorSlideAndFade.h"

@implementation LeftMenuViewController

#pragma mark - UIViewController Methods -

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self.slideOutAnimationEnabled = YES;
	
	return [super initWithCoder:aDecoder];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.tableView.separatorColor = [UIColor lightGrayColor];
	
	UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"leftMenu.jpg"]];
	self.tableView.backgroundView = imageView;
}

- (void)viewWillAppear:(BOOL)animated
{
    [_tableView reloadData];
}

#pragma mark - UITableView Delegate & Datasrouce -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 6;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 20)];
	view.backgroundColor = [UIColor clearColor];
	return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"leftMenuCell"];
	
	switch (indexPath.row)
	{
		case 0:
			cell.textLabel.text = @"HOME";
			break;
			
        case 1:
			cell.textLabel.text = @"MY ACCOUNT";
            break;
            
		case 2:
			cell.textLabel.text = @"HISTORY";
            break;
        case 3:
            cell.textLabel.text = @"REQUEST's";
            break;
		case 4:
			cell.textLabel.text = @"FAQs";
			break;
            
		case 5:
			cell.textLabel.text = @"LOGOUT";
			break;
	}
    
    [cell setNeedsLayout];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
															 bundle: nil];
	
	UIViewController *vc ;
	
	switch (indexPath.row)
	{
		case 0:
			vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"RSHomeViewController"];
			break;
			
		case 1:
			vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"MyProfileViewController"];
			break;
			
		case 2:
			vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"RSHistoryViewController"];
			break;
            
        case 3:
            vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"NotificationsView"];
            break;
            
        case 4:
            vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"RSFAQsViewController"];
            break;
            
		case 5:
			[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
            [[SlideNavigationController sharedInstance] popToRootViewControllerAnimated:YES];
            
            ////
            [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"isLoggedIn"];
            [[NSUserDefaults standardUserDefaults]synchronize];
//            vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"RLLoginViewController"];
//            [[SlideNavigationController sharedInstance] popAllAndSwitchToViewController:vc withCompletion:nil];
			
			return;
			break;
	}
	
	[[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc
															 withSlideOutAnimation:self.slideOutAnimationEnabled
																	 andCompletion:nil];
}

@end
