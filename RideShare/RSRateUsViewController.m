//
//  RSRateUsViewController.m
//  RideShare
//
//  Created by Reddy on 07/01/16.
//  Copyright © 2016 Reddy. All rights reserved.
//

#import "RSRateUsViewController.h"
#import "UIViewController+AMSlideMenu.h"

@interface RSRateUsViewController ()

@end

@implementation RSRateUsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //self.canDisplayBannerAds = YES;
    self.title = @"Rate Us";
        UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(menuClicked)];
        leftButton.image = [UIImage imageNamed:@"Hamburger_menu"];
        self.navigationItem.leftBarButtonItem = leftButton;
    
    ////Ads
    (appDelegate).googleAdIsVisible=NO;
    [self updateUserInterface:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateUserInterface:)
                                                 name:@"updateUserInterface" object:nil];
    
    // Do any additional setup after loading the view.
}
-(void)integrateAds
{
    //iAds Implementation
    //[appDelegate iAdIntegration];
    //[appDelegate iAdIntegrationwith:<#(ADBannerView *)#> andviewController:self];
    
    
    //Google Ads Implementation
    //[appDelegate googleAdsIntegration];
    [appDelegate googleAdsIntegrationWith:self.googleAdBanner andviewController:self];
    
    //LARSAd Implementation
    //[[LARSAdController sharedManager] addAdContainerToView:self.view withParentViewController:self];
    //[[LARSAdController sharedManager] addAdContainerToViewInViewController:self];
    
}
-(void)updateUserInterface:(NSNotification *)notification
{
    if ((appDelegate).googleAdIsVisible)
    {
        _googleAdBanner.hidden=NO;
        _googleAdbottomConstraint.constant=0;
    }
    else
    {
        _googleAdBanner.hidden=YES;
        _googleAdbottomConstraint.constant=-50;
    }
    [self.view layoutIfNeeded];
}
-(void)viewWillAppear:(BOOL)animated
{
    [self integrateAds];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateUserInterface" object:nil];
}
- (void)menuClicked
{
    [[self mainSlideMenu] openLeftMenu];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
