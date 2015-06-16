//
//  ViewController.m
//  AudioApp
//
//  Created by David Seitz Jr on 6/14/15.
//  Copyright (c) 2015 DavidSights. All rights reserved.
//

#import "FeedViewController.h"
#import <Parse/Parse.h>

@interface FeedViewController ()

@end

@implementation FeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    PFUser *currentUser = [PFUser currentUser]; //show current user in console
    if (currentUser) {
        NSLog(@"Current user: %@", currentUser.username);
    } else {
        [self performSegueWithIdentifier:@"login" sender:self];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    PFUser *currentUser = [PFUser currentUser]; //show current user in console
    if (currentUser) {
        NSLog(@"Current user: %@", currentUser.username);
    } else {
        [self performSegueWithIdentifier:@"login" sender:self];
    }
}



@end