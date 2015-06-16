//
//  OptionsViewController.m
//  AudioApp
//
//  Created by David Seitz Jr on 6/15/15.
//  Copyright (c) 2015 DavidSights. All rights reserved.
//

#import "OptionsViewController.h"
#import <Parse/Parse.h>

@interface OptionsViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *displayNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailAddressTextField;
@property (weak, nonatomic) IBOutlet UITextField *aboutTextField;
@property (weak, nonatomic) IBOutlet UITextField *currentPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *myNewPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmNewPasswordTextField;
@property PFUser *user;

@end

@implementation OptionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentPasswordTextField.secureTextEntry = YES;
    self.myNewPasswordTextField.secureTextEntry = YES;
    self.confirmNewPasswordTextField.secureTextEntry = YES;

    self.user = [PFUser currentUser];
    self.displayNameTextField.text = _user[@"displayName"];
    self.aboutTextField.text = _user[@"about"];
    self.usernameTextField.text = _user.username;
    self.emailAddressTextField.text = _user.email;
}

- (IBAction)saveChangesButtonPressed:(id)sender {
    self.user.username = self.usernameTextField.text;
    self.user.email = self.emailAddressTextField.text;
    self.user[@"about"] = self.aboutTextField.text;
    self.user[@"displayName"] = self.displayNameTextField.text;
    [self.user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        if (succeeded) {
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Account changes not saved. Please try again later." preferredStyle:UIAlertControllerStyleAlert];

            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
}

- (IBAction)logoutButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    [PFUser logOut];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self dismissKeyBoard];
    return YES;
}

- (void) dismissKeyBoard {
    [self.displayNameTextField resignFirstResponder];
    [self.usernameTextField resignFirstResponder];
    [self.emailAddressTextField resignFirstResponder];
    [self.aboutTextField resignFirstResponder];
    [self.currentPasswordTextField resignFirstResponder];
    [self.myNewPasswordTextField resignFirstResponder];
    [self.confirmNewPasswordTextField resignFirstResponder];
}

- (IBAction)cancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
