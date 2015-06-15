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

@property (weak, nonatomic) IBOutlet UILabel *displayNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *aboutLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *postsLikesController;
@property (weak, nonatomic) IBOutlet UITableView *tableview;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewDidAppear:(BOOL)animated {
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser != nil) {
        self.usernameLabel.text = currentUser.username;
        self.displayNameLabel.text = currentUser[@"displayName"];
        self.aboutLabel.text = currentUser[@"about"];
    } else {
        [self.tabBarController setSelectedIndex:0];
    }
}

@end
