//
//  ActvityViewController.m
//  AudioApp
//
//  Created by Alex Santorineos on 6/25/15.
//  Copyright (c) 2015 DavidSights. All rights reserved.
//
#import <Parse/Parse.h>
#import "ActvityViewController.h"

@interface ActvityViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (nonatomic)  NSArray* activities;
@property (weak, nonatomic) IBOutlet UILabel *likesLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation ActvityViewController


- (void)viewDidLoad {

    self.activities = [[NSArray alloc]init];
    [super viewDidLoad];
    PFQuery *activityQuery = [PFQuery queryWithClassName:@"Activity"];
    [activityQuery whereKey:@"toUser" equalTo:[PFUser currentUser]];
    [activityQuery whereKey:@"type" containsString:@"Like"];

    [activityQuery orderByAscending:@"createdAt"];
    [activityQuery findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
        if (!error) {
            self.activities = activities;
            NSLog(@"%lu****************************", (unsigned long)self.activities.count);
            NSLog(@"%@",self.activities.lastObject);
        }
    }];
}

-(void)viewWillAppear:(BOOL)animated{

    PFQuery *activityQuery = [PFQuery queryWithClassName:@"Activity"];
    [activityQuery whereKey:@"toUser" equalTo:[PFUser currentUser]];
    [activityQuery whereKey:@"type" containsString:@"Like"];
    [activityQuery orderByAscending:@"createdAt"];
    [activityQuery findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
        if (!error) {
            self.activities = activities;
            NSLog(@"%lu", (unsigned long)self.activities.count);

//            self.likesLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.activities.count];
//            NSLog(@"%@-------------",self.activities.lastObject);
        }
    }];
}

-(void)setActivities:(NSArray *)activities {

    _activities = activities;
    [self.tableView reloadData];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return 3;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{


    if (indexPath.row == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"followersID"];

        cell.textLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.activities.count];

        NSLog(@"%lu😲", (unsigned long)self.activities.count);
        cell.detailTextLabel.text = @"number of likes";
        return cell;

    }

   else if (indexPath.row == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"postsID"];

        cell.textLabel.text = @"friend";

        return cell;

   }else{
       UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commentID"];

       cell.textLabel.text = @"hellooperator";

       return cell;


   }


}


@end
