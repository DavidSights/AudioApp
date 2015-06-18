//
//  ProfileViewController.m
//  AudioApp
//
//  Created by Alex Santorineos on 6/15/15.
//  Copyright (c) 2015 DavidSights. All rights reserved.
//

#import "ProfileViewController.h"
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>


@interface ProfileViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *displayNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *postsLikesController;
@property (weak, nonatomic) IBOutlet UILabel *aboutLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property NSArray *userPosts;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.userPosts =
    PFQuery *query = [[PFQuery alloc] initWithClassName:@"Post"];
    [query whereKey:@"author" equalTo:[PFUser currentUser]];

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

//-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
//    /* Create custom view to display section header... */
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, tableView.frame.size.width, 18)];
//    [label setFont:[UIFont boldSystemFontOfSize:12]];
////    NSString *string =[list objectAtIndex:section];
//    /* Section header is in 0th index... */
////    [label setText:string];
//    [view addSubview:label];
//    [view setBackgroundColor:[UIColor colorWithRed:166/255.0 green:177/255.0 blue:186/255.0 alpha:1.0]]; //your background color...
//    return view;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell;
    if (indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ProfileCell"];

    } else if (indexPath.row == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"MiddleCell"];

    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"PostCell"];
    }

    return cell;
}

@end
