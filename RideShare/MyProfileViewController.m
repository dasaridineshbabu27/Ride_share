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
#import "RSServices.h"

@interface MyProfileViewController ()

@end

@implementation MyProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.canDisplayBannerAds = YES;
    self.title = @"Account";
    [RSUtils addCornerRadius:self.btnPickImage];
    [self populateUI];
    ////Ads
    (appDelegate).googleAdIsVisible=NO;
    [self updateUserInterface:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateUserInterface:)
                                                 name:@"updateUserInterface" object:nil];
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
-(void)populateUI
{
    User *currentUser = [User currentUser];
    
    self.firstNameInput.text = currentUser.firstName;
    self.lastNameInput.text = currentUser.lastName;
    self.emailInput.text = currentUser.emailId;
    self.mobileNoInput.text = currentUser.mobileNo;
     self.regNoInput.text = currentUser.regNumber;
    self.passwordInput.text= currentUser.password;
    self.vehicleTypeInput.text = currentUser.vehicleType;
   
    [self.btnPickImage setBackgroundImage:currentUser.profilePic forState:UIControlStateNormal];
}
- (void)setUserInteraction:(BOOL)enable
{
    _firstNameInput.userInteractionEnabled = enable;
    _lastNameInput.userInteractionEnabled = enable;
    _emailInput.userInteractionEnabled = enable;
    _vehicleTypeInput.userInteractionEnabled = enable;
    _regNoInput.userInteractionEnabled = enable;
    _mobileNoInput.userInteractionEnabled = enable;
    _btnPickImage.userInteractionEnabled = enable;
}
- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
    return NO;
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
    //NSLog(@"%@", info);
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
- (IBAction)editButtonAction:(id)sender
{
    /////////////
    if ([_editBtn.title isEqualToString:@"EDIT"])
    {
        _editBtn.title = @"SAVE";
        [self setUserInteraction:YES];
    }
    ////////////
    else if ([_editBtn.title isEqualToString:@"SAVE"])
    {
            if ([RSUtils trimWhiteSpaces:_firstNameInput.text].length == 0 ||
                [RSUtils trimWhiteSpaces:_lastNameInput.text].length == 0 ||
                [RSUtils trimWhiteSpaces:_emailInput.text].length == 0 ||
                [RSUtils trimWhiteSpaces:_mobileNoInput.text].length == 0 ||
                [RSUtils trimWhiteSpaces:_regNoInput.text].length == 0 )
            {
                [RSUtils showAlertWithTitle:@"My Profile" message:@"Fields must not be empty." actionOne:nil actionTwo:nil inView:self];
                return;
            }
        
        //////New Code
        UIImage * beforeImg=[_btnPickImage backgroundImageForState:UIControlStateNormal];
        UIImage * afterImg =[self imageWithImage:beforeImg scaledToSize:CGSizeMake(100, 100)];
        
        NSData *beforeImgData = UIImagePNGRepresentation(beforeImg);
        NSData *afterImgData = UIImagePNGRepresentation(afterImg);
        
        long beforeimageSize   = beforeImgData.length;
        long afterimageSize   = afterImgData.length;
        NSLog(@"\n \n beforeImgSize===%f KB afterImgsize===%f KB",beforeimageSize/1024.0,afterimageSize/1024.0);
        
        [self setUserInteraction:NO];
        [_editBtn setTitle:@"EDIT"];
        User *currentUser = [User currentUser];
            NSDictionary *infoDict = @{ @"user_id" : currentUser.userId,
                                        @"fname" : _firstNameInput.text,
                                       @"lname" : _lastNameInput.text,
                                       @"gender" : currentUser.gender,
                                       @"email" : _emailInput.text,
                                       @"vehicle_type" : @"",
                                       @"reg_num" : _regNoInput.text,
                                       @"mobile" : _mobileNoInput.text,
                
                                      
                                       };
        ////////////////
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
                         NSDictionary *parameters = @{@"user_id": currentUser.userId};
                         [self updateProfileImageWith:parameters imageData:afterImgData];
                         
                         User *currentUser = [User currentUser];
                         [currentUser saveUserDetails:response];
                         

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

-(void)updateProfileImageWith:(NSDictionary*)info imageData:(NSData*)imgData
{
     //////////////////////////////
    /////Upload Profile image/////
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
                  User *currentUser = [User currentUser];
                   currentUser.profilePic= [_btnPickImage backgroundImageForState:UIControlStateNormal];;
                 [RSUtils showAlertWithTitle:@"My Profile" message:@"Your profile has been updated." actionOne:nil actionTwo:nil inView:self];
                 return;
             }
             else
             {
                 [RSUtils showAlertWithTitle:@"My Profile" message:[responseImage objectForKey:kResponseMessage] actionOne:nil actionTwo:nil inView:self];
                 return;

             }
             
         }
         if (alertMsgImage.length != 0)
         {
             [RSUtils showAlertWithTitle:@"My Profile" message:alertMsgImage actionOne:nil actionTwo:nil inView:self];
         }
         
     }];
    
}


@end
