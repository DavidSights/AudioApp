//
//  LoginViewController.m
//  AudioApp
//
//  Created by David Seitz Jr on 6/15/15.
//  Copyright (c) 2015 DavidSights. All rights reserved.
//

#import "LoginViewController.h"
#import <Parse/Parse.h>

@interface LoginViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet UIButton *loginToggleButton;
@property (weak, nonatomic) IBOutlet UIButton *signUpToggleButton;
@property (weak, nonatomic) IBOutlet UIButton *forgotPasswordButton;
@property BOOL loginToggled;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.passwordTextField.secureTextEntry = YES;
    self.usernameTextField.delegate = self;
    self.passwordTextField.delegate = self;
    self.emailTextField.delegate = self;
    self.loginToggleButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    self.signUpToggleButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;

    [self toggleSignUp];
}

- (void)toggleLogin {
    self.emailTextField.alpha = 0;
    self.signUpButton.alpha = 0;
    self.loginToggleButton.alpha = 0;
    self.signUpToggleButton.alpha = 1;
    self.loginButton.alpha = 1;
    self.forgotPasswordButton.alpha = 1;
    self.loginToggled = YES;
}

- (void)toggleSignUp {
    self.emailTextField.alpha = 1;
    self.signUpButton.alpha = 1;
    self.loginToggleButton.alpha = 1;
    self.signUpToggleButton.alpha = 0;
    self.loginButton.alpha = 0;
    self.forgotPasswordButton.alpha = 0;
    self.loginToggled = NO;
}

- (IBAction)signUpTogglePressed:(id)sender {
    [self toggleSignUp];
}

- (IBAction)loginTogglePressed:(id)sender {
    [self toggleLogin];
}

- (IBAction)forgotPasswordButtonPressed:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Reset Password" message:@"Enter email" preferredStyle:UIAlertControllerStyleAlert];

    //adding text field to alert controller
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Enter email"; //adds the placeholder text in the field
    }];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]; //cancels alert controller

    //saves what you wrote
    UIAlertAction *resetAction =  [UIAlertAction actionWithTitle:@"Reset" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

        UITextField *emailTextField = alertController.textFields[0];
        [PFUser requestPasswordResetForEmailInBackground:emailTextField.text];
    }];

    //add cancelAction variable to alertController
    [alertController addAction:cancelAction];
    [alertController addAction:resetAction];

    //activates alertcontroler
    [self presentViewController:alertController animated:true completion:nil];
}

- (IBAction)signUpButton:(id)sender {
    NSString *username=[self.usernameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password =[self.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *email=[self.emailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if ([username length]==0 || [password length]==0 ||[email length]==0) {
        UIAlertView *alertview = [[UIAlertView alloc]initWithTitle:@"Something's wrong..." message:@"Did you forget to enter your username, password, or email?" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alertview show];
    } else {
        PFUser *newUser = [PFUser user];
        newUser.username=username;
        newUser.password=password;
        newUser.email=email;
        [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                [alertView show];
            } else {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }];
    }
}

- (IBAction)loginButton:(id)sender {
    NSString *username = [self.usernameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = [self.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if ([username length]==0 || [password length]==0 ) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Something's wrong..." message:@"Did you forget to enter your username or password?" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];

        [alertView show];
    } else {
        [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error) {
            if (user) {
                [self dismissViewControllerAnimated:YES completion:nil];
            } else {
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                [alertView show];
            }
        }];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

//– (void)giveCakeToUser:(PFUser *)user {
//       PFUser *currentUser = [PFUser currentUser]; //show current user in console
//
//    if (![[user objectForKey:@”emailVerified”] boolValue]) {
//        // Refresh to make sure the user did not recently verify
//        [user refresh];
//        if (![[user objectForKey:@”emailVerified”] boolValue]) {
//            [self redirectWithMessage:@”You must verify your email address for cake”];
//            return;
//        }
//    }
//    // This is a triumph.
//    [self warnUserAboutCakeAvailability];
//}

@end
