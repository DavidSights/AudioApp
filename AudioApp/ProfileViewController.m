//
//  ProfileViewController.m
//  AudioApp
//
//  Created by Alex Santorineos on 6/15/15.
//  Copyright (c) 2015 DavidSights. All rights reserved.
//

#import "ProfileViewController.h"
#import "PostCell.h"
#import "LikesAndCommentsCell.h"
#import "PostHeaderCell.h"
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "Post.h"
#import "AudioPlayerWithTag.h"
//#import <AVFoundation/AVFoundation.h>


@interface ProfileViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *aboutLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSArray *userPosts;
@property AudioPlayerWithTag *player;
@property CGFloat lastOffsetY;
@property int integer;
@property NSIndexPath *indexPath;
@end

//static const CGFloat kNavBarHeight = 52.0f;
//static const CGFloat kLabelHeight = 14.0f;
//static const CGFloat kMargin = 10.0f;
//static const CGFloat kSpacer = 2.0f;
//static const CGFloat kLabelFontSize = 12.0f;
//static const CGFloat kAddressHeight = 24.0f;

@implementation ProfileViewController

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

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        //if the notification is touched stop spinng. if is not touched start spinning
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receiveNotification:) name:@"Test2" object:nil];
    }
    return self;
}

- (void)receiveNotification:(NSNotification *)notification {
    if ([notification.name isEqualToString:@"Test2"]) {
//        PFUser *user = [PFUser currentUser];
//        self.usernameLabel.text = user.username;
//        self.aboutLabel.text = user[@"about"];
        [self.tableView reloadData];
    }
}

-(void)viewDidAppear:(BOOL)animated {

    [self.tableView reloadData];

    NSLog(@"%@--------------",[PFUser currentUser].username);
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser != nil) {
        PFUser *currentUser = [PFUser currentUser];

        self.usernameLabel.text = currentUser.username;
        self.aboutLabel.text = currentUser[@"about"];


    } else {
        [self.tabBarController setSelectedIndex:0];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [self.tableView reloadData];
}

- (void)queryFromParse {
    PFQuery* query = [PFQuery queryWithClassName:@"Post"];
    [query whereKey:@"author" equalTo:[PFUser currentUser]];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        } else {
            self.userPosts = objects;
            NSLog(@"%lu", (unsigned long)self.userPosts.count);;
            [self.tableView reloadData];
        }
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
//        [commentsQuery whereKey:@"post" equalTo:post];
//            [commentsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//                NSArray *comments = objects;
//                if (!comments.count == 0) {
//                   numberOfComments = (int)comments.count;
//                }
//            }];

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

        if (indexPath.row == 2) {

            PostCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PostCell"];
            //        [cell.coloredView sizeToFit];
//            CGRect cellRect = [tableView rectForRowAtIndexPath:indexPath];
//            cell.coloredView.frame = cellRect;
            Post *post = self.userPosts[indexPath.section];

            if (post[@"colorHex"] != nil) {
                NSString *string = post[@"colorHex"];
                cell.backgroundColor = [self colorWithHexString:string];
            }else{
                cell.backgroundColor = [UIColor yellowColor];
            }
            
            return cell;

            cell.layoutMargins = UIEdgeInsetsZero;
            cell.preservesSuperviewLayoutMargins = NO;
            NSLog(@"%f, %f", cell.center.x, cell.center.y);
//            cell.backgroundColor = [UIColor yellowColor];
            return cell;
        } else if (indexPath.row == 1) {

            LikesAndCommentsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LikeCell"];
//            PFQuery *likesQuery = [PFQuery queryWithClassName:@"Like"];
//            [likesQuery whereKey:@"Post" equalTo:self.userPosts[indexPath.section]];
//            NSArray *likes = [likesQuery findObjects];
//            cell.likesLabel.text = [NSString stringWithFormat:@"%lu Likes", (unsigned long)likes.count];
            return cell;
        } else {

            PostHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommentCell"];
            return cell;
        }   
    }

    return cell;
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

@end
