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
#import "PostTableViewCell.h"
#import "LabelsAndButtonsTableViewCell.h"
#import "CommentTableViewCell.h"
#import "PostImageTableViewCell.h"


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
        NSLog(@"THE VIEW IS THIS WIDE: %f", self.view.frame.size.width);
//        return self.view.frame.size.width; // Height for audio view.
        return [UIScreen mainScreen].bounds.size.width;
    }
    return  50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    __block int numberOfComments;

    PFObject *post = [self.posts objectAtIndex:section]; //Grab a specific post - each post is its own section
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
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    PostTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"imageCell"];
    NSLog(@"IndexPath.section: %ld", indexPath.section);
    NSLog(@"Index path: %ld",(long)indexPath.row);
//    return cell;
    if (indexPath.row == 0) {
        PostTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"imageCell"];
        cell.backgroundColor = [UIColor yellowColor];
        return cell;
    } else if (indexPath.row == 1) {
        LabelsAndButtonsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"labelsAndButtonsCell"];
        PFQuery *likesQuery = [PFQuery queryWithClassName:@"Like"];
        [likesQuery whereKey:@"Post" equalTo:self.posts[indexPath.section]];
        NSArray *likes = [likesQuery findObjects];
        cell.likesLabel.text = [NSString stringWithFormat:@"%lu Likes", (unsigned long)likes.count];
        return cell;
    } else {
        CommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commentCell"];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (!self.player.playing) {
        PFObject *object = [self.posts objectAtIndex:indexPath.row];
        PFFile *file = [object objectForKey:@"audio"];
        NSData *data = [file getData];
        self.player = [[AVAudioPlayer alloc] initWithData:data error:nil];
        [self.player play];
    } else {
        [self.player pause];
    }
}

#pragma mark - Parse

- (void)queryFromParse {
//    NSLog(@"QUERY BEGAN.");
    PFQuery* query = [PFQuery queryWithClassName:@"Post"];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        } else {
            self.posts = objects;
//            NSLog(@"%@", objects);
//            NSLog(@"Retrieved %lu messages", (unsigned long)[self.posts count]);
            [self.tableView reloadData];
//            NSLog(@"Reloaded tableview.");
        }
//        NSLog(@"QUERY ENDED.");
    }];
}

#pragma mark - Update Information

- (void)viewWillAppear:(BOOL)animated{
    PFUser *currentUser = [PFUser currentUser]; //show current user in console
    if (currentUser) {
        NSLog(@"Current user: %@", currentUser.username);
        [self queryFromParse];
        [self.tableView reloadData];
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