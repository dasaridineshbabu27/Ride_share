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
    self.title = @"Rate Us";
        UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(menuClicked)];
        leftButton.image = [UIImage imageNamed:@"Hamburger_menu"];
        self.navigationItem.leftBarButtonItem = leftButton;
    // Do any additional setup after loading the view.
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
