//
//  ActvityViewController.m
//  AudioApp
//
//  Created by Alex Santorineos on 6/25/15.
//  Copyright (c) 2015 DavidSights. All rights reserved.
//

#import <Parse/Parse.h>
#import "ActvityViewController.h"
#import "ActivityTableViewCell.h"

@interface ActvityViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *likesLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSArray *likesActivities;
@property NSArray *followsActivities;
@property NSArray *commentActivities;

@end

@implementation ActvityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated{
    [self getUserActivity];
}

- (void) getUserActivity {
    [self likesQuery];
    [self commentsQuery];
    [self followsQuery];
}

-(void)likesQuery {
    PFQuery *activityQuery = [PFQuery queryWithClassName:@"Activity"];
    [activityQuery whereKey:@"toUser" equalTo:[PFUser currentUser]];
    [activityQuery whereKey:@"type" containsString:@"Like"];
    [activityQuery orderByAscending:@"createdAt"];
    [activityQuery findObjectsInBackgroundWithBlock:^(NSArray *result, NSError *error) {
        if (!error) {
            self.likesActivities = result;
        } else {
            NSLog(@"Error querying likes in Activity: %@", error.localizedDescription);
        }
    }];
}

- (void)commentsQuery {
    PFQuery *activityQuery = [PFQuery queryWithClassName:@"Activity"];
    [activityQuery whereKey:@"toUser" equalTo:[PFUser currentUser]];
    [activityQuery whereKey:@"type" containsString:@"Comment"];
    [activityQuery orderByAscending:@"createdAt"];
    [activityQuery findObjectsInBackgroundWithBlock:^(NSArray *result, NSError *error) {
        if (!error) {
            self.commentActivities = result;
        } else {
            NSLog(@"Error querying comments in Activity: %@", error.localizedDescription);
        }
    }];
}

-(void)followsQuery {
    PFQuery *activityQuery = [PFQuery queryWithClassName:@"Activity"];
    [activityQuery whereKey:@"toUser" equalTo:[PFUser currentUser]];
    [activityQuery whereKey:@"type" containsString:@"Follow"];
    [activityQuery orderByAscending:@"createdAt"];
    [activityQuery findObjectsInBackgroundWithBlock:^(NSArray *result, NSError *error) {
        if (!error) {
            self.followsActivities = result;
        } else {
            NSLog(@"Error querying follows in Activity: %@", error.localizedDescription);
        }
    }];
}

#pragma mark - TableView Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 9;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ActivityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    if (indexPath.row == 0) {
        // Total number of likes count.
        cell.statLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.likesActivities.count];
        cell.titleLabel.text = @"number of likes";
        return cell;
    } else if (indexPath.row == 1) {
        // Total number of followers count.
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"postsID"];
//        cell.textLabel.text = @"friend";
        cell.textLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.followsActivities.count];
       cell.detailTextLabel.text = @"number of followers";
        return cell;
   } else if (indexPath.row == 2){
       UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commentID"];
       cell.textLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.commentActivities.count];
       cell.detailTextLabel.text = @"number of comments";
       return cell;
   } else if (indexPath.row == 3) {

   } else if (indexPath.row == 4) {

   } else if (indexPath.row == 5) {

   } else if (indexPath.row == 6) {

   } else if (indexPath.row == 7) {

   } else if (indexPath.row == 8) {

   }
    return cell;
}

@end
