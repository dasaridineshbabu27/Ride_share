//
//  RLRegistrationViewController.m
//  RideShare
//
//  Created by Reddy on 05/01/16.
//  Copyright © 2016 Reddy. All rights reserved.
//

#import "RLRegistrationViewController.h"
#import "RSServices.h"
#import "AppDelegate.h"

@implementation RLRegistrationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _btnMale.selected = YES;
    
    /////////Old Code
//    _btnPickImage.layer.cornerRadius = self.btnPickImage.frame.size.height;
//    _btnPickImage.layer.borderColor = [UIColor blackColor].CGColor;
//    _btnPickImage.layer.borderWidth = 1.0;
//    _btnPickImage.layer.masksToBounds = YES;
    
    //////New
    [_btnPickImage setBackgroundImage:[UIImage imageNamed:@"ProfilePic"] forState:UIControlStateNormal];
    [RSUtils addCornerRadius:self.btnPickImage];
  
    
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
    //NSLog(@"%@", info);
    [_btnPickImage setBackgroundImage:[info valueForKey:@"UIImagePickerControllerOriginalImage"] forState:UIControlStateNormal];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

////Resize image
- (UIImage*)imageWithImage:(UIImage*)image
              scaledToSize:(CGSize)newSize;
{
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}
- (IBAction)registerAction:(id)sender
{


    /////////////
    
    if ([RSUtils trimWhiteSpaces:_firstNameInput.text].length == 0 ||
        [RSUtils trimWhiteSpaces:_lastNameInput.text].length == 0 ||
        [RSUtils trimWhiteSpaces:_emailInput.text].length == 0 ||
        [RSUtils trimWhiteSpaces:_confirmEmailInput.text].length == 0 ||
        [RSUtils trimWhiteSpaces:_passwordInput.text].length == 0 ||
        [RSUtils trimWhiteSpaces:_confirmPasswordInput.text].length == 0)
    {
        [RSUtils showAlertWithTitle:@"Registration" message:@"Fields must not be empty." actionOne:nil actionTwo:nil inView:self];
        return;
    }
    
    
    //////Old Code
    //NSData *imageData = UIImagePNGRepresentation([_btnPickImage backgroundImageForState:UIControlStateNormal]);
    
    //////New Code
    UIImage * beforeImg=[_btnPickImage backgroundImageForState:UIControlStateNormal];
    UIImage * afterImg =[self imageWithImage:beforeImg scaledToSize:CGSizeMake(100, 100)];
    
    NSData *beforeImgData = UIImagePNGRepresentation(beforeImg);
    NSData *afterImgData = UIImagePNGRepresentation(afterImg);
    
    long beforeimageSize   = beforeImgData.length;
    long afterimageSize   = afterImgData.length;
    //NSLog(@"\n \n beforeImgSize===%f KB afterImgsize===%f KB",beforeimageSize/1024.0,afterimageSize/1024.0);

    
     NSString *deviceToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"device_token"];
    NSString *gender = (_btnMale.selected)?@"1" : @"2";
    
    NSDictionary *infoDict;
    if (deviceToken != nil)
    {
        infoDict  =@{@"fname" : _firstNameInput.text,
                     @"lname" : _lastNameInput.text,
                     @"password" : _passwordInput.text,
                     @"gender" : gender,
                     @"email" : _emailInput.text,
                     @"vehicle_type" : @"",
                     @"reg_num" : _regNoInput.text,
                     @"mobile" : _mobileNoInput.text,
                     @"device_id":deviceToken
                     };

        
    }
    else
    {
        infoDict  = @{@"fname" : _firstNameInput.text,
                      @"lname" : _lastNameInput.text,
                      @"password" : _passwordInput.text,
                      @"gender" : gender,
                      @"email" : _emailInput.text,
                      @"vehicle_type" : @"",
                      @"reg_num" : _regNoInput.text,
                      @"mobile" : _mobileNoInput.text
                      };

        
    }

//    NSDictionary *infoDict = @{@"fname" : _firstNameInput.text,
//                               @"lname" : _lastNameInput.text,
//                               @"password" : _passwordInput.text,
//                               @"gender" : gender,
//                               @"email" : _emailInput.text,
//                               @"vehicle_type" : @"",
//                               @"reg_num" : _regNoInput.text,
//                               @"mobile" : _mobileNoInput.text
//
//                               };
    [appDelegate showLoaingWithTitle:nil];
    
    [RSServices processRegistration:infoDict completionHandler:^(NSDictionary* response, NSError * error)
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
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    // call the same method on a background thread
                    NSDictionary *parameters = @{@"user_id": [response objectForKey:@"user_id"]};
                    [self updateProfileImageWith:parameters imageData:afterImgData];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // update UI on the main thread
                    });
                    
                });

                
//               NSDictionary *parameters = @{@"user_id": [response objectForKey:@"user_id"]};
//                [self updateProfileImageWith:parameters imageData:afterImgData];
                
//                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Registration" message:@"Registered successfully, verification mail has been sent to your email, please verify to confinue services." preferredStyle:UIAlertControllerStyleAlert];
//                
//                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
//                {
//                    [self.navigationController popViewControllerAnimated:YES];
//                }];
//                
//                [alertController addAction:okAction];
//                [self presentViewController:alertController animated:YES completion:nil];
//                return ;
            }
            else
            {
                [RSUtils showAlertWithTitle:@"Registration" message:[response objectForKey:kResponseMessage] actionOne:nil actionTwo:nil inView:self];
                return;
            }
        }
        if (alertMsg.length != 0)
        {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Registration" message:alertMsg preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }];
}


-(void)updateProfileImageWith:(NSDictionary*)info imageData:(NSData*)imgData
{
    ///////////////////////////////////////////////////////////////////////////////////
    /////Upload Profile image/////////////////////////////////////////////////////////
     [appDelegate showLoaingWithTitle:nil];
    [RSServices uploadProfileImageWithUserID:info imageData:imgData completionHandler:^(NSDictionary* responseImage, NSError * errorImage)
     {
         [appDelegate hideLoading];
         NSString *alertMsgImage = nil;
         if (errorImage != nil)
         {
             alertMsgImage = errorImage.description;
         }
         else if (responseImage != nil)
         {
             if ([[responseImage objectForKey:kResponseCode] intValue] == kRequestSuccess)
             {
                 
//                 UIAlertController *alertControllerImage = [UIAlertController alertControllerWithTitle:@"Profile Image" message:@"Profile Image updated successfully" preferredStyle:UIAlertControllerStyleAlert];
//                 [self presentViewController:alertControllerImage animated:YES completion:nil];
                 
                 UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Registration" message:@"Registered successfully, verification mail has been sent to your email, please verify to confinue services." preferredStyle:UIAlertControllerStyleAlert];
                 
                 UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                            {
                                                [self.navigationController popViewControllerAnimated:YES];
                                            }];
                 
                 [alertController addAction:okAction];
                 [self presentViewController:alertController animated:YES completion:nil];
                 return ;

                
             }
             else
             {
                 [RSUtils showAlertWithTitle:@"Profile Image" message:[responseImage objectForKey:kResponseMessage] actionOne:nil actionTwo:nil inView:self];
                 //return;
             }
             
         }
         if (alertMsgImage.length != 0)
         {
             UIAlertController *alertControllerImage = [UIAlertController alertControllerWithTitle:@"Profile Image" message:alertMsgImage preferredStyle:UIAlertControllerStyleAlert];
             [self presentViewController:alertControllerImage animated:YES completion:nil];
         }
         
     }];
    
    ////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////

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
    [_firstNameInput resignFirstResponder];
    [_lastNameInput resignFirstResponder];
   
    [_emailInput resignFirstResponder];
    [_confirmEmailInput resignFirstResponder];
    
     [_passwordInput resignFirstResponder];
    [_confirmPasswordInput resignFirstResponder];
    
    [_mobileNoInput resignFirstResponder];
    [_regNoInput resignFirstResponder];
}


- (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(nonnull NSString *)string
{
    if (string.length == 0)
    {
        return YES;
    }
    
    if (textField == _mobileNoInput && textField.text.length >= 10)
    {
        return NO;
    }
    if ((textField == _passwordInput || textField == _confirmPasswordInput) && textField.text.length >= 8)
    {
        return NO;
    }
    
    return YES;
}
@end
