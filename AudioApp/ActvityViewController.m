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

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSArray *likesActivities;
@property NSArray *followsActivities;
@property NSArray *commentActivities;
@property NSArray *posts;
@property UIColor *blue, *yellow, *red, *purple, *green, *darkBlue, *darkYellow, *darkRed, *darkPurple, *darkGreen, *pink, *deepBlue;

@end


@implementation ActvityViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.backgroundColor = self.deepBlue;
    refreshControl.tintColor = [UIColor whiteColor];
    [refreshControl addTarget:self action:@selector(queryAll:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    self.likesActivities = [NSArray new];
    self.followsActivities = [NSArray new];
    self.commentActivities = [NSArray new];

    // App color theme.
    self.blue = [UIColor colorWithRed:160/255.0 green:215/255.0 blue:231/255.0 alpha:1.0];
    self.yellow = [UIColor colorWithRed:249/255.0 green:217/255.0 blue:119/255.0 alpha:1.0];
    self.red = [UIColor colorWithRed:205/255.0 green:124/255.0 blue:135/255.0 alpha:1.0];
    self.purple = [UIColor colorWithRed:176/255.0 green:150/255.0 blue:193/255.0 alpha:1.0];
    self.green = [UIColor colorWithRed:177/255.0 green:215/255.0 blue:165/255.0 alpha:1.0];
    self.darkBlue = [UIColor colorWithRed:83/255.0 green:153/255.0 blue:174/255.0 alpha:1.0];
    self.darkYellow = [UIColor colorWithRed:204/255.0 green:164/255.0 blue:42/255.0 alpha:1.0];
    self.darkRed = [UIColor colorWithRed:166/255.0 green:81/255.0 blue:92/255.0 alpha:1.0];
    self.darkPurple = [UIColor colorWithRed:121/255.0 green:192/255.0 blue:140/255.0 alpha:1.0];
    self.darkGreen = [UIColor colorWithRed:75/255.0 green:151/255.0 blue:142/255.0 alpha:1.0];
    self.pink = [UIColor colorWithRed:255/255.0 green:187/255.0 blue:208/255.0 alpha:1.0];
    self.deepBlue = [UIColor colorWithRed:21/255.0 green:42/255.0 blue:59/255.0 alpha:1.0];

    self.view.backgroundColor = self.deepBlue;
}

- (void)viewWillAppear:(BOOL)animated{
    [self getUserActivity];
}

- (void) getUserActivity {
    [self likesQuery];
    [self commentsQuery];
    [self followsQuery];
}

- (void)queryAll:(UIRefreshControl *)sender{
    [self likesQuery];
    [self commentsQuery];
    [self followsActivities];
    [self postsQuery];
    [sender endRefreshing];
}

- (void)likesQuery {
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
        [self.tableView reloadData];
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
            // Code to get comments this week
        } else {
            NSLog(@"Error querying comments in Activity: %@", error.localizedDescription);
        }
        [self.tableView reloadData];
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
            // Code to get follows this week
        } else {
            NSLog(@"Error querying follows in Activity: %@", error.localizedDescription);
        }
        [self.tableView reloadData];
    }];
}

- (void) postsQuery {
    PFQuery *postsQuery = [PFQuery queryWithClassName:@"Post"];
    [postsQuery whereKey:@"author" equalTo:[PFUser currentUser].objectId];
    [postsQuery findObjectsInBackgroundWithBlock:^(NSArray *result, NSError *error) {
        if (!error) {
        self.posts = result;
        NSLog(@"Posts retireved: %lu", (unsigned long)self.posts.count);
        } else {
            NSLog(@"Error querying posts in Activity feed. Error: %@", error.localizedDescription);
        }
    }];
}

#pragma mark - TableView Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (ActivityTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ActivityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellID"];
    if (indexPath.row == 0) {
        // Total number of likes.
        cell.titleLabel.text = @"Likes Given to You";
        cell.statLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.likesActivities.count];
        cell.contentView.backgroundColor = self.green;
        return cell;
    } else if (indexPath.row == 1) {
        // Total number of followers.
        cell.titleLabel.text = @"People Follow You";
        cell.statLabel.text = [NSString stringWithFormat:@"%ld", self.followsActivities.count];
        cell.contentView.backgroundColor = self.purple;
        return cell;
   } else if (indexPath.row == 2) {
       // Total number of posts.
       cell.titleLabel.text = @"Posts From You";
       cell.statLabel.text = [NSString stringWithFormat:@"%ld", (long)indexPath.row]; // <------- Get number of posts
       cell.contentView.backgroundColor = self.yellow;
       return cell;
   } else if (indexPath.row == 3) {
       // Total number of comments recieved.
       cell.titleLabel.text = @"Comments on Your Posts";
       cell.contentView.backgroundColor = self.red;
       cell.statLabel.text = [NSString stringWithFormat:@"%ld", self.commentActivities.count];
       return cell;
   }
    return cell;
}

@end
