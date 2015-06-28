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
    self.navigationItem.rightBarButtonItem = saveButton;
}

- (void)leftButtonPressed:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void) saveButtonPressed:(id)sender {
    PFUser *currentUser = [PFUser currentUser];

    NSString *oldPass=[self.oldPasswordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *newPass =[self.nPasswordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *repeatNewPass=[self.repeatNewPasswordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if ([oldPass isEqualToString:currentUser.password]) {
        if ([newPass isEqualToString:repeatNewPass]) {
            currentUser.password = repeatNewPass;
            [currentUser saveInBackground];
            NSLog(@"Successfully saved new password.");
            [self.navigationController popToRootViewControllerAnimated:YES];
        } else {
            NSLog(@"new passwords dont match");
        }
    } else {
        NSLog(@"not old password");
    }


    if (![self.nPasswordTextField.text isEqualToString:self.repeatNewPasswordTextField.text] && ![self.oldPasswordTextField.text isEqualToString:currentUser.password] ) {

        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Wrong" message:@"Your current password and new passwords don't match" delegate:nil cancelButtonTitle:@"cancel" otherButtonTitles:nil, nil];
        [alert show];
        
    }
   else if (![self.oldPasswordTextField.text isEqualToString:currentUser.password]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Wrong" message:@"Not your current password" delegate:nil cancelButtonTitle:@"cancel" otherButtonTitles:nil, nil];
        [alert show];
        
    }
    else if (![self.nPasswordTextField.text isEqualToString:self.repeatNewPasswordTextField.text]) {

        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Wrong" message:@"New passwords don't match" delegate:nil cancelButtonTitle:@"cancel" otherButtonTitles:nil, nil];
        [alert show];
        
    }

}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
NSInteger nextTag = textField.tag + 1;
// Try to find next responder
UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
if (nextResponder) {
    // Found next responder, so set it.
    [nextResponder becomeFirstResponder];
} else {
    // Not found, so remove keyboard.
    [textField resignFirstResponder];
}
    return NO;

}


@end
