//
//  ViewController.m
//  AudioApp
//
//  Created by David Seitz Jr on 6/14/15.
//  Copyright (c) 2015 DavidSights. All rights reserved.
//

#import "FeedViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <Parse/Parse.h>
#import "LabelsAndButtonsTableViewCell.h"
#import "CommentTableViewCell.h"
#import "PostImageTableViewCell.h"
#import "Post.h"


@interface FeedViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSArray *posts;
@property AVAudioPlayer *player;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinnerActivityIndicator;
@end

@implementation FeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.posts = [[NSArray alloc]init];
    PFUser *currentUser = [PFUser currentUser]; //show current user in console
    if (currentUser) {
        NSLog(@"Current user: %@", currentUser.username);
        [self.player prepareToPlay];
        [self queryFromParse];
    } else {
        [self performSegueWithIdentifier:@"login" sender:self];
    }
}

#pragma mark - TableView

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.posts.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) { // First cell should display the audio view.
        return self.view.frame.size.width; // Height for audio view.
//        return [UIScreen mainScreen].bounds.size.width;
    }
    return  50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    Post *post = self.posts[section];

    NSInteger commentCount = post.comments.count;
    NSLog(@"Comment count: %d", commentCount);
    if (commentCount) {
        if (commentCount < 5) {
            return 2 + commentCount;
        } else {
            return 8;
        }
    }
    return 3;
}

//-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    // Remove seperator inset
//    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
//        [cell setSeparatorInset:UIEdgeInsetsZero];
//    }
//
//    // Prevent the cell from inheriting the Table View's margin settings
//    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
//        [cell setPreservesSuperviewLayoutMargins:NO];
//    }
//
//    // Explictly set your cell's layout margins
//    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
//        [cell setLayoutMargins:UIEdgeInsetsZero];
//    }
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSLog(@"IndexPath.section: %ld", indexPath.section);
    NSLog(@"Index path: %ld",(long)indexPath.row);

    if (indexPath.row == 0) {

        PostImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"imageCell"];
//        [cell.coloredView sizeToFit];
        CGRect cellRect = [tableView rectForRowAtIndexPath:indexPath];
        cell.coloredView.frame = cellRect;
        cell.layoutMargins = UIEdgeInsetsZero;
        cell.preservesSuperviewLayoutMargins = NO;
        NSLog(@"%f, %f", cell.center.x, cell.center.y);
        cell.backgroundColor = [UIColor yellowColor];
        return cell;
    } else if (indexPath.row == 1) {

        LabelsAndButtonsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"labelsAndButtonsCell"];
        Post *post = self.posts[indexPath.section];
        cell.likesLabel.text = [NSString stringWithFormat:@"%lu Likes", (unsigned long)post.likes.count];
        return cell;
    } else {

        CommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commentCell"];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (!self.player.playing) {
//        PFObject *object = [self.posts objectAtIndex:indexPath.row];
//        PFFile *file = [object objectForKey:@"audio"];
        Post *post = self.posts[indexPath.section];
        NSData *data = [post.audioFile getData];
        self.player = [[AVAudioPlayer alloc] initWithData:data error:nil];
        [self.player play];
    } else {
        [self.player pause];
    }
}

#pragma mark - Parse

- (void)queryFromParse {

    PFQuery* query = [PFQuery queryWithClassName:@"Post"];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {

        if (error) {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        } else {

            NSMutableArray *postsMutable = [NSMutableArray new];

            for (PFObject *object in objects) {

                Post *post = [[Post alloc] initWithPFObject:object];
                [postsMutable addObject:post];

            }

            self.posts = postsMutable;

            [self.tableView reloadData];
        }
    }];
}

#pragma mark - Update Information

- (void)viewWillAppear:(BOOL)animated{
    PFUser *currentUser = [PFUser currentUser]; //show current user in console
    if (currentUser) {
        NSLog(@"Current user: %@", currentUser.username);
        [self queryFromParse];
//        [self.tableView reloadData];
    } else {
        [self performSegueWithIdentifier:@"login" sender:self];
    }
}

#pragma mark - Notification Center

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {

        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receiveNotification:) name:@"Test1" object:nil];


    }
    return self;
}

- (void)receiveNotification:(NSNotification *)notification {
    if ([notification.name isEqualToString:@"Test1"]) {
        [self queryFromParse];
    }
}

@end