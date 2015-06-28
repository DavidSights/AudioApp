//
//  ActvityViewController.m
//  AudioApp
//
//  Created by Alex Santorineos on 6/25/15.
//  Copyright (c) 2015 DavidSights. All rights reserved.
//
#import <Parse/Parse.h>
#import "ActvityViewController.h"

@interface ActvityViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property NSArray* activities;
@end

@implementation ActvityViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    PFQuery *activityQuery = [PFQuery queryWithClassName:@"Activity"];
    [activityQuery whereKey:@"toUser" equalTo:[PFUser currentUser]];
//    [commentsQuery includeKey:@"fromUser"];

    [activityQuery orderByAscending:@"createdAt"];
    [activityQuery findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
        if (!error) {
            self.activities = activities;
            NSLog(@"%i", self.activities.count);
            NSLog(@"%@",self.activities.lastObject);
        }
    }];

}

-(void)viewWillAppear:(BOOL)animated{

    PFQuery *activityQuery = [PFQuery queryWithClassName:@"Activity"];
    [activityQuery whereKey:@"toUser" equalTo:[PFUser currentUser]];
    //    [commentsQuery includeKey:@"fromUser"];

    [activityQuery orderByAscending:@"createdAt"];
    [activityQuery findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
        if (!error) {
            self.activities = activities;
            NSLog(@"%i", self.activities.count);
            NSLog(@"%@-------------",self.activities.lastObject);
        }
    }];


}



@end
