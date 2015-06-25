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
#import "LikesAndCommentsCell.h"
#import "PostCell.h"
#import "Post.h"
#import "AudioPlayerWithTag.h"
#import "LikesTableViewController.h"
#import "CommentTableViewController.h"

@interface FeedViewController () <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, AVAudioPlayerDelegate, PostFooterCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic)  NSArray *posts;
@property NSArray *likes;
@property NSTimer *timer;
@property AudioPlayerWithTag *player;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinnerActivityIndicator;
@property UIScrollView *scrollview;
@property int integer;
@property NSIndexPath *indexPath;
@end

@implementation FeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.integer = 0;
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
    return 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {

    return 50.0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    PostHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HeaderCell"];

    Post *post = self.posts[section];
    PFUser *user = post[@"author"];
    NSLog(@"User: %@", user.username);
    NSString *displayNameText = user[@"displayName"];
    NSLog(@"Display Name: %@", displayNameText);
    cell.displayNameLabel.text = displayNameText;
    [cell.displayNameLabel sizeToFit];
    cell.backgroundColor = [UIColor whiteColor];

    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.row == 0) {

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
    } else {

        LikesAndCommentsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LikesAndCommentsCell"];

        Post *post = self.posts[indexPath.section];
        cell.likesLabel.text = [NSString stringWithFormat:@"%@ Likes", post[@"numOfLikes"]];
        cell.commentsLabel.text = [NSString stringWithFormat:@"%@ Comments", post[@"numOfComments"]];

        cell.delegate = self;
        cell.tag = indexPath.section;
        cell.backgroundColor = [UIColor whiteColor];

        cell.likesLabel.tag = indexPath.section;
        cell.commentsLabel.tag = indexPath.section;

        UITapGestureRecognizer *likesGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(likesLabelTapped:)];
        UITapGestureRecognizer *commentsGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(commentsLabelTapped:)];

        [cell.likesLabel setUserInteractionEnabled:YES];
        [cell.likesLabel addGestureRecognizer:likesGestureRecognizer];
        [cell.commentsLabel setUserInteractionEnabled:YES];
        [cell.commentsLabel addGestureRecognizer:commentsGestureRecognizer];

        return cell;
    }
}

#pragma mark - Audio

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.indexPath = indexPath;

    if (indexPath.row == 0) { // Only respond to audio display cell.

        NSLog(@"TAP");

        if (self.player.tag == indexPath.section) { // Check if user is trying to play the same audio again.
            if (self.player.playing) {
                [self.player pause];
            } else if (self.player.tag == 0) { // Audio tag is automatically set to 0, so the first post requires special attention.
                if (self.player.playing) {
                    [self.player pause];
                }
                Post *post = self.posts[indexPath.section];
                NSData *data = [post[@"audio"] getData]; // Get audio from specific post in Parse - Can we avoid this query?
                self.player = [[AudioPlayerWithTag alloc] initWithData:data error:nil];
                [self playRecordedAudio];
            } else if (!self.player.playing) {
                [self.player play];
            }
        } else { // A new post was tapped - stop whatever audio the player is playing, load up the new audio, and play it.
            [self.player stop];
            Post *post = self.posts[indexPath.section];
            NSData *data = [post[@"audio"] getData]; // Get audio from specific post in Parse - Can we avoid this query?
            self.player = [[AudioPlayerWithTag alloc] initWithData:data error:nil];
            self.player.tag = (int)indexPath.section;
            self.integer = 0;

            [self playRecordedAudio];
        }
    }
}

- (void)playRecordedAudio {
//    self.player.numberOfLoops = -1;
    self.player.delegate = self;
    [self.player play];


    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(playingTime) userInfo:nil repeats:YES];
}

- (NSTimeInterval)playingTime {
    PostCell* postImageTableViewCell = (PostCell *)[self.tableView cellForRowAtIndexPath:self.tableView.indexPathForSelectedRow];
    postImageTableViewCell.timerLabel.text = [NSString stringWithFormat:@"%.0f",self.player.currentTime];
    return self.player.currentTime;
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{


   if (!self.player.playing) {

        if (flag == YES) {

//            Post *post = self.posts[self.indexPath.section];
//            NSData *data = [post.audioFile getData]; // Get audio from specific post in Parse - Can we avoid this query?
//            self.player = [[AudioPlayerWithTag alloc] initWithData:data error:nil];
//            [self playRecordedAudio];

            [self.player play];

            self.integer = self.integer +1;

            NSLog(@"%d_______",self.integer);
            
        }

    }
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

    LikesAndCommentsCell *cell = (LikesAndCommentsCell *)button.superview.superview;

    PFUser *currentUser = [PFUser currentUser];
    Post *post = self.posts[cell.tag];
    NSMutableArray *likes = [post[@"likes"] mutableCopy];

    if ([likes containsObject:currentUser.objectId]) {

        NSLog(@"User already liked this post");

        button.enabled = NO;

        PFQuery *likeQuery = [PFQuery queryWithClassName:@"Activity"];
        [likeQuery whereKey:@"type" equalTo:@"Like"];
        [likeQuery whereKey:@"fromUser" equalTo:currentUser];
        [likeQuery whereKey:@"toUser" equalTo:post[@"author"]];

        [likeQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {

            if (!error) {

                for (PFObject *likeActivity in objects) {

                    [likeActivity deleteEventually];
                }
            }
        }];

        [post removeObject:currentUser.objectId forKey:@"likes"];
        [post incrementKey:@"numOfLikes" byAmount:[NSNumber numberWithInt:-1]];

        cell.likesLabel.text = [NSString stringWithFormat:@"%@ Likes", post[@"numOfLikes"]];

        [post saveInBackgroundWithBlock:^(BOOL completed, NSError *error) {

            if (completed && !error) {

                NSLog(@"Likes uploaded successfully");

                button.enabled = YES;
            } else {

                button.enabled = YES;
            }
        }];

    } else {

        button.enabled = NO;

        PFObject *activity = [PFObject objectWithClassName:@"Activity"];
        activity[@"fromUser"] = currentUser;
        activity[@"toUser"] = post[@"author"];
        activity[@"post"] = post;
        activity[@"type"] = @"Like";
        activity[@"content"] = @"";

        [post addObject:currentUser.objectId forKey:@"likes"];
        [post incrementKey:@"numOfLikes"];

        cell.likesLabel.text = [NSString stringWithFormat:@"%@ Likes", post[@"numOfLikes"]];

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

-(void)likesLabelTapped:(UITapGestureRecognizer *)sender {

    [self performSegueWithIdentifier:@"LikeSegue" sender:sender];
}

-(void)commentsLabelTapped:(UITapGestureRecognizer *)sender {

    [self performSegueWithIdentifier:@"CommentSegue" sender:sender];
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



-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error{
    NSLog(@"%@",error);


}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"LikeSegue"]) {

        LikesTableViewController *likesVC = segue.destinationViewController;
        likesVC.post = self.posts[((UITapGestureRecognizer *)sender).view.tag];
        likesVC.likesLabel = (UILabel *)((UITapGestureRecognizer *)sender).view;

    } else if ([segue.identifier isEqualToString:@"CommentSegue"]) {

        NSLog(@"Comments VC Segue");

        if ([sender isKindOfClass:[UITapGestureRecognizer class]]) {

            CommentTableViewController *commentsVC = segue.destinationViewController;
            commentsVC.post = self.posts[((UITapGestureRecognizer *)sender).view.tag];
            commentsVC.commentsLabel = (UILabel *)((UITapGestureRecognizer *)sender).view;
        } else {

            CommentTableViewController *commentsVC = segue.destinationViewController;
            //            NSLog(@"add comment segue tag: %ld", (long)((UIButton *)sender).superview.superview.tag);
            LikesAndCommentsCell *cell = (LikesAndCommentsCell *)((UIButton *)sender).superview.superview;
            commentsVC.post = self.posts[cell.tag];
            commentsVC.commentsLabel = cell.commentsLabel;
        }
    }

}
@end