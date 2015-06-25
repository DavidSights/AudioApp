//
//  CommentTableViewController.m
//  AudioApp
//
//  Created by Alex Santorineos on 6/23/15.
//  Copyright (c) 2015 DavidSights. All rights reserved.
//

#import "CommentTableViewController.h"

@interface CommentTableViewController ()

@property (nonatomic)  NSArray *comments;

@end

@implementation CommentTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

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

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];

    PFObject *comment = self.comments[indexPath.row];
    PFUser *user = comment[@"fromUser"];

    cell.textLabel.text = user.username;
    cell.detailTextLabel.text = comment[@"content"];

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
            comment[@"toUser"] = self.post[@"user"];
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
@end
