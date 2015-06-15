//
//  LoginViewController.m
//  AudioApp
//
//  Created by David Seitz Jr on 6/15/15.
//  Copyright (c) 2015 DavidSights. All rights reserved.
//

#import "LoginViewController.h"
#import <Parse/Parse.h>
@interface LoginViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet UIButton *loginToggleButton;
@property (weak, nonatomic) IBOutlet UIButton *signUpToggleButton;
@property (weak, nonatomic) IBOutlet UIButton *forgotPasswordButton;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.usernameTextField.delegate = self;
    self.passwordTextField.delegate = self;
    self.emailTextField.delegate = self;
    // Align toggle buttons to right justification.
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
}

- (void)toggleSignUp {
    self.emailTextField.alpha = 1;
    self.signUpButton.alpha = 1;
    self.loginToggleButton.alpha = 1;
    self.signUpToggleButton.alpha = 0;
    self.loginButton.alpha = 0;
    self.forgotPasswordButton.alpha = 0;
}
- (IBAction)signUpTogglePressed:(id)sender {
    [self toggleSignUp];
}

- (IBAction)loginTogglePressed:(id)sender {
    [self toggleLogin];
}

- (IBAction)forgotPasswordButtonPressed:(id)sender {
}
- (IBAction)signUpButton:(id)sender {

    NSString *username=[self.usernameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password =[self.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *email=[self.emailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];


    if ([username length]==0 || [password length]==0 ||[email length]==0) {
        UIAlertView *alertview = [[UIAlertView alloc]initWithTitle:@"oops" message:@"enter Username, password, and email adress" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];


        [alertview show];
    }


    else{

        PFUser *newUser = [PFUser user];
        newUser.username=username;
        newUser.password=password;
        newUser.email=email;

        [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"sorry" message:[error.userInfo objectForKey:@"error"] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
                [alertView show];

            }

            else{
                [self dismissViewControllerAnimated:YES completion:nil];

            }
        }];


    }
    
    

}
- (IBAction)loginButton:(id)sender {

    NSString *username = [self.usernameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    NSString *password = [self.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];



    if ([username length]==0 || [password length]==0 ) {

        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Seriously?😡" message:@"enter Username and password" delegate:nil cancelButtonTitle:@"cancel" otherButtonTitles:nil];

        [alertView show];

    }else{
        [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error) {

            if (user) {

                NSLog(@"%@",user.username);



                [self dismissViewControllerAnimated:YES completion:nil];


            } else {

                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"sorry" message:[error.userInfo objectForKey:@"error"] delegate:nil cancelButtonTitle:@"cancel" otherButtonTitles:nil];
                [alertView show];
                
                // The login failed. Check error to see why.
            }
        }];
        
    }

}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{


    [textField resignFirstResponder];
    return YES;

}


@end
