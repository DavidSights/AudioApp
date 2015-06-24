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
#import "Comment.h"
#import "AudioPlayerWithTag.h"



@interface FeedViewController () <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, AVAudioPlayerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSArray *posts;
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
        [self queryFromParse];
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
//    NSLog(@"Comment count: %d", commentCount);

    if (commentCount < 5) {
//        NSLog(@"Comment count less than 5");

        return commentCount + 2;
    } else {
        return 8;
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
    if (indexPath.row == 0) {
      PostImageTableViewCell* postImageTableViewCell = [tableView dequeueReusableCellWithIdentifier:@"imageCell"];
//        [cell.coloredView sizeToFit];
        CGRect cellRect = [tableView rectForRowAtIndexPath:indexPath];
       postImageTableViewCell.coloredView.frame = cellRect;
       postImageTableViewCell.layoutMargins = UIEdgeInsetsZero;
       postImageTableViewCell.preservesSuperviewLayoutMargins = NO;
        Post *post = self.posts[indexPath.section];
        if (post.colorHex !=nil) {
            NSString *string = post.colorHex;
            postImageTableViewCell.backgroundColor = [self colorWithHexString:string];
        }else{
            postImageTableViewCell.backgroundColor = [UIColor yellowColor];

        }
        return postImageTableViewCell;
    } else if (indexPath.row == 1) {
        LabelsAndButtonsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"labelsAndButtonsCell"];
        cell.likesButton.tag = indexPath.section;
        Post *post = self.posts[indexPath.section];
        cell.likesLabel.text = [NSString stringWithFormat:@"%lu Likes", (unsigned long)post.likes.count];
        return cell;
    } else {
        CommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commentCell"];
        Post *post = self.posts[indexPath.section];
        Comment *comment = post.comments[0];
//        NSLog(@"%@", comment.text);
        cell.commentLabel.text = comment.text;
        return cell;
    }
}

#pragma mark - Audio

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.indexPath = indexPath;

    if (indexPath.row == 0) { // Only respond to audio display cell.
        if (self.player.tag == indexPath.section) { // Check if user is trying to play the same audio again.
            if (self.player.playing) {
                [self.player pause];
            } else if (self.player.tag == 0) { // Audio tag is automatically set to 0, so the first post requires special attention.
                if (self.player.playing) {
                    [self.player pause];
                }
                Post *post = self.posts[indexPath.section];
                NSData *data = [post.audioFile getData]; // Get audio from specific post in Parse - Can we avoid this query?
                self.player = [[AudioPlayerWithTag alloc] initWithData:data error:nil];
                [self playRecordedAudio];
            } else if (!self.player.playing) {
                [self.player play];
            }
        } else { // A new post was tapped - stop whatever audio the player is playing, load up the new audio, and play it.
            [self.player stop];
            Post *post = self.posts[indexPath.section];
            NSData *data = [post.audioFile getData]; // Get audio from specific post in Parse - Can we avoid this query?
            self.player = [[AudioPlayerWithTag alloc] initWithData:data error:nil];
            self.player.tag = (int)indexPath.section;
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
    PostImageTableViewCell* postImageTableViewCell = (PostImageTableViewCell *)[self.tableView cellForRowAtIndexPath:self.tableView.indexPathForSelectedRow];
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

//            [self.player play];

            self.integer = self.integer +1;

            NSLog(@"%d_______",self.integer);
            
        }
        
        
        
        
    }

    }






#pragma mark - Parse

- (void)queryFromParse {
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {

        if (error) {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        } else {
            NSMutableArray *postsMutable = [NSMutableArray new];
            for (PFObject *object in objects) {
                Post *post = [[Post alloc] initWithPFObject:object];
                [Post queryCommentsAndLikesWithPost:object andCompletion:^(NSArray *comments, NSArray *likes) {
                    post.comments = comments;
                    post.likes = likes;
                    [self.tableView reloadData];
                }];
                [postsMutable addObject:post];
            }
            self.posts = postsMutable;
            [self.tableView reloadData];
        }
    }];
}

#pragma mark - Update Information

- (void)viewWillAppear:(BOOL)animated {
    PFUser *currentUser = [PFUser currentUser]; //show current user in console
    if (currentUser) {
        [self queryFromParse];
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

- (IBAction)onLikesButtonTapped:(UIButton *)sender {

//    PFQuery *query = [PFQuery queryWithClassName:@"Like"];
//    [query whereKey:@"post" equalTo:[self.posts objectAtIndex:sender.tag]];
//    [query findObjectsInBackgroundWithBlock:^(NSArray *likes, NSError *error) {
//        if (likes.count != 0) {
//            PFObject *like = [likes firstObject];
//            if (like[@"user"] == [PFUser currentUser]) {
//                [like deleteInBackgroundWithBlock:^(BOOL completed, NSError *error) {
//                    if (completed) {
//                        NSLog(@"Like deleted.");
//                        [self.tableView reloadData];
//                    } else {
//                        NSLog(@"There was an error deleting the like: %@", error.localizedDescription);
//                    }
//                }];
//            }
//        } else {
//            PFObject *like = [PFObject objectWithClassName:@"Like"];
//            like[@"user"] = [PFUser currentUser];
//            like[@"post"] = self.posts[sender.tag];
//            [like saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
//                if (succeeded) {
//                    NSLog(@"Like saved.");
//                    [self.tableView reloadData];
//                } else {
//                    NSLog(@"Error saving like: %@", error.localizedDescription);
//                }
//            }];
//        }
//    }];

    LabelsAndButtonsTableViewCell *cell = (LabelsAndButtonsTableViewCell *)sender.superview.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];

    Post *post = self.posts[sender.tag];
    BOOL shouldCreateLikeObject = YES;

    for (Like *like in post.likes) {

        PFUser *user = like.user;

        if (user == [PFUser currentUser]) {

            shouldCreateLikeObject = NO;
            [like.likeObject deleteEventually];
            NSMutableArray *tempArray = [post.likes mutableCopy];
            [tempArray removeObject:like];
            post.likes = tempArray;

            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
    if (shouldCreateLikeObject) {

        PFObject *likeObject = [PFObject objectWithClassName:@"Like"];
        likeObject[@"user"] = [PFUser currentUser];
        likeObject[@"post"] = post.postObject;
        [likeObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {

            if (succeeded) {
                NSLog(@"Like object saved");
                Like *like = [[Like alloc] initWithLikeObject:likeObject];
                NSMutableArray *tempArray = [post.likes mutableCopy];
                [tempArray addObject:like];
                post.likes = tempArray;

                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];

            } else {
                NSLog(@"Error saving like: %@", error.localizedDescription);
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



-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error{
    NSLog(@"%@",error);


}
@end