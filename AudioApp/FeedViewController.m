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
#import "PostHeaderCell.h"
#import "PostFooterCell.h"
#import "PostCell.h"
#import "Post.h"
#import "Comment.h"
#import "AudioPlayerWithTag.h"

@interface FeedViewController () <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, PostFooterCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic)  NSArray *posts;
@property NSArray *likes;
@property NSTimer *timer;
@property AudioPlayerWithTag *player;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinnerActivityIndicator;
@property UIScrollView *scrollview;

@end

@implementation FeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.scrollview.delegate = self;
    self.posts = [[NSArray alloc]init];
    PFUser *currentUser = [PFUser currentUser]; //show current user in console
    if (currentUser) {
        NSLog(@"Current user: %@", currentUser.username);
//        [self queryFromParse];

        [Post queryPostsForFeedWithCompletion:^(NSArray *posts) {
            self.posts = posts;
        }];
    } else {
        [self performSegueWithIdentifier:@"login" sender:self];
    }

    // Required to make sound play from speakers rather than ear piece. Otherwise will randomly choose to play from speakers or earpiece.
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *setCategoryError = nil;
    if (![session setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:&setCategoryError]) {
        NSLog(@"%@", setCategoryError);
        // handle error
    }
}

- (void) viewDidDisappear:(BOOL)animated{
    [self.player stop];
}

-(void)setPosts:(NSArray *)posts {

    _posts = posts;
    [self.tableView reloadData];
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
//    Post *post = self.posts[section];
//    NSInteger commentCount = post.comments.count;
////    NSLog(@"Comment count: %d", commentCount);
//
//    if (commentCount < 5) {
////        NSLog(@"Comment count less than 5");
//
//        return commentCount + 2;
//    } else {
//        return 8;
//    }
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {

    return 50.0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    PostHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HeaderCell"];

    Post *post = self.posts[section];
    PFUser *user = post[@"user"];
    NSString *displayNameText = user[@"displayName"];
    NSLog(@"%@", displayNameText);
    cell.displayNameLabel.text = displayNameText;
    [cell.displayNameLabel sizeToFit];

    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {

    return 30.0;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {

    PostFooterCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FooterCell"];

    cell.delegate = self;
    cell.tag = section;
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

        PostCell* postCell = [tableView dequeueReusableCellWithIdentifier:@"PostCell"];
        CGRect cellRect = [tableView rectForRowAtIndexPath:indexPath];

        postCell.coloredView.frame = cellRect;
        postCell.layoutMargins = UIEdgeInsetsZero;
        postCell.preservesSuperviewLayoutMargins = NO;

        Post *post = self.posts[indexPath.section];

        if (post[@"colorHex"] != nil) {
            NSString *string = post[@"colorHex"];
            postCell.backgroundColor = [self colorWithHexString:string];
        }else{
            postCell.backgroundColor = [UIColor yellowColor];
        }

        return postCell;
}

#pragma mark - Audio

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.row == 0) { // Only respond to audio display cell.

        if (self.player.tag == indexPath.section) { // Check if user is trying to play the same audio again.
            if (self.player.playing) {
                [self.player pause];
            } else if (self.player.tag == 0) { // Audio tag is automatically set to 0, so the first post requires special attention.
                if (self.player.playing) {
                    [self.player pause];
                }
                Post *post = self.posts[indexPath.section];
                NSData *data = [post[@"audioFile"] getData]; // Get audio from specific post in Parse - Can we avoid this query?
                self.player = [[AudioPlayerWithTag alloc] initWithData:data error:nil];
                [self playRecordedAudio];
            } else if (!self.player.playing) {
                [self.player play];
            }
        } else { // A new post was tapped - stop whatever audio the player is playing, load up the new audio, and play it.
            [self.player stop];
            Post *post = self.posts[indexPath.section];
            NSData *data = [post[@"audioFile"] getData]; // Get audio from specific post in Parse - Can we avoid this query?
            self.player = [[AudioPlayerWithTag alloc] initWithData:data error:nil];
            self.player.tag = (int)indexPath.section;
            [self playRecordedAudio];
        }
    }
}

- (void)playRecordedAudio {
    self.player.numberOfLoops = -1;
    [self.player play];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(playingTime) userInfo:nil repeats:YES];
}

- (NSTimeInterval)playingTime {
    PostCell* postImageTableViewCell = (PostCell *)[self.tableView cellForRowAtIndexPath:self.tableView.indexPathForSelectedRow];
    postImageTableViewCell.timerLabel.text = [NSString stringWithFormat:@"%.0f",self.player.currentTime];
    return self.player.currentTime;
}

#pragma mark - Parse

- (void)queryFromParse {

    [Post queryPostsForFeedWithCompletion:^(NSArray *posts) {
        self.posts = posts;
    }];
}

#pragma mark - Update Information

- (void)viewWillAppear:(BOOL)animated {
    PFUser *currentUser = [PFUser currentUser]; //show current user in console
    if (currentUser) {
//        [self queryFromParse];
    } else {
        [self performSegueWithIdentifier:@"login" sender:self];
    }
}

#pragma mark - Notification Center

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        //if the notification is touched stop spinng. if is not touched start spinning
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receiveNotification:) name:@"Test1" object:nil];
    }
    return self;
}

- (void)receiveNotification:(NSNotification *)notification {
    if ([notification.name isEqualToString:@"Test1"]) {
        [self queryFromParse];
    }
}

-(void)didTapLikeButton:(UIButton *)button {

    NSLog(@"Tapped");

}

- (IBAction)onLikesButtonTapped:(UIButton *)button {

    PostFooterCell *cell = (PostFooterCell *)button.superview.superview;

    PFUser *currentUser = [PFUser currentUser];
    Post *post = self.posts[cell.tag];
    NSMutableArray *likes = [post[@"likes"] mutableCopy];

    NSLog(@"Likes: %@", likes);

    if ([likes containsObject:currentUser.objectId]) {

        NSLog(@"User already liked this post");

        button.enabled = NO;

        PFQuery *likeQuery = [PFQuery queryWithClassName:@"Activity"];
        [likeQuery whereKey:@"type" equalTo:@"Like"];
        [likeQuery whereKey:@"fromUser" equalTo:currentUser];
        [likeQuery whereKey:@"toUser" equalTo:post[@"user"]];

        [likeQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {

            if (!error) {

                for (PFObject *likeActivity in objects) {

                    [likeActivity deleteEventually];
                }
            }

        }];

        [post removeObject:currentUser.objectId forKey:@"likes"];
        [post incrementKey:@"numOfLikes" byAmount:[NSNumber numberWithInt:-1]];

        [post saveInBackgroundWithBlock:^(BOOL completed, NSError *error) {

            if (completed && !error) {

                NSLog(@"Likes uploaded successfully");
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:cell.tag];
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];

                button.enabled = YES;
            }
        }];

    } else {

        button.enabled = NO;

        PFObject *activity = [PFObject objectWithClassName:@"Activity"];
        activity[@"fromUser"] = currentUser;
        activity[@"toUser"] = post[@"user"];
        activity[@"post"] = post;
        activity[@"type"] = @"Like";
        activity[@"content"] = @"";

        [post addObject:currentUser.objectId forKey:@"likes"];
        [post incrementKey:@"numOfLikes"];

        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:cell.tag];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];

        [activity saveInBackgroundWithBlock:^(BOOL completed, NSError *error) {

            if (completed && !error) {

                NSLog(@"Activity Saved");

                [post saveInBackgroundWithBlock:^(BOOL completed, NSError *error) {

                    if (completed && !error) {

                        NSLog(@"Likes uploaded successfully");
                        
                        button.enabled = YES;
                    } else {
                        
                        button.enabled = YES;
                    }
                }];
            } else {
                
                button.enabled = YES;
            }
        }];
    }
}


#pragma mark - NSString to UIColor

- (UIColor *) colorWithHexString: (NSString *) hexString {
    NSString *colorString = [[hexString stringByReplacingOccurrencesOfString: @"#" withString: @""] uppercaseString];
    CGFloat alpha, red, blue, green;

    // #RGB
    alpha = 1.0f;
    red   = [self colorComponentFrom: colorString start: 0 length: 2];
    green = [self colorComponentFrom: colorString start: 2 length: 2];
    blue  = [self colorComponentFrom: colorString start: 4 length: 2];

    return [UIColor colorWithRed: red green: green blue: blue alpha: alpha];
}

- (CGFloat) colorComponentFrom: (NSString *) string start: (NSUInteger) start length: (NSUInteger) length {
    NSString *substring = [string substringWithRange: NSMakeRange(start, length)];
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat: @"%@%@", substring, substring];
    unsigned hexComponent;
    [[NSScanner scannerWithString: fullHex] scanHexInt: &hexComponent];
    return hexComponent / 255.0;
}
//keep method below!
//-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
//
//    for (NSIndexPath *path in [self.tableView indexPathsForVisibleRows]) {
////        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:path];
//
//
//        Post *post = self.posts[path.section];
//        NSData *data = [post.audioFile getData];
//        AVAudioSession *session = [AVAudioSession sharedInstance];
//
//        NSError *setCategoryError = nil;
//        if (![session setCategory:AVAudioSessionCategoryPlayback
//                      withOptions:AVAudioSessionCategoryOptionMixWithOthers
//                            error:&setCategoryError]) {
//
//            NSLog(@"%@", setCategoryError);
//            // handle error
//        }
//
//
//
//        self.player = [[AVAudioPlayer alloc] initWithData:data error:nil];
//
//        [self.player play];
//    }
//}




@end