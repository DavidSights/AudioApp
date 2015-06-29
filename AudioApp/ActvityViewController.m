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
    self.likesActivities = [NSArray new];
    self.followsActivities = [NSArray new];
    self.commentActivities = [NSArray new];
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
        } else {
            NSLog(@"Error querying follows in Activity: %@", error.localizedDescription);
        }
        [self.tableView reloadData];
    }];
}

#pragma mark - TableView Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 9;
}

- (ActivityTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ActivityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellID"];
    if (indexPath.row == 0) {
        // Total number of likes count.
        cell.titleLabel.text = @"Total Number of Likes";
        cell.statLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.likesActivities.count];
        return cell;
    } else if (indexPath.row == 1) {
        // Total number of followers count.
       cell.titleLabel.text = @"Total Number of Followers";
        cell.statLabel.text = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
        return cell;
   } else if (indexPath.row == 2){
       cell.titleLabel.text = @"Total Number of Comments";
       cell.statLabel.text = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
       return cell;
   } else if (indexPath.row == 3) {
       cell.titleLabel.text = @"Total Number of Followers";
       return cell;
   } else if (indexPath.row == 4) {
       cell.titleLabel.text = @"Number of Likes This Week";
       return cell;
   } else if (indexPath.row == 5) {
       cell.titleLabel.text = @"Number of Posts This Week";
       return cell;
   } else if (indexPath.row == 6) {
       cell.titleLabel.text = @"Number of Comments This Week";
       return cell;
   } else if (indexPath.row == 7) {
       cell.titleLabel.text = @"Number of Followers This Week";
       return cell;
   } else if (indexPath.row == 8) {
       cell.titleLabel.text = @"Account Age";
       return cell;
   }
    
    return cell;
}

@end
