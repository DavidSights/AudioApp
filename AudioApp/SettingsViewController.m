//
//  SettingsViewController.m
//  AudioApp
//
//  Created by Alex Santorineos on 6/19/15.
//  Copyright (c) 2015 DavidSights. All rights reserved.
//

#import "SettingsViewController.h"
#import "ProfileViewController.h"
#import <Parse/Parse.h>
@interface SettingsViewController ()<UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *displaynameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextView *aboutTextView;
@property PFUser *user;
@property UIImage *image;
@property (nonatomic,strong) UIImagePickerController *imagePicker;
@property NSMutableArray *images;
@property UIImage *nImage;
@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(bBPressed:)];
    self.navigationItem.rightBarButtonItem = saveButton;
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButton:)];
    self.navigationItem.leftBarButtonItem = cancelButton;

    self.emailTextField.delegate = self;
    self.username.delegate = self;
    self.displaynameTextField.delegate = self;
    self.aboutTextView.delegate = self;

    self.user = [PFUser currentUser];
    self.username.text = _user[@"username"];
    self.emailTextField.text = _user.email;
    self.aboutTextView.text = [self.user objectForKey:@"about"];
    self.displaynameTextField.text = self.user[@"displayName"];
}
- (IBAction)logOut:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    [PFUser logOut];
}
-(void)cancelButton:(id)segue{
    [self dismissViewControllerAnimated:YES completion:nil];

}
-(void)bBPressed:(id)segue{
    [[PFUser currentUser] setUsername:self.username.text];
    [[PFUser currentUser]setEmail:self.emailTextField.text];
    [[PFUser currentUser]setValue:self.displaynameTextField.text forKey:@"displayName"];
    [[PFUser currentUser]setValue:self.aboutTextView.text forKey:@"about"];
    //    [[PFUser currentUser] saveEventually];
    //    [[PFUser currentUser] save];
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error saving info."
                                                                message:[NSString stringWithFormat:@"Error: %@", error.localizedDescription]
                                                               delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];

            NSLog(@"%@----------------------------",error.localizedDescription);
            [alertView show];
        }
        else {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"Test2" object:self];

            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}



-(BOOL)textFieldShouldReturn:(UITextField *)textField {

[self.emailTextField endEditing:YES];
 [self.displaynameTextField endEditing:YES];
 [self.aboutTextView endEditing:YES];
 [self.username endEditing:YES];

 return YES;
}

- (IBAction)onEditPicButtonTapped:(id)sender {


    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Add Profile Picture" message:@"Do you want to take a picture or upload a picture?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Upload", @"Take Picture", nil];

    [alert show];
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

    if (buttonIndex == 1) {
        NSLog(@"Upload tapped");

        [self uploadFromPhotoAlbum];
    } else if (buttonIndex == 2) {

        [self uploadFromCamera];
    }
    
}



-(void)uploadFromPhotoAlbum {

    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;

    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

    [self presentViewController:imagePicker animated:YES completion:nil];

}

-(void)uploadFromCamera {

    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;

    imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;

    [self presentViewController:imagePicker animated:YES completion:nil];
    
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

    self.image = [info objectForKey:UIImagePickerControllerOriginalImage];

    [self uploadToParse];

    [self dismissViewControllerAnimated:YES completion:nil];

}
+ (UIImage*)imageWithImage:(UIImage*)image
              scaledToSize:(CGSize)newSize;
{
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return newImage;
}

- (void)uploadToParse {
    NSData *fileData;
    NSString *fileName;

    if (self.image != nil) {
//                       UIImage *newImage =self.image;

//        self.nImage = [SettingsViewController imageWithImage:self.image scaledToSize:CGSizeMake(15, 15)];
        fileData = UIImageJPEGRepresentation(self.image, 0.5);
        fileName = @"profileImage.jpg";
    }

    PFFile *file = [PFFile fileWithName:fileName data:fileData];
    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"An error occurred!"
                                                                message:@"Please try again."
                                                               delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
        else {
            PFUser *user = [PFUser currentUser];

            [user setObject:file forKey:@"profileImage"];

            [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"An error occurred!"
                                                                        message:@"Please try again."
                                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alertView show];
                }
                else {
                    // Everything was successful!
                    [self reset];
                }
            }];
        }


        [[NSNotificationCenter defaultCenter]postNotificationName:@"TestProfilePic" object:self];

    }];
}

- (void)reset {
    self.imagePicker = nil;

}



- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {

    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }

    return YES;
}

@end
