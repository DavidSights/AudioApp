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
@property UIColor *blue, *yellow, *red, *purple, *green, *darkBlue, *darkYellow, *darkRed, *darkPurple, *darkGreen, *pink;

@end

@implementation ActvityViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.backgroundColor = [UIColor purpleColor];
    refreshControl.tintColor = [UIColor whiteColor];
    [refreshControl addTarget:self
                       action:@selector(queryAll:)
             forControlEvents:UIControlEventValueChanged];
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
}

- (void)viewWillAppear:(BOOL)animated{
    [self getUserActivity];
}

- (void) getUserActivity {
    [self likesQuery];
    [self commentsQuery];
    [self followsQuery];
}
-(void)queryAll:(UIRefreshControl *)sender{
    [self likesQuery];
    [self commentsQuery];
    [self followsActivities];
    [sender endRefreshing];

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
        // Total number of likes.
        cell.titleLabel.text = @"Total Number of Likes";
        cell.statLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.likesActivities.count];
        return cell;
    } else if (indexPath.row == 1) {
        // Total number of followers.
        cell.titleLabel.text = @"Total Number of Followers";
        cell.statLabel.text = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
        cell.contentView.backgroundColor = self.purple;
        return cell;
   } else if (indexPath.row == 2){
       // Total number of posts.
       cell.titleLabel.text = @"Total Number of Comments";
       cell.statLabel.text = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
       cell.backgroundColor = self.yellow;
       return cell;
   } else if (indexPath.row == 3) {
       // Total number of comments recieved.
       cell.titleLabel.text = @"Total Number of Followers";
       cell.backgroundColor = self.red;
       return cell;
   } else if (indexPath.row == 4) {
       // Number of likes this week.
       cell.titleLabel.text = @"Number of Likes This Week";
       return cell;
   } else if (indexPath.row == 5) {
       // Number of followers this week.
       cell.titleLabel.text = @"Number of Posts This Week";
       return cell;
   } else if (indexPath.row == 6) {
       // Number of posts this week.
       cell.titleLabel.text = @"Number of Comments This Week";
       return cell;
   } else if (indexPath.row == 7) {
       // Number of comments recieved this week.
       cell.titleLabel.text = @"Number of Followers This Week";
       return cell;
   } else if (indexPath.row == 8) {
       // Age of account
       cell.titleLabel.text = @"Account Age";
       return cell;
   }
    
    return cell;
}

@end
