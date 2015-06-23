//
//  UserViewController.m
//  AudioApp
//
//  Created by Alex Santorineos on 6/23/15.
//  Copyright (c) 2015 DavidSights. All rights reserved.
//

#import "UserViewController.h"
#import "PostImageTableViewCell.h"
#import "LabelsAndButtonsTableViewCell.h"
#import "CommentTableViewCell.h"
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>


@interface UserViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *aboutLabel;
@property NSArray *userPosts;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property CGFloat lastOffsetY;

@end

//static const CGFloat kNavBarHeight = 52.0f;
//static const CGFloat kLabelHeight = 14.0f;
//static const CGFloat kMargin = 10.0f;
//static const CGFloat kSpacer = 2.0f;
//static const CGFloat kLabelFontSize = 12.0f;
//static const CGFloat kAddressHeight = 24.0f;

@implementation UserViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Set up profile details.
    PFUser *user = [PFUser currentUser];
    self.usernameLabel.text = user.username;
    self.aboutLabel.text = user[@"about"];

    //    self.userPosts =
    //    PFQuery *query = [[PFQuery alloc] initWithClassName:@"Post"];
    //    [query whereKey:@"author" equalTo:[PFUser currentUser]];

    [self queryFromParse];
}

-(void)viewDidAppear:(BOOL)animated {
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser != nil) {
        self.usernameLabel.text = currentUser.username;

    } else {
        [self.tabBarController setSelectedIndex:0];
    }
}

- (void)queryFromParse {
    //    NSLog(@"QUERY BEGAN.");
    PFQuery* query = [PFQuery queryWithClassName:@"Post"];
    [query whereKey:@"author" equalTo:[PFUser currentUser]];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        } else {
            self.userPosts = objects;

            NSLog(@"%lu", (unsigned long)self.userPosts.count);
            //            NSLog(@"%@", objects);
            //            NSLog(@"Retrieved %lu messages", (unsigned long)[self.posts count]);
            [self.tableView reloadData];
            //            NSLog(@"Reloaded tableview.");
        }
        //        NSLog(@"QUERY ENDED.");
    }];
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

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return self.userPosts.count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (section == 0) {
        return 2;
    } else {

        PFObject *post = [self.userPosts objectAtIndex:section - 1]; //Grab a specific post - each post is its own section
        PFQuery *commentsQuery = [PFQuery queryWithClassName:@"Comment"];
        [commentsQuery whereKey:@"post" equalTo:post];
        //    [commentsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        //        NSArray *comments = objects;
        //        if (!comments.count == 0) {
        //           numberOfComments = (int)comments.count;
        //        }
        //    }];

        NSArray *comments = [commentsQuery findObjects];

        if (comments) {
            if (comments.count < 5) {
                return 2 + comments.count;
            } else {
                return 8;
            }
        }
    }

    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell;

    if (indexPath.section == 0) {

        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"ProfileCell"];

        } else if (indexPath.row == 1) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"MiddleCell"];

        }
    } else {

        if (indexPath.row == 0) {

            PostImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PostCell"];
            //        [cell.coloredView sizeToFit];
            //            CGRect cellRect = [tableView rectForRowAtIndexPath:indexPath];
            //            cell.coloredView.frame = cellRect;
            cell.layoutMargins = UIEdgeInsetsZero;
            cell.preservesSuperviewLayoutMargins = NO;
            NSLog(@"%f, %f", cell.center.x, cell.center.y);
            cell.backgroundColor = [UIColor yellowColor];
            return cell;
        } else if (indexPath.row == 1) {

            LabelsAndButtonsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LikeCell"];
            //            PFQuery *likesQuery = [PFQuery queryWithClassName:@"Like"];
            //            [likesQuery whereKey:@"Post" equalTo:self.userPosts[indexPath.section]];
            //            NSArray *likes = [likesQuery findObjects];
            //            cell.likesLabel.text = [NSString stringWithFormat:@"%lu Likes", (unsigned long)likes.count];
            return cell;
        } else {

            CommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommentCell"];
            return cell;
        }
    }

    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGRect frame = self.navigationController.navigationBar.frame;
    CGFloat size = frame.size.height - 21;
    CGFloat framePercentageHidden = ((20 - frame.origin.y) / (frame.size.height - 1));
    CGFloat scrollOffset = scrollView.contentOffset.y;
    CGFloat scrollDiff = scrollOffset - self.lastOffsetY;
    CGFloat scrollHeight = scrollView.frame.size.height;
    CGFloat scrollContentSizeHeight = scrollView.contentSize.height + scrollView.contentInset.bottom;

    if (scrollOffset <= -scrollView.contentInset.top) {
        frame.origin.y = 20;
    } else if ((scrollOffset + scrollHeight) >= scrollContentSizeHeight) {
        frame.origin.y = -size;
    } else {
        frame.origin.y = MIN(20, MAX(-size, frame.origin.y - scrollDiff));

    }

    [self.navigationController.navigationBar setFrame:frame];
    [self updateBarButtonItems:(1 - framePercentageHidden)];
    self.lastOffsetY = scrollOffset;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {

    [self stoppedScrolling];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate {

    if (!decelerate) {
        [self stoppedScrolling];
    }
}

- (void)stoppedScrolling {

    CGRect frame = self.navigationController.navigationBar.frame;
    if (frame.origin.y < -5) {
        [self animateNavBarTo:-(frame.size.height - 21)];
        //        [self animateWebView:-(frame.size.height - 21)];
    } else {
        [self animateNavBarTo:(frame.size.height - 21)];
        //                [self animateWebView:(frame.size.height - 21)];

    }
}

- (void)updateBarButtonItems:(CGFloat)alpha {

    [self.navigationItem.leftBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem* item, NSUInteger i, BOOL *stop) {
        item.customView.alpha = alpha;
    }];
    [self.navigationItem.rightBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem* item, NSUInteger i, BOOL *stop) {
        item.customView.alpha = alpha;
    }];
    self.navigationItem.titleView.alpha = alpha;
    self.navigationController.navigationBar.tintColor = [self.navigationController.navigationBar.tintColor colorWithAlphaComponent:alpha];
    //    self.urlTextField.alpha = alpha;
}

- (void)animateNavBarTo:(CGFloat)y {

    [UIView animateWithDuration:0.2 animations:^{
        CGRect frame = self.navigationController.navigationBar.frame;
        CGFloat alpha = (frame.origin.y >= y ? 0 : 1);
        frame.origin.y = y;
        [self.navigationController.navigationBar setFrame:frame];
        [self updateBarButtonItems:alpha];
    }];
}

@end

