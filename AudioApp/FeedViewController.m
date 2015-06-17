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


@interface FeedViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSArray *posts;
@property AVAudioPlayer *player;

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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    PFObject *currentObject = [self.posts objectAtIndex:section]; //Grab a specific post - each post is its own section
    // Find the number of items to be displayed... 1. Audio View, 2. Likes and Plays labels, 3. First comment, 4. Second comment, 5. Third comment, 6. View more comments link ... 6 rows in this section, may vary depending on how many comments there are... 
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PostTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    PFObject *object = [self.posts objectAtIndex:indexPath.row];

    cell.textLabel.text = [NSString stringWithFormat:@"%@",[object objectForKey:@"createdAt"]];
    return cell;
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
    NSLog(@"QUERY BEGAN.");
    PFQuery* query = [PFQuery queryWithClassName:@"Post"];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        } else {
            self.posts = objects;
            NSLog(@"%@", objects);
            NSLog(@"Retrieved %lu messages", (unsigned long)[self.posts count]);
            [self.tableView reloadData];
            NSLog(@"Reloaded tableview.");
        }
        NSLog(@"QUERY ENDED.");
    }];
}

#pragma mark - Update Information

- (void)viewDidAppear:(BOOL)animated {
    PFUser *currentUser = [PFUser currentUser]; //show current user in console
    if (currentUser) {
        NSLog(@"Current user: %@", currentUser.username);
        [self queryFromParse];
    } else {
        [self performSegueWithIdentifier:@"login" sender:self];
    }
}

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