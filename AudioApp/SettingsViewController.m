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
@interface SettingsViewController ()<UITextFieldDelegate, UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *displaynameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextView *aboutTextView;
@property PFUser *user;
@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(bBPressed:)];
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



- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {

    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }

    return YES;
}

@end
