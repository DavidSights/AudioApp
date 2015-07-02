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

    if ([self.nPasswordTextField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [UIColor colorWithRed:124/255.0 green:165/255.0 blue:206/255.0 alpha:1.0];
        self.nPasswordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.nPasswordTextField.placeholder attributes:@{NSForegroundColorAttributeName: color}];
    } else {
        NSLog(@"Cannot set placeholder text's color, because deployment target is earlier than iOS 6.0");
        // TODO: Add fall-back code to set placeholder color.
    }

    if ([self.repeatNewPasswordTextField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [UIColor colorWithRed:124/255.0 green:165/255.0 blue:206/255.0 alpha:1.0];
        self.repeatNewPasswordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.repeatNewPasswordTextField.placeholder attributes:@{NSForegroundColorAttributeName: color}];
    } else {
        NSLog(@"Cannot set placeholder text's color, because deployment target is earlier than iOS 6.0");
        // TODO: Add fall-back code to set placeholder color.
    }
}

- (void)leftButtonPressed:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void) saveButtonPressed:(id)sender {
    PFUser *currentUser = [PFUser currentUser];

    NSString *newPass =[self.nPasswordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *repeatNewPass=[self.repeatNewPasswordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

        if ([newPass isEqualToString:repeatNewPass]) {
            currentUser.password = repeatNewPass;
            [currentUser saveInBackground];
            NSLog(@"Successfully saved new password.");
            [self.navigationController popToRootViewControllerAnimated:YES];
        } else {
            NSLog(@"new passwords dont match");
        }


    if (![self.nPasswordTextField.text isEqualToString:self.repeatNewPasswordTextField.text]) {

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
