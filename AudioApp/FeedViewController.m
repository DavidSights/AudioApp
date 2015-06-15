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
    NSLog(@"%@", self.description);
    if ([PFUser currentUser] == nil) {
        [self performSegueWithIdentifier:@"login" sender:nil];
    }
}

@end
