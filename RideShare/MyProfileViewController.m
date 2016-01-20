//
//  MyProfileViewController.m
//  RideShare
//
//  Created by Reddy on 07/01/16.
//  Copyright © 2016 Reddy. All rights reserved.
//

#import "MyProfileViewController.h"
#import "UIViewController+AMSlideMenu.h"
#import "User.h"

@interface MyProfileViewController ()

@end

@implementation MyProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Account";
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(menuClicked)];
    leftButton.image = [UIImage imageNamed:@"Hamburger_menu"];
    self.navigationItem.leftBarButtonItem = leftButton;
    // Do any additional setup after loading the view.
}

-(void)populateUI
{
    User *currentUser = [User currentUser];
    
    self.firstNameInput.text = currentUser.firstName;
    self.lastNameInput.text = currentUser.lastName;
    self.emailInput.text = currentUser.emailId;
    self.mobileNoInput.text = currentUser.mobileNo;
    self.vehicleTypeInput.text = currentUser.vehicleType;
    self.regNoInput.text = currentUser.regNumber;
}


- (IBAction)pickProfileImageAction:(id)sender
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Choose Source" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:imagePicker animated:YES completion:nil];
        }];
        [alertController addAction:cameraAction];
    }
    
    UIAlertAction *libraryAction = [UIAlertAction actionWithTitle:@"Photo Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }];
    [alertController addAction:libraryAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertController addAction:cancelAction];
    
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    NSLog(@"%@", info);
    [_btnPickImage setBackgroundImage:[info valueForKey:@"UIImagePickerControllerOriginalImage"] forState:UIControlStateNormal];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
