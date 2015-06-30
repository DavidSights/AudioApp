//
//  ProfileViewController.m
//  AudioApp
//
//  Created by Alex Santorineos on 6/15/15.
//  Copyright (c) 2015 DavidSights. All rights reserved.
//

#import "ProfileViewController.h"
#import "LikesTableViewController.h"
#import "CommentTableViewController.h"
#import "ProfileInfoTableViewCell.h"
#import "ProfileMiddleTableViewCell.h"
#import "PostCell.h"
#import "LikesAndCommentsCell.h"
#import "PostHeaderCell.h"
#import "Post.h"
#import "User.h"
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "AudioPlayerWithTag.h"
//#import <AVFoundation/AVFoundation.h>


@interface ProfileViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, ProfileMiddleTableViewCellDelegate, LikesAndCommentsCellDelegate, AVAudioPlayerDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate>
@property UIImage *image;
@property UIImagePickerController *imagePicker;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *settingsButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property UISegmentedControl *postLikesController;
@property (nonatomic)  NSArray *likedPosts;
@property (nonatomic)  NSArray *userPosts;
@property AudioPlayerWithTag *player;
@property NSIndexPath *indexPath;
@property CGFloat lastOffsetY;
@property NSTimer *timer;
@property int integer;
@property (weak, nonatomic) IBOutlet UIButton *profilePicButton;
@property NSIndexPath *indexPath2;

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

    if (self.postLikesController == 0) {
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        refreshControl.backgroundColor = [UIColor purpleColor];
        refreshControl.tintColor = [UIColor whiteColor];

        [refreshControl addTarget:self action:@selector(queryUserPost:) forControlEvents:UIControlEventValueChanged];
        [self.tableView addSubview:refreshControl];
    } else {
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        refreshControl.backgroundColor = [UIColor purpleColor];
        refreshControl.tintColor = [UIColor whiteColor];
        [refreshControl addTarget:self action:@selector(queryLike:) forControlEvents:UIControlEventValueChanged];
        [self.tableView addSubview:refreshControl];
    }
    self.settingsButton.title = @"Settings";
}

- (void) viewDidDisappear:(BOOL)animated{
    [self.player stop];
}


- (void)viewDidAppear:(BOOL)animated {

    if (self.postLikesController == 0) {
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        refreshControl.backgroundColor = [UIColor purpleColor];
        refreshControl.tintColor = [UIColor whiteColor];
        [refreshControl addTarget:self action:@selector(queryUserPost:) forControlEvents:UIControlEventValueChanged];
        [self.tableView addSubview:refreshControl];
    } else {
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        refreshControl.backgroundColor = [UIColor purpleColor];
        refreshControl.tintColor = [UIColor whiteColor];
        [refreshControl addTarget:self action:@selector(queryLike:) forControlEvents:UIControlEventValueChanged];
        [self.tableView addSubview:refreshControl];
    }

    if (![PFUser currentUser]) {
        [self.tabBarController setSelectedIndex:0];
    }

    if (self.user == nil) {
        self.user = [PFUser currentUser];
    }

    [self queryUserPosts];
}

- (void)viewWillAppear:(BOOL)animated{

    if (self.postLikesController == 0) {
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        refreshControl.backgroundColor = [UIColor purpleColor];
        refreshControl.tintColor = [UIColor whiteColor];
        [refreshControl addTarget:self action:@selector(queryUserPost:) forControlEvents:UIControlEventValueChanged];
        [self.tableView addSubview:refreshControl];
    } else {
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        refreshControl.backgroundColor = [UIColor purpleColor];
        refreshControl.tintColor = [UIColor whiteColor];
        [refreshControl addTarget:self action:@selector(queryLike:) forControlEvents:UIControlEventValueChanged];
        [self.tableView addSubview:refreshControl];
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        // If the notification is touched stop spinning. If is not touched start spinning.
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receiveNotification:) name:@"TestProfilePic" object:nil];
    }
    return self;
}

#pragma mark - Setters

- (void)setUserPosts:(NSArray *)userPosts {
    _userPosts = userPosts;
    [self.tableView reloadData];
}

- (void)setLikedPosts:(NSArray *)likedPosts {
    _likedPosts = likedPosts;
    [self.tableView reloadData];
    NSLog(@"Updated likedPosts.");
}

#pragma mark - Parse

- (void)queryUserPost:(UIRefreshControl *)refresher {
    [self queryUserPosts];
    [refresher endRefreshing];
}

- (void)queryLike:(UIRefreshControl *)refresher {
    [self queryLikedPosts];
    [refresher endRefreshing];
}

- (void)queryUserPosts {
    [Post queryPostsWithUser:self.user withCompletion:^(NSArray *posts, NSError *error) {
        if (!error) {
            self.userPosts = posts;
        }
    }];
}

- (void)queryLikedPosts {
    [Post queryActivityWithUser:self.user forLikedPostsWithCompletion:^(NSArray *posts, NSError *error) {
        if (!error) {
            self.likedPosts = posts;
        }
    }];
}

- (void)queryUserProfilePic{
    ProfileInfoTableViewCell *cell = [self.tableView cellForRowAtIndexPath:self.indexPath2];
    PFFile *file = self.user[@"profileImage"];
    NSData *data = [file getData];
    UIImage *image = [UIImage imageWithData:data];
    //cell.imageView.image = image;
    cell.profileImagevIEW.image = image;
}

- (void)uploadToParse {
    NSData *fileData;
    NSString *fileName;

    if (self.image != nil) {
        // UIImage *newImage =self.image;
        // self.nImage = [SettingsViewController imageWithImage:self.image scaledToSize:CGSizeMake(15, 15)];
        fileData = UIImageJPEGRepresentation(self.image, 0.5);
        fileName = @"profileImage.jpg";
    }

    PFFile *file = [PFFile fileWithName:fileName data:fileData];
    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"An error occurred!" message:@"Please try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        } else {
            PFUser *user = [PFUser currentUser];
            [user setObject:file forKey:@"profileImage"];
            [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"An error occurred!"
                                                                        message:@"Please try again."
                                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alertView show];
                } else {
                    // Everything was successful!
                    self.imagePicker = nil;
                }
            }];
        }
        // don't touch!!!! - please let us know why
        [[NSNotificationCenter defaultCenter]postNotificationName:@"TestProfilePic" object:self];
    }];
}

#pragma mark - NSNotification

- (void)receiveNotification:(NSNotification *)notification {
    if ([notification.name isEqualToString:@"TestProfilePic"]) {
        [self queryUserProfilePic];
    }
}

#pragma mark - User Interaction

-(void)didTapLikeButton:(UIButton *)button {
    LikesAndCommentsCell *cell = (LikesAndCommentsCell *)button.superview.superview;
    PFUser *currentUser = [PFUser currentUser];
    Post *post;
    if (self.postLikesController.selectedSegmentIndex == 0) {
        post = self.userPosts[cell.tag];
    } else {
        post = self.likedPosts[cell.tag];
    }
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
                NSLog(@"button enabled");
                
                button.enabled = YES;
            }
        }];
    }
}

-(void)didTapAddCommentButton:(UIButton *)button {

    NSLog(@"Comment button tapped");

    [self performSegueWithIdentifier:@"CommentSegue" sender:button];
}

-(void)middleCellButtonTapped:(UIButton *)button {

    button.enabled = NO;

    if ([button.titleLabel.text isEqualToString:@"Unfollow"]) {

        PFObject *followActivity = currentUserFollowDictionary[self.user.objectId];

        NSLog(@"Follow activity to unfollow: %@", followActivity);

        button.enabled = YES;
    } else if ([button.titleLabel.text isEqualToString:@"Follow"]) {

        PFObject *newFollowActivity = [PFObject objectWithClassName:@"Activity"];
        newFollowActivity[@"type"] = @"Follow";
        newFollowActivity[@"fromUser"] = [PFUser currentUser];
        newFollowActivity[@"toUser"] = self.user;

        [newFollowActivity saveInBackgroundWithBlock:^(BOOL completed, NSError *error) {

            if (completed && !error) {

                NSMutableDictionary *followDictionaryMutable = [currentUserFollowDictionary mutableCopy];
                [followDictionaryMutable setObject:newFollowActivity forKey:[newFollowActivity[@"toUser"] objectId]];
                currentUserFollowDictionary = followDictionaryMutable;

                NSMutableArray *friendsMutable = [currentUserFriends mutableCopy];
                [friendsMutable addObject:newFollowActivity[@"toUser"]];
                currentUserFriends = friendsMutable;
                
                [button setTitle:@"Unfollow" forState:UIControlStateNormal];
                button.enabled = YES;
            } else {

                button.enabled = YES;
            }
        }];
    }
}

-(void)segmentedControlChanged:(UISegmentedControl *)segmentedControl {

    NSLog(@"Segmented control changed");

    if (segmentedControl.selectedSegmentIndex == 0) {

        if (self.userPosts == nil) {

            [self queryUserPosts];
        } else {

            self.player = nil;
            UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
            refreshControl.backgroundColor = [UIColor purpleColor];
            refreshControl.tintColor = [UIColor whiteColor];
            
            [refreshControl addTarget:self
                               action:@selector(queryUserPost:)
                     forControlEvents:UIControlEventValueChanged];
            [self.tableView addSubview:refreshControl];

            [self.tableView reloadData];
        }
    } else {

        if (self.likedPosts == nil) {

            [self queryLikedPosts];
        } else {

            self.player = nil;
            UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
            refreshControl.backgroundColor = [UIColor purpleColor];
            refreshControl.tintColor = [UIColor whiteColor];
            
            [refreshControl addTarget:self
                               action:@selector(queryLike:)
                     forControlEvents:UIControlEventValueChanged];
            [self.tableView addSubview:refreshControl];

            [self.tableView reloadData];
        }
    }
}

- (void)tappedImageView{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Add Profile Picture" message:@"Do you want to take a picture or upload a picture?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Upload", @"Take Picture", nil];

    [alert show];

}

- (void)tappedImageView:(UITapGestureRecognizer *)sender{

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Add Profile Picture" message:@"Do you want to take a picture or upload a picture?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Upload", @"Take Picture", nil];
    //
    [alert show];
}

- (IBAction)onDeleteTapped:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"delete" message:nil preferredStyle:UIAlertControllerStyleAlert];

    //cancels alert controller
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    //
    //saves what you wrote
    UIAlertAction *deleteAction =  [UIAlertAction actionWithTitle:@"DELETE FOREVER!!!" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

        //        self.uploadPhoto = [[UploadPhoto alloc]init];

        //        [self.selectedPhotos deleteInBackground];

        NSIndexPath *indexPath = self.tableView.indexPathsForSelectedRows[0];
        Post *post = self.userPosts[indexPath.section - 1];
        [post deleteInBackground];
        [self queryUserPosts];

    }];

    // add cancelAction variable to alertController
    [alertController addAction:cancelAction];
    [alertController addAction:deleteAction];

    // activates alertcontroler
    [self presentViewController:alertController animated:true completion:nil];
}

- (IBAction)onProfilePicButtonTapped:(UIButton *)sender {
    //    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Add Profile Picture" message:@"Do you want to take a picture or upload a picture?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Upload", @"Take Picture", nil];
    //
    //    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self uploadFromPhotoAlbum];
    } else if (buttonIndex == 2) {
        [self uploadFromCamera];
    }
}

-(void)likesLabelTapped:(UITapGestureRecognizer *)sender {

    NSLog(@"Likes label tapped");

    [self performSegueWithIdentifier:@"LikeSegue" sender:sender];
}

-(void)commentsLabelTapped:(UITapGestureRecognizer *)sender {

    NSLog(@"Comments label tapped");

    [self performSegueWithIdentifier:@"CommentSegue" sender:sender];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.indexPath = indexPath;

    if (indexPath.section != 0) {

        if (indexPath.row == 0) { // Only respond to audio display cell.

            if (self.player.tag == indexPath.section - 1) { // Check if user is trying to play the same audio again.
                if (self.player.playing) {
                    [self.player pause];
                } else if (self.player.tag == 0) { // Audio tag is automatically set to 0, so the first post requires special attention.
                    if (self.player.playing) {
                        [self.player pause];
                    }
                    Post *post;
                    if (self.postLikesController.selectedSegmentIndex == 0) {

                        post = self.userPosts[indexPath.section - 1];
                    } else {

                        post = self.likedPosts[indexPath.section - 1];
                    }
                    NSData *data = [post[@"audio"] getData];// Get audio from specific post in Parse - Can we avoid this query?

                    //do NOT DELETE CODE BELOW;
                    AVAudioSession *session = [AVAudioSession sharedInstance];
                    NSError *setCategoryError = nil;
                    if (![session setCategory:AVAudioSessionCategoryPlayback
                                  withOptions:AVAudioSessionCategoryOptionMixWithOthers
                                        error:&setCategoryError]) {
                        NSLog(@"%@)))))))))", setCategoryError);
                    }

                    self.player = [[AudioPlayerWithTag alloc] initWithData:data error:nil];
                    [self playRecordedAudio];

                } else if (!self.player.playing) {
                    [self.player play];
                }
            } else { // A new post was tapped - stop whatever audio the player is playing, load up the new audio, and play it.
                [self.player stop];
                Post *post;
                if (self.postLikesController.selectedSegmentIndex == 0) {

                    post = self.userPosts[indexPath.section - 1];
                } else {

                    post = self.likedPosts[indexPath.section - 1];
                }
                NSData *data = [post[@"audio"] getData]; // Get audio from specific post in Parse - Can we avoid this query?

                //do NOT DELETE CODE BELOW;
                AVAudioSession *session = [AVAudioSession sharedInstance];
                NSError *setCategoryError = nil;
                if (![session setCategory:AVAudioSessionCategoryPlayback
                              withOptions:AVAudioSessionCategoryOptionMixWithOthers
                                    error:&setCategoryError]) {
                    NSLog(@"%@)))))))))", setCategoryError);
                }

                self.player = [[AudioPlayerWithTag alloc] initWithData:data error:nil];
                self.player.tag = (int)indexPath.section - 1;
                self.integer = 0;
                
                [self playRecordedAudio];
            }
        }
    }
}

#pragma mark - TableView Data Source

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

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    if (self.postLikesController.selectedSegmentIndex == 0) {

        NSLog(@"Segmented index is 0. Returning %lu + 1", (unsigned long)self.userPosts.count);
        return self.userPosts.count + 1;
    } else {

        NSLog(@"Segmented index is 1. Returning %lu + 1", (unsigned long)self.likedPosts.count);
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
        if (self.postLikesController.selectedSegmentIndex == 0) {

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
            self.indexPath2 = indexPath;

            ProfileInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProfileCell"];
            cell.usernameLabel.text = self.user.username;
            PFUser *currentUser = [PFUser currentUser];
            PFFile *file = self.user[@"profileImage"];
            NSData *data = [file getData];
            UIImage *image = [UIImage imageWithData:data];

            cell.profileImagevIEW.image = image;

            UITapGestureRecognizer *imageview = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedImageView:)];
            [cell.profileImagevIEW addGestureRecognizer:imageview];

            return cell;
        } else if (indexPath.row == 1) {
            ProfileMiddleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MiddleCell"];
            cell.delegate = self;
            self.postLikesController = cell.profileSegmentedControl;

            if ([self.user isEqual:[PFUser currentUser]]) {

                [cell.cellButton setTitle:@"Edit Profile" forState:UIControlStateNormal];
            } else {

                if (currentUserFollowDictionary[self.user.objectId]) {

                    [cell.cellButton setTitle:@"Unfollow" forState:UIControlStateNormal];
                } else {

                    [cell.cellButton setTitle:@"Follow" forState:UIControlStateNormal];
                }
            }
            return cell;
        }
    } else {
        if (indexPath.row == 0) {

            PostCell* postCell = [tableView dequeueReusableCellWithIdentifier:@"PostCell"];
            CGRect cellRect = [tableView rectForRowAtIndexPath:indexPath];

            postCell.coloredView.frame = cellRect;
            postCell.layoutMargins = UIEdgeInsetsZero;
            postCell.preservesSuperviewLayoutMargins = NO;
            postCell.timerLabel.text = @"0";

            Post *post;
            if (self.postLikesController.selectedSegmentIndex == 0) {

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
            if (self.postLikesController.selectedSegmentIndex == 0) {

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

// Deals with color for post cells
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

// Deals with color for post cells
- (CGFloat)colorComponentFrom: (NSString *) string start: (NSUInteger) start length: (NSUInteger) length {
    NSString *substring = [string substringWithRange: NSMakeRange(start, length)];
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat: @"%@%@", substring, substring];
    unsigned hexComponent;
    [[NSScanner scannerWithString: fullHex] scanHexInt: &hexComponent];
    return hexComponent / 255.0;
}

#pragma mark - Manage Audio

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

#pragma mark - Manage Profile Picture

- (void)uploadFromPhotoAlbum {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)uploadFromCamera {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    self.image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self uploadToParse];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Navigation Bar Scroll Customization

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

#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"LikeSegue"]) {
        LikesTableViewController *likesVC = segue.destinationViewController;
        Post *post;

        if (self.postLikesController.selectedSegmentIndex == 0) {
            post = self.userPosts[((UITapGestureRecognizer *)sender).view.tag];
        } else {
            post = self.likedPosts[((UITapGestureRecognizer *)sender).view.tag];
        }

        likesVC.post = post;
        likesVC.likesLabel = (UILabel *)((UITapGestureRecognizer *)sender).view;

    } else if ([segue.identifier isEqualToString:@"CommentSegue"]) {

        if ([sender isKindOfClass:[UITapGestureRecognizer class]]) {
            CommentTableViewController *commentsVC = segue.destinationViewController;
            Post *post;

            if (self.postLikesController.selectedSegmentIndex == 0) {
                post = self.userPosts[((UITapGestureRecognizer *)sender).view.tag];
            } else {
                post = self.likedPosts[((UITapGestureRecognizer *)sender).view.tag];
            }

            commentsVC.post = post;
            commentsVC.commentsLabel = (UILabel *)((UITapGestureRecognizer *)sender).view;
        } else {
            CommentTableViewController *commentsVC = segue.destinationViewController;
            LikesAndCommentsCell *cell = (LikesAndCommentsCell *)((UIButton *)sender).superview.superview;
            Post *post;
            NSLog(@"Cell tag: %ld", (long)cell.tag);

            if (self.postLikesController.selectedSegmentIndex == 0) {
                post = self.userPosts[cell.tag];
            } else {
                post = self.likedPosts[cell.tag];
            }

            commentsVC.post = post;
            commentsVC.commentsLabel = cell.commentsLabel;
        }
    }
}

@end
