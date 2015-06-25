//
//  PasswordViewController.m
//  AudioApp
//
//  Created by Alex Santorineos on 6/23/15.
//  Copyright (c) 2015 DavidSights. All rights reserved.
//

#import "PasswordViewController.h"
#import <Parse/Parse.h>

@interface PasswordViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *oldPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *nPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *repeatNewPasswordTextField;

@end

@implementation PasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.oldPasswordTextField.delegate = self;
    self.nPasswordTextField.delegate = self;
    self.repeatNewPasswordTextField.delegate = self;
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(leftButtonPressed:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveButtonPressed:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    self.navigationItem.rightBarButtonItem = saveButton;
}

- (void)leftButtonPressed:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void) saveButtonPressed:(id)sender {
    PFUser *currentUser = [PFUser currentUser];
    if ([self.oldPasswordTextField.text isEqualToString:currentUser.password]) {
        if ([self.nPasswordTextField.text isEqualToString:self.repeatNewPasswordTextField.text]) {
            currentUser.password = self.repeatNewPasswordTextField.text;
            [currentUser saveInBackground];
            NSLog(@"Successfully saved new password.");
            [self.navigationController popToRootViewControllerAnimated:YES];
        } else {
            NSLog(@"new passwords dont match");
        }
    } else {
        NSLog(@"not old password");
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.nPasswordTextField endEditing:YES];
    [self.oldPasswordTextField endEditing:YES];
    [self.repeatNewPasswordTextField endEditing:YES];

    return YES;
}

@end
