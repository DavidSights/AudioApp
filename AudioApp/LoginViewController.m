//
//  LoginViewController.m
//  AudioApp
//
//  Created by David Seitz Jr on 6/15/15.
//  Copyright (c) 2015 DavidSights. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()
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
@end
