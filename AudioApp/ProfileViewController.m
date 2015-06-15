//
//  ProfileViewController.m
//  AudioApp
//
//  Created by Alex Santorineos on 6/15/15.
//  Copyright (c) 2015 DavidSights. All rights reserved.
//

#import "ProfileViewController.h"
#import <Parse/Parse.h>
@interface ProfileViewController ()

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

-(void)viewWillAppear:(BOOL)animated{

    PFUser *currentUser = [PFUser currentUser]; //show current user in console
    if (currentUser) {
        NSLog(@"Current user: %@", currentUser.username);
    }
    else {
        [self.tabBarController setSelectedIndex:0];
    }

}

@end
