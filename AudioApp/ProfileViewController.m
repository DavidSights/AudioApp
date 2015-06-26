//
//  ProfileViewController.m
//  AudioApp
//
//  Created by Alex Santorineos on 6/15/15.
//  Copyright (c) 2015 DavidSights. All rights reserved.
//

#import "ProfileViewController.h"
#import "ProfileInfoTableViewCell.h"
#import "ProfileMiddleTableViewCell.h"
#import "PostCell.h"
#import "LikesAndCommentsCell.h"
#import "PostHeaderCell.h"
#import "Post.h"
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "Post.h"
#import "AudioPlayerWithTag.h"
//#import <AVFoundation/AVFoundation.h>


@interface ProfileViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, ProfileMiddleTableViewCellDelegate, LikesAndCommentsCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic)  NSArray *userPosts;
@property (nonatomic)  NSArray *likedPosts;

@property CGFloat lastOffsetY;
@property UISegmentedControl *userPostsOrLikes;
@property PFUser *user;

@property AudioPlayerWithTag *player;
@property int integer;
@property NSIndexPath *indexPath;
@end

static const CGFloat kNavBarHeight = 52.0f;
static const CGFloat kLabelHeight = 14.0f;
static const CGFloat kMargin = 10.0f;
static const CGFloat kSpacer = 2.0f;
static const CGFloat kLabelFontSize = 12.0f;
static const CGFloat kAddressHeight = 24.0f;

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set up profile details.
    self.user = [PFUser currentUser];

    [self queryUserPosts];
}

-(void)queryUserPosts {

    [Post queryPostsWithUser:self.user withCompletion:^(NSArray *posts, NSError *error) {

        if (!error) {

            self.userPosts = posts;

            NSLog(@"Posts: %@", posts);
        }
    }];
}

-(void)queryLikedPosts {

    NSLog(@"Liked posts empty");
    [Post queryActivityWithUser:self.user forLikedPostsWithCompletion:^(NSArray *posts, NSError *error) {

        if (!error) {

            NSLog(@"Liked Posts: %@", posts);
            self.likedPosts = posts;
        }
    }];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        //if the notification is touched stop spinng. if is not touched start spinning
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receiveNotification:) name:@"Test2" object:nil];
    }
    return self;
}

-(void)setUserPosts:(NSArray *)userPosts {

    _userPosts = userPosts;
    [self.tableView reloadData];
}

-(void)setLikedPosts:(NSArray *)likedPosts {

    NSLog(@"liked posts changed");

    _likedPosts = likedPosts;
    [self.tableView reloadData];
}

- (void)receiveNotification:(NSNotification *)notification {
    if ([notification.name isEqualToString:@"Test2"]) {
//        PFUser *user = [PFUser currentUser];
//        self.usernameLabel.text = user.username;
//        self.aboutLabel.text = user[@"about"];
//        [self.tableView reloadData];
    }
}

-(void)viewDidAppear:(BOOL)animated {

//    [self.tableView reloadData];

    NSLog(@"%@--------------",[PFUser currentUser].username);
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser != nil) {


    } else {
        [self.tabBarController setSelectedIndex:0];
    }
}

-(void)viewWillAppear:(BOOL)animated{

//    [self.tableView reloadData];
}

-(void)didTapLikeButton:(UIButton *)button {


}

-(void)segmentedControlChanged:(UISegmentedControl *)segmentedControl {

    NSLog(@"Segmented control changed");

    if (segmentedControl.selectedSegmentIndex == 0) {

        if (self.userPosts == nil) {

            [self queryUserPosts];
        } else {

            [self.tableView reloadData];
        }
    } else {

        if (self.likedPosts == nil) {

            [self queryLikedPosts];
        } else {

            [self.tableView reloadData];
        }
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    if (self.userPostsOrLikes.selectedSegmentIndex == 0) {

        NSLog(@"Segmented index is 0. Returning %d + 1", self.userPosts.count);
        return self.userPosts.count + 1;
    } else {

        NSLog(@"Segmented index is 1. Returning %d + 1", self.likedPosts.count);
        return self.likedPosts.count + 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (section == 0) {

        return 2;
    } else {

        return 2;
    }

    return 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {

    if (section == 0) {
        return 0;
    }
    return 50.0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    PostHeaderCell *cell = nil;
    cell.alpha = 0;

    if (section != 0) {

        cell.alpha = 1;
        cell = [tableView dequeueReusableCellWithIdentifier:@"HeaderCell"];

        Post *post;
        if (self.userPostsOrLikes.selectedSegmentIndex == 0) {

            post = self.userPosts[section - 1];
        } else {

            post = self.likedPosts[section - 1];
        }

        PFUser *user = post[@"author"];
//        NSLog(@"User: %@", user.username);
        NSString *displayNameText;
        displayNameText = user[@"displayName"];
//        NSLog(@"Display Name: %@", displayNameText);

        displayNameText = user.username;
        cell.displayNameLabel.text = displayNameText;
        [cell.displayNameLabel sizeToFit];
        cell.backgroundColor = [UIColor whiteColor];
    }

    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == 0) {

        if (indexPath.row == 0) {

            ProfileInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProfileCell"];

            return cell;
        } else if (indexPath.row == 1) {
            ProfileMiddleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MiddleCell"];
            cell.delegate = self;
            self.userPostsOrLikes = cell.profileSegmentedControl;

            return cell;
        }
    } else {

        if (indexPath.row == 0) {

            PostCell* postCell = [tableView dequeueReusableCellWithIdentifier:@"PostCell"];
            CGRect cellRect = [tableView rectForRowAtIndexPath:indexPath];

            postCell.coloredView.frame = cellRect;
            postCell.layoutMargins = UIEdgeInsetsZero;
            postCell.preservesSuperviewLayoutMargins = NO;

            Post *post;
            if (self.userPostsOrLikes.selectedSegmentIndex == 0) {

                post = self.userPosts[indexPath.section - 1];
            } else {

                post = self.likedPosts[indexPath.section - 1];
            }

            if (post[@"colorHex"] != nil) {
                NSString *string = post[@"colorHex"];
                postCell.backgroundColor = [self colorWithHexString:string];
            }else{
                postCell.backgroundColor = [UIColor yellowColor];
            }

            return postCell;

        } else {

            LikesAndCommentsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LikesAndCommentsCell"];

            Post *post;
            if (self.userPostsOrLikes.selectedSegmentIndex == 0) {

                post = self.userPosts[indexPath.section - 1];
            } else {

                post = self.likedPosts[indexPath.section - 1];
            }
            cell.likesLabel.text = [NSString stringWithFormat:@"%@ Likes", post[@"numOfLikes"]];
            cell.commentsLabel.text = [NSString stringWithFormat:@"%@ Comments", post[@"numOfComments"]];

            cell.delegate = self;
            cell.tag = indexPath.section - 1;
            cell.backgroundColor = [UIColor whiteColor];

            cell.likesLabel.tag = indexPath.section - 1;
            cell.commentsLabel.tag = indexPath.section - 1;

            UITapGestureRecognizer *likesGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(likesLabelTapped:)];
            UITapGestureRecognizer *commentsGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(commentsLabelTapped:)];

            [cell.likesLabel setUserInteractionEnabled:YES];
            [cell.likesLabel addGestureRecognizer:likesGestureRecognizer];
            [cell.commentsLabel setUserInteractionEnabled:YES];
            [cell.commentsLabel addGestureRecognizer:commentsGestureRecognizer];
            
            return cell;
        }   
    }

    return nil;
}

-(void)likesLabelTapped:(UITapGestureRecognizer *)sender {

    NSLog(@"Likes label tapped");

//    [self performSegueWithIdentifier:@"LikeSegue" sender:sender];
}

-(void)commentsLabelTapped:(UITapGestureRecognizer *)sender {

    NSLog(@"Comments label tapped");

//    [self performSegueWithIdentifier:@"CommentSegue" sender:sender];
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    self.indexPath = indexPath;
//
//    if (indexPath.row == 0) { // Only respond to audio display cell.
//
//        NSLog(@"TAP");
//
//        if (self.player.tag == indexPath.section) { // Check if user is trying to play the same audio again.
//            if (self.player.playing) {
//                [self.player pause];
//            } else if (self.player.tag == 0) { // Audio tag is automatically set to 0, so the first post requires special attention.
//                if (self.player.playing) {
//                    [self.player pause];
//                }
//                Post *post = self.userPosts[indexPath.section];
//                NSData *data = [post[@"audio"] getData]; // Get audio from specific post in Parse - Can we avoid this query?
//                self.player = [[AudioPlayerWithTag alloc] initWithData:data error:nil];
//                [self playRecordedAudio];
//            } else if (!self.player.playing) {
//                [self.player play];
//            }
//        } else { // A new post was tapped - stop whatever audio the player is playing, load up the new audio, and play it.
//            [self.player stop];
//            Post *post = self.userPosts[indexPath.section];
//            NSData *data = [post[@"audio"] getData]; // Get audio from specific post in Parse - Can we avoid this query?
//            self.player = [[AudioPlayerWithTag alloc] initWithData:data error:nil];
//            self.player.tag = (int)indexPath.section;
//            self.integer = 0;
//
//            [self playRecordedAudio];
//        }
//    }
//}

- (void)playRecordedAudio {
    //    self.player.numberOfLoops = -1;
//    self.player.delegate = self;
    [self.player play];


//    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(playingTime) userInfo:nil repeats:YES];
}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    CGRect frame = self.navigationController.navigationBar.frame;
//    CGFloat size = frame.size.height - 21;
//    CGFloat framePercentageHidden = ((20 - frame.origin.y) / (frame.size.height - 1));
//    CGFloat scrollOffset = scrollView.contentOffset.y;
//    CGFloat scrollDiff = scrollOffset - self.lastOffsetY;
//    CGFloat scrollHeight = scrollView.frame.size.height;
//    CGFloat scrollContentSizeHeight = scrollView.contentSize.height + scrollView.contentInset.bottom;
//
//    if (scrollOffset <= -scrollView.contentInset.top) {
//        frame.origin.y = 20;
//    } else if ((scrollOffset + scrollHeight) >= scrollContentSizeHeight) {
//        frame.origin.y = -size;
//    } else {
//        frame.origin.y = MIN(20, MAX(-size, frame.origin.y - scrollDiff));
//
//    }
//
//    [self.navigationController.navigationBar setFrame:frame];
//    [self updateBarButtonItems:(1 - framePercentageHidden)];
//    self.lastOffsetY = scrollOffset;
//}
//
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//
//    [self stoppedScrolling];
//}
//
//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
//                  willDecelerate:(BOOL)decelerate {
//
//    if (!decelerate) {
//        [self stoppedScrolling];
//    }
//}
//
//- (void)stoppedScrolling {
//
//    CGRect frame = self.navigationController.navigationBar.frame;
//    if (frame.origin.y < -5) {
//        [self animateNavBarTo:-(frame.size.height - 21)];
//        //        [self animateWebView:-(frame.size.height - 21)];
//    } else {
//        [self animateNavBarTo:(frame.size.height - 21)];
//        //                [self animateWebView:(frame.size.height - 21)];
//
//    }
//}

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

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0 && indexPath.section == 0) {
        return 200;
    } else if (indexPath.row == 1 && indexPath.section == 0) {
        return 88;
    } else if (indexPath.row == 0 && indexPath.section != 0){
        return self.view.frame.size.width;
    }
    return 50;
}

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
@end
