//
//  LikesTableViewController.m
//  AudioApp
//
//  Created by Tony Dakhoul on 6/24/15.
//  Copyright (c) 2015 DavidSights. All rights reserved.
//

#import "LikesTableViewController.h"
#import "ProfileViewController.h"
#import "LikeCell.h"
#import "User.h"

@interface LikesTableViewController () <LikeCellDelegate>

@property (nonatomic) NSArray *likes;

@end

@implementation LikesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if (self.post) {

        PFQuery *likesQuery = [PFQuery queryWithClassName:@"Activity"];
        [likesQuery whereKey:@"type" equalTo:@"Like"];
        [likesQuery whereKey:@"post" equalTo:self.post];
        [likesQuery includeKey:@"fromUser"];
        [likesQuery orderByAscending:@"createdAt"];

        [likesQuery findObjectsInBackgroundWithBlock:^(NSArray *likes, NSError *error) {

            if (!error) {

                self.likes = likes;
                self.likesLabel.text = [NSString stringWithFormat:@"%lu Likes", (unsigned long)self.likes.count];
            }
        }];
    }

}

-(void)setLikes:(NSArray *)likes {

    _likes = likes;
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.likes.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    LikeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LikeCell"];

    PFObject *like = self.likes[indexPath.row];
    PFUser *user = like[@"fromUser"];

    if ([user isEqual:[PFUser currentUser]]) {

        cell.followButton.hidden = YES;
    } else if (currentUserFollowDictionary[user.objectId]) {

        NSLog(@"user: %@ is in currentUserFriends array", user);
        [cell.followButton setTitle:@"Unfollow" forState:UIControlStateNormal];
        [cell.followButton sizeToFit];
    } else {

        cell.followButton.titleLabel.text = @"Follow";
    }

    cell.usernameLabel.text = [NSString stringWithFormat:@"%@", user.username];
    cell.delegate = self;

    return cell;
}

-(void)didTapFollowButton:(UIButton *)button {

    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)button.superview.superview];
    PFObject *likeActivity = self.likes[indexPath.row];
    PFObject *user = likeActivity[@"fromUser"];

    button.enabled = NO;

    if ([button.titleLabel.text isEqualToString:@"Unfollow"]) {

        PFObject *followActivity = currentUserFollowDictionary[user.objectId];

        [followActivity deleteInBackgroundWithBlock:^(BOOL completed, NSError *error) {


            if (completed && !error) {

                NSMutableDictionary *followDictionaryMutable = [currentUserFollowDictionary mutableCopy];
                [followDictionaryMutable removeObjectForKey:user.objectId];
                currentUserFollowDictionary = followDictionaryMutable;

                NSMutableArray *friendsMutable = [currentUserFriends mutableCopy];
                [friendsMutable removeObject:user];
                currentUserFriends = friendsMutable;

                [button setTitle:@"Follow" forState:UIControlStateNormal];
                button.enabled = YES;
            } else {
                
                button.enabled = YES;
            }
        }];

        NSLog(@"Follow activity to unfollow: %@", followActivity);

        button.enabled = YES;
    } else {

        PFObject *newFollowActivity = [PFObject objectWithClassName:@"Activity"];
        newFollowActivity[@"type"] = @"Follow";
        newFollowActivity[@"fromUser"] = [PFUser currentUser];
        newFollowActivity[@"toUser"] = user;

        [newFollowActivity saveInBackgroundWithBlock:^(BOOL completed, NSError *error) {

            if (completed && !error) {

                NSMutableDictionary *followDictionaryMutable = [currentUserFollowDictionary mutableCopy];
                [followDictionaryMutable setObject:newFollowActivity forKey:[newFollowActivity[@"toUser"] objectId]];
                currentUserFollowDictionary = followDictionaryMutable;

                NSMutableArray *friendsMutable = [currentUserFriends mutableCopy];
                [friendsMutable addObject:newFollowActivity[@"toUser"]];
                currentUserFriends = friendsMutable;

                [button setTitle:@"Unfollow" forState:UIControlStateNormal];
                button.enabled = YES;
            } else {

                button.enabled = YES;
            }
        }];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"ProfileSegue"]) {

        ProfileViewController *profileVC = segue.destinationViewController;
        UITableViewCell *cell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        PFObject *like = self.likes[indexPath.row];
        PFUser *user = like[@"fromUser"];
        profileVC.user = user;
    }
}
@end
