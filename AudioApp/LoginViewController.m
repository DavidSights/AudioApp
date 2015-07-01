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
@property UIColor *blue, *yellow, *red, *purple, *green, *darkBlue, *darkYellow, *darkRed, *darkPurple, *darkGreen, *pink, *deepBlue;
@property BOOL loginToggled;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];


    // App color theme.
    self.blue = [UIColor colorWithRed:160/255.0 green:215/255.0 blue:231/255.0 alpha:1.0];
    self.yellow = [UIColor colorWithRed:251/255.0 green:247/255.0 blue:199/255.0 alpha:1.0];
    self.red = [UIColor colorWithRed:205/255.0 green:124/255.0 blue:135/255.0 alpha:1.0];
    self.purple = [UIColor colorWithRed:176/255.0 green:150/255.0 blue:193/255.0 alpha:1.0];
    self.green = [UIColor colorWithRed:177/255.0 green:215/255.0 blue:165/255.0 alpha:1.0];
    self.darkBlue = [UIColor colorWithRed:83/255.0 green:153/255.0 blue:174/255.0 alpha:1.0];
    self.darkYellow = [UIColor colorWithRed:204/255.0 green:164/255.0 blue:42/255.0 alpha:1.0];
    self.darkRed = [UIColor colorWithRed:166/255.0 green:81/255.0 blue:92/255.0 alpha:1.0];
    self.darkPurple = [UIColor colorWithRed:121/255.0 green:192/255.0 blue:140/255.0 alpha:1.0];
    self.darkGreen = [UIColor colorWithRed:75/255.0 green:151/255.0 blue:142/255.0 alpha:1.0];
    self.pink = [UIColor colorWithRed:255/255.0 green:187/255.0 blue:208/255.0 alpha:1.0];
    self.deepBlue = [UIColor colorWithRed:21/255.0 green:42/255.0 blue:59/255.0 alpha:1.0];


    self.passwordTextField.secureTextEntry = YES;
    self.usernameTextField.delegate = self;
    self.passwordTextField.delegate = self;
    self.emailTextField.delegate = self;
    self.loginToggleButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    self.signUpToggleButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;

    NSArray *textfields = [NSArray arrayWithObjects:self.usernameTextField, self.passwordTextField, self.emailTextField, nil];
    for (UITextField *textField in textfields) {
        if ([textField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
            UIColor *color = [UIColor colorWithRed:124/255.0 green:165/255.0 blue:206/255.0 alpha:1.0];
            textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:textField.placeholder attributes:@{NSForegroundColorAttributeName: color}];
        } else {
            NSLog(@"Cannot set placeholder text's color, because deployment target is earlier than iOS 6.0");
            // TODO: Add fall-back code to set placeholder color.
        }
    }

    [self toggleSignUp];
}

-(void)viewDidAppear:(BOOL)animated {
    // Format button style
    self.loginButton.backgroundColor = self.yellow;
    self.signUpButton.backgroundColor = self.yellow;
    self.loginButton.layer.cornerRadius = self.loginButton.frame.size.width/25;
    self.signUpButton.layer.cornerRadius = self.signUpButton.frame.size.width/25;
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
    [self dismissKeyboard];
}

- (IBAction)loginTogglePressed:(id)sender {
    [self toggleLogin];
    [self dismissKeyboard];
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

- (void) dismissKeyboard {
    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self.emailTextField resignFirstResponder];
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
