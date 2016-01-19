//
//  RLRegistrationViewController.m
//  RideShare
//
//  Created by Reddy on 05/01/16.
//  Copyright © 2016 Reddy. All rights reserved.
//

#import "RLRegistrationViewController.h"
#import "RSServices.h"

@implementation RLRegistrationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _btnMale.selected = YES;
    _btnPickImage.layer.cornerRadius = self.btnPickImage.frame.size.height;
    _btnPickImage.layer.borderColor = [UIColor blackColor].CGColor;
    _btnPickImage.layer.borderWidth = 1.0;
    _btnPickImage.layer.masksToBounds = YES;
    NSLog(@"%@", [RSUtils trimWhiteSpaces:@"  abc   123  "]);
    self.navigationController.navigationBarHidden = NO;
    // Do any additional setup after loading the view.
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

- (IBAction)registerAction:(id)sender
{
    if ([RSUtils trimWhiteSpaces:_firstNameInput.text].length == 0 ||
        [RSUtils trimWhiteSpaces:_lastNameInput.text].length == 0 ||
        [RSUtils trimWhiteSpaces:_emailInput.text].length == 0 ||
        [RSUtils trimWhiteSpaces:_confirmEmailInput.text].length == 0 ||
        [RSUtils trimWhiteSpaces:_passwordInput.text].length == 0 ||
        [RSUtils trimWhiteSpaces:_confirmPasswordInput.text].length == 0 ||
        [RSUtils trimWhiteSpaces:_vehicleTypeInput.text].length == 0 ||
        [RSUtils trimWhiteSpaces:_vehicleTypeInput.text].length == 0 )
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Registration" message:@"Please fill all fields." preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
        }];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    
    NSString *gender = (_btnMale.selected)?@"1" : @"2";
    NSDictionary *infoDict = @{@"fname" : _firstNameInput.text,
                               @"lname" : _lastNameInput.text,
                               @"password" : _passwordInput.text,
                               @"gender" : gender,
                               @"email" : _emailInput.text,
                               @"vehicle_type" : _vehicleTypeInput.text,
                               @"reg_num" : _regNoInput.text,
                               @"mobile" : _mobileNoInput.text
                               };
    
    [RSServices processRegistration:infoDict completionHandler:^(NSData * response, NSError * error)
    {
        NSString *alertMsg = nil;
        if (error != nil)
        {
            alertMsg = @"Registration Failed, Please try again later.";
        }
        else
        {
            alertMsg = @"Registration Success, Please login.";
        }
        
        NSLog(@"Registration success with data: %@", response);
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Registration" message:alertMsg preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                   {
                                       [self dismissViewControllerAnimated:YES completion:nil];
                                   }];
        [alertController addAction:okAction];
        [self.navigationController popViewControllerAnimated:YES];        
    }];
    return;
}

- (IBAction)genderToggleAction:(UIButton*)sender
{
    if (sender == _btnMale)
    {
        _btnMale.selected = YES;
        _btnFemale.selected = NO;
    }
    else
    {
        _btnMale.selected = NO;
        _btnFemale.selected = YES;
    }
}

- (IBAction)cancelRegistration:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [_passwordInput resignFirstResponder];
    [_emailInput resignFirstResponder];
    [_firstNameInput resignFirstResponder];
    [_lastNameInput resignFirstResponder];
    [_confirmEmailInput resignFirstResponder];
    [_confirmPasswordInput resignFirstResponder];
}

@end
