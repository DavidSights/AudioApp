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
@property (nonatomic)  NSArray* likesActivities;
@property (nonatomic)  NSArray* followsActivities;
@property (nonatomic) NSArray *commentActivities;
@property (weak, nonatomic) IBOutlet UILabel *likesLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation ActvityViewController


- (void)viewDidLoad {
//    self.activities = [[NSArray alloc]init];
    [super viewDidLoad];
    self.followsActivities = [[NSArray alloc]init];
    self.likesActivities = [[NSArray alloc]init];
    [self activityLikesQuery];
    [self activityFollowQuery];
    [self activityCommentQueries];
}

-(void)viewWillAppear:(BOOL)animated{
    [self activityLikesQuery];
}

-(void)activityLikesQuery {
    PFQuery *activityQuery = [PFQuery queryWithClassName:@"Activity"];
    [activityQuery whereKey:@"toUser" equalTo:[PFUser currentUser]];
    [activityQuery whereKey:@"type" containsString:@"Like"];
    [activityQuery orderByAscending:@"createdAt"];
    [activityQuery findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
        if (!error) {
            self.likesActivities = activities;
            NSLog(@"%lu", (unsigned long)self.likesActivities.count);
        }
    }];
}

- (void)activityCommentQueries {
    PFQuery *activityQuery = [PFQuery queryWithClassName:@"Activity"];
    [activityQuery whereKey:@"toUser" equalTo:[PFUser currentUser]];
    [activityQuery whereKey:@"type" containsString:@"Comment"];
    [activityQuery orderByAscending:@"createdAt"];
    [activityQuery findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
        if (!error) {
//            self.activities = activities;
//            self.likesLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.activities.count];
//            NSLog(@"%@-------------",self.activities.lastObject);
            self.commentActivities = activities;
            NSLog(@"%lu", (unsigned long)self.likesActivities.count);
        }
    }];
}

-(void)activityFollowQuery {
    PFQuery *activityQuery = [PFQuery queryWithClassName:@"Activity"];
    [activityQuery whereKey:@"toUser" equalTo:[PFUser currentUser]];
    [activityQuery whereKey:@"type" containsString:@"Follow"];
    [activityQuery orderByAscending:@"createdAt"];
    [activityQuery findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
        if (!error) {
            self.followsActivities = activities;
            NSLog(@"%lu", (unsigned long)self.followsActivities.count);
        }
    }];
}

-(void)setCommentActivities:(NSArray *)commentActivities{
    _commentActivities = commentActivities;
    [self.tableView reloadData];
}

-(void)setLikesActivities:(NSArray *)likesActivities{
    _likesActivities = likesActivities;
    [self.tableView reloadData];
}

- (void)setFollowsActivities:(NSArray *)followsActivities{
    _followsActivities = followsActivities;
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"followersID"];
//        cell.textLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.activities.count];
//        NSLog(@"%lu😲", (unsigned long)self.activities.count);
        cell.textLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.likesActivities.count];
        cell.detailTextLabel.text = @"number of likes";
        return cell;
    } else if (indexPath.row == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"postsID"];
//        cell.textLabel.text = @"friend";
        cell.textLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.followsActivities.count];
       cell.detailTextLabel.text = @"number of followers";

        return cell;
   } else {
       UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commentID"];
       cell.textLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.commentActivities.count];
       cell.detailTextLabel.text = @"number of comments";

       return cell;
   }
}

@end
