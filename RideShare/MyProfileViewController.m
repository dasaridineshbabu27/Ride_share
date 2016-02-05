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
#import "RSUtils.h"
#import "RSConstants.h"
#import "AppDelegate.h"
#import "RSServices.h"

@interface MyProfileViewController ()

@end

@implementation MyProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Account";
//    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(menuClicked)];
//    leftButton.image = [UIImage imageNamed:@"Hamburger_menu"];
//    self.navigationItem.leftBarButtonItem = leftButton;
    // Do any additional setup after loading the view.
    [self populateUI];
}

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
    return NO;
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

-(BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(nonnull NSString *)string
{
    if ([string isEqualToString:@""])
    {
        return YES;
    }
    if (textField == _mobileNoInput && textField.text.length == 10)
    {
        return NO;
    }
    return YES;
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

- (IBAction)editButtonAction:(id)sender
{
    if ([_editBtn.title isEqualToString:@"EDIT"])
    {
        _editBtn.title = @"SAVE";
        [self setUserInteraction:YES];
    }
    else if ([_editBtn.title isEqualToString:@"SAVE"])
    {
            if ([RSUtils trimWhiteSpaces:_firstNameInput.text].length == 0 ||
                [RSUtils trimWhiteSpaces:_lastNameInput.text].length == 0 ||
                [RSUtils trimWhiteSpaces:_emailInput.text].length == 0 ||
                [RSUtils trimWhiteSpaces:_vehicleTypeInput.text].length == 0 ||
                [RSUtils trimWhiteSpaces:_regNoInput.text].length == 0 )
            {
                [RSUtils showAlertWithTitle:@"My Profile" message:@"Fields must not be empty." actionOne:nil actionTwo:nil inView:self];
                return;
            }
        [self setUserInteraction:NO];
        [_editBtn setTitle:@"EDIT"];
        User *currentUser = [User currentUser];
            NSDictionary *infoDict = @{@"fname" : _firstNameInput.text,
                                       @"lname" : _lastNameInput.text,
                                       @"gender" : currentUser.gender,
                                       @"email" : _emailInput.text,
                                       @"vehicle_type" : _vehicleTypeInput.text,
                                       @"reg_num" : _regNoInput.text,
                                       @"mobile" : _mobileNoInput.text,
                                       @"user_id" : currentUser.userId
                                       };
        
        [appDelegate showLoaingWithTitle:@"Loading..."];
        [RSServices processUpdateProfile:infoDict completionHandler:^(NSDictionary* response, NSError * error)
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
                         [self.navigationController popViewControllerAnimated:YES];
                         [RSUtils showAlertWithTitle:@"My Profile" message:@"Your profile has been updated." actionOne:nil actionTwo:nil inView:self];
                         [_editBtn setTitle:@"EDIT"];
                         return ;
                     }
                     else
                     {
                         [RSUtils showAlertWithTitle:@"My Profile" message:[response objectForKey:kResponseMessage] actionOne:nil actionTwo:nil inView:self];
                         return;
                     }
                 }
                 if (alertMsg.length != 0)
                 {
                     [RSUtils showAlertWithTitle:@"My Profile" message:alertMsg actionOne:nil actionTwo:nil inView:self];
                 }
             }];
    }
}

- (void)setUserInteraction:(BOOL)enable
{
    _firstNameInput.userInteractionEnabled = enable;
    _lastNameInput.userInteractionEnabled = enable;
    _emailInput.userInteractionEnabled = enable;
    _vehicleTypeInput.userInteractionEnabled = enable;
    _regNoInput.userInteractionEnabled = enable;
    _mobileNoInput.userInteractionEnabled = enable;
}

@end
