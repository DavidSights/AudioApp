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

-(id)initWithCoder:(NSCoder *)aDecoder{

    self = [super initWithCoder:aDecoder];
    if (self) {
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receiveNotification:) name:@"Test1" object:nil];
    }
    return self;
}


-(void)receiveNotification:(NSNotification *)notification {
    if ([notification.name isEqualToString:@"Test1"]) {

        [self queryFromParse];
        
    }
    
}
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

-(void)viewDidAppear:(BOOL)animated{

    PFUser *currentUser = [PFUser currentUser]; //show current user in console
    if (currentUser) {
        NSLog(@"Current user: %@", currentUser.username);
        [self queryFromParse];
    } else {
        [self performSegueWithIdentifier:@"login" sender:self];
    }
}

-(void)viewWillAppear:(BOOL)animated{

    PFUser *currentUser = [PFUser currentUser]; //show current user in console
    if (currentUser) {
        NSLog(@"Current user: %@", currentUser.username);
        [self queryFromParse];
        [self.tableView reloadData];
    } else {
        [self performSegueWithIdentifier:@"login" sender:self];
    }
}

-(void)queryFromParse {
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.posts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PostTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    PFObject *object = [self.posts objectAtIndex:indexPath.row];

    cell.textLabel.text = [NSString stringWithFormat:@"%@",[object objectForKey:@"createdAt"]];
    NSLog(@"%@",[[object objectForKey:@"author"]objectForKey:@"username"]);
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{


    if (!self.player.playing) {
        PFObject *object = [self.posts objectAtIndex:indexPath.row];
        PFFile *file = [object objectForKey:@"audio"];
        NSData *data = [file getData];

        self.player = [[AVAudioPlayer alloc] initWithData:data error:nil];
        [self.player play];

    }
    else{

        [self.player pause];

    }

}



@end