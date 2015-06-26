//
//  LikesTableViewController.m
//  AudioApp
//
//  Created by Tony Dakhoul on 6/24/15.
//  Copyright (c) 2015 DavidSights. All rights reserved.
//

#import "LikesTableViewController.h"
#import "ProfileViewController.h"

@interface LikesTableViewController ()

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

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LikeCell"];

    PFObject *like = self.likes[indexPath.row];
    PFUser *user = like[@"fromUser"];

    cell.textLabel.text = [NSString stringWithFormat:@"%@ liked this post!", user.username];

    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onFollowTapped:(UIButton *)sender {
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
