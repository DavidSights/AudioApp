//
//  CommentTableViewController.m
//  AudioApp
//
//  Created by Alex Santorineos on 6/23/15.
//  Copyright (c) 2015 DavidSights. All rights reserved.
//

#import "CommentTableViewController.h"
#import "ProfileViewController.h"
#import "CommentTableViewCell.h"
@interface CommentTableViewController ()

@property (nonatomic)  NSArray *comments;

@end

@implementation CommentTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.comments = [NSArray new];
    if (self.post) {
        PFQuery *commentsQuery = [PFQuery queryWithClassName:@"Activity"];
        [commentsQuery whereKey:@"type" equalTo:@"Comment"];
        [commentsQuery whereKey:@"post" equalTo:self.post];
        [commentsQuery includeKey:@"fromUser"];
        [commentsQuery orderByAscending:@"createdAt"];
        [commentsQuery findObjectsInBackgroundWithBlock:^(NSArray *comments, NSError *error) {
            if (!error) {
                self.comments = comments;
                self.commentsLabel.text = [NSString stringWithFormat:@"%lu Comments", (unsigned long)self.comments.count];
            }
        }];
    }

    // Hide cell dividers.
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

}

-(void)setComments:(NSArray *)comments {
    _comments = comments;
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    return self.comments.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    CommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommentCell"];

    PFObject *comment = self.comments[indexPath.row];
    PFUser *user = comment[@"fromUser"];

    cell.usernameLabel.text = user.username;
    cell.commentLabel.text =  comment[@"content"];
    [cell.commentLabel sizeToFit];
//    cell.commentTextField.text = comment[@"content"];

    // Get profile image.
    PFFile *imageFile = user[@"profileImage"];
    NSData *imageData = [imageFile getData];
    UIImage *profileImage = [UIImage imageWithData:imageData];
    NSLog(@"Checked profile image and found image: %@", user[@"profileImage"]);

    cell.profileImage.clipsToBounds = YES;
    cell.profileImage.layer.cornerRadius = cell.profileImage.frame.size.width/2;

    // Show appropriate image.
    if (profileImage != nil) {
        cell.profileImage.image = profileImage;
    } else {
        NSLog(@"No profile image found for current user.");
        cell.profileImage.image = [UIImage imageNamed:@"emptyPhoto"];
    }

    return cell;
}

- (IBAction)onAddCommentTapped:(UIBarButtonItem *)sender {

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Add Comment" message:@"Add your comment" preferredStyle:UIAlertControllerStyleAlert];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Comment Text";
    }];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];

    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

        UITextField *textField = alert.textFields[0];

        if (![textField.text isEqualToString:@""]) {

            PFUser *currentUser = [PFUser currentUser];
            PFObject *comment = [PFObject objectWithClassName:@"Activity"];
            comment[@"fromUser"] = currentUser;
            comment[@"toUser"] = self.post[@"author"];
            comment[@"type"] = @"Comment";
            comment[@"post"] = self.post;
            comment[@"content"] = textField.text;

            [self.post incrementKey:@"numOfComments"];

            [comment saveInBackgroundWithBlock:^(BOOL completed, NSError *error) {

                if (completed && !error) {

                    NSLog(@"Comment Saved");

                    [self.post saveInBackgroundWithBlock:^(BOOL completed, NSError *error) {

                        if (completed && !error) {

                            NSLog(@"Post saved with comment increment");

                            NSMutableArray *commentsMutable = [self.comments mutableCopy];
                            [commentsMutable addObject:comment];
                            self.comments = commentsMutable;
                            self.commentsLabel.text = [NSString stringWithFormat:@"%lu Comments", (unsigned long)self.comments.count];

                            //update comments label for post in previous view controller
                        }
                    }];
                }
                
            }];
            
        }
    }];
    
    [alert addAction:cancelAction];
    [alert addAction:confirmAction];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"ProfileSegueID"]) {

        ProfileViewController *profileVC = segue.destinationViewController;
        UITableViewCell *cell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        PFObject *like = self.comments[indexPath.row];
        PFUser *user = like[@"fromUser"];
        profileVC.user = user;
    }
}
@end
