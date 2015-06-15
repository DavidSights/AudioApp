//
//  OptionsViewController.m
//  AudioApp
//
//  Created by David Seitz Jr on 6/15/15.
//  Copyright (c) 2015 DavidSights. All rights reserved.
//

#import "OptionsViewController.h"
#import <Parse/Parse.h>

@interface OptionsViewController ()

@end

@implementation OptionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)logoutButtonPressed:(id)sender {

    [self dismissViewControllerAnimated:YES completion:nil];

    [PFUser logOut];
//logout of account


}

@end
