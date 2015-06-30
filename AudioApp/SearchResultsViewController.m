//
//  SearchResultsViewController.m
//  AudioApp
//
//  Created by Tony Dakhoul on 6/29/15.
//  Copyright (c) 2015 DavidSights. All rights reserved.
//

#import "SearchResultsViewController.h"
#import "LikesTableViewController.h"
#import "CommentTableViewController.h"
#import "PostHeaderCell.h"
#import "PostCell.h"
#import "LikesAndCommentsCell.h"
#import "Post.h"
#import "AudioPlayerWithTag.h"
#import <Parse/Parse.h>

@interface SearchResultsViewController () <UITableViewDataSource, UITableViewDelegate, LikesAndCommentsCellDelegate, AVAudioPlayerDelegate>

@property (nonatomic)  NSArray *searchResults;

@property AudioPlayerWithTag *player;
@property NSTimer *timer;
@property NSInteger *integer;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *searchSegmentedControl;

@end

@implementation SearchResultsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.searchBar.delegate = self;
}

-(void)setSearchResults:(NSArray *)searchResults {

    _searchResults = searchResults;
    [self.tableView reloadData];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    if (self.searchSegmentedControl.selectedSegmentIndex == 0) {
        return 1;
    } else {

        return self.searchResults.count;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (self.searchSegmentedControl.selectedSegmentIndex == 0) {
        return self.searchResults.count;
    } else {

        return 2;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {

    if (self.searchSegmentedControl.selectedSegmentIndex == 1) {
        return 50;
    }
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    if (self.searchSegmentedControl.selectedSegmentIndex == 1) {

        PostHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HeaderCell"];

        Post *post = self.searchResults[section];
        PFUser *user = post[@"author"];
        NSLog(@"User: %@", user.username);
        NSString *displayNameText = user.username;
        NSLog(@"Display Name: %@", displayNameText);
        cell.displayNameLabel.text = displayNameText;
        [cell.displayNameLabel sizeToFit];
        cell.backgroundColor = [UIColor whiteColor];

        return cell;
    }

    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (self.searchSegmentedControl.selectedSegmentIndex == 1) {

        if (indexPath.row == 0) { // First cell should display the audio view.
            return self.view.frame.size.width; // Height for audio view.
            //        return [UIScreen mainScreen].bounds.size.width;
        }
    }

    return  50;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {


    if (self.searchSegmentedControl.selectedSegmentIndex == 0) {

        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell"];

        PFUser *user = self.searchResults[indexPath.row];

        cell.textLabel.text = user.username;
        cell.detailTextLabel.text = user[@"displayName"];

        return cell;
    } else {

        if (indexPath.row == 0) {

            PostCell* postCell = [tableView dequeueReusableCellWithIdentifier:@"PostCell"];
            CGRect cellRect = [tableView rectForRowAtIndexPath:indexPath];
            postCell.timerLabel.text = @"0";

            postCell.coloredView.frame = cellRect;
            postCell.layoutMargins = UIEdgeInsetsZero;
            postCell.preservesSuperviewLayoutMargins = NO;

            Post *post = self.searchResults[indexPath.section];

            if (post[@"colorHex"] != nil) {
                NSString *string = post[@"colorHex"];
                postCell.backgroundColor = [self colorWithHexString:string];
            }else{
                postCell.backgroundColor = [UIColor yellowColor];
            }
            
            return postCell;
        } else {

            LikesAndCommentsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LikesAndCommentsCell"];

            Post *post = self.searchResults[indexPath.section];
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

            if ([PFUser currentUser] == post[@"author"]) {
                cell.deleteButton.alpha = 1;
            } else {
                cell.deleteButton.alpha = 0;
            }

            return cell;
        }
    }

    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    self.indexPath = indexPath;

    if (self.searchSegmentedControl.selectedSegmentIndex == 1) {
        
        if (indexPath.row == 0) { // Only respond to audio display cell.

            NSLog(@"TAP");

            if (self.player.tag == indexPath.section) { // Check if user is trying to play the same audio again.
                if (self.player.playing) {
                    [self.player pause];
                } else if (self.player.tag == 0) { // Audio tag is automatically set to 0, so the first post requires special attention.
                    if (self.player.playing) {
                        [self.player pause];
                    }
                    Post *post = self.searchResults[indexPath.section];
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
                Post *post = self.searchResults[indexPath.section];
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
                self.player.tag = (int)indexPath.section;
                self.integer = 0;
                
                [self playRecordedAudio];
            }
        }
    }
}

-(void)didTapLikeButton:(UIButton *)button {

    NSLog(@"Tapped");

    LikesAndCommentsCell *cell = (LikesAndCommentsCell *)button.superview.superview;

    PFUser *currentUser = [PFUser currentUser];
    Post *post = self.searchResults[cell.tag];
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
            
            NSLog(@"%i_______",self.integer);
        }
    }
}

-(void)likesLabelTapped:(UITapGestureRecognizer *)sender {

    Post *post = self.searchResults[((UITapGestureRecognizer *)sender).view.tag];
    UILabel *likesLabel = (UILabel *)((UITapGestureRecognizer *)sender).view;

    [self.delegate onLikesLabelTapped:likesLabel andPost:post];
}

-(void)commentsLabelTapped:(UITapGestureRecognizer *)sender {

    Post *post = self.searchResults[((UITapGestureRecognizer *)sender).view.tag];
    UILabel *commentsLabel = (UILabel *)((UITapGestureRecognizer *)sender).view;


    [self.delegate onCommentsLabelTapped:commentsLabel andPost:post];
}

-(void)didTapAddCommentButton:(UIButton *)button {

    LikesAndCommentsCell *cell = (LikesAndCommentsCell *)(button).superview.superview;
    Post *post = self.searchResults[cell.tag];
    UILabel *commentsLabel = cell.commentsLabel;

    [self.delegate onAddCommentTapped:commentsLabel andPost:post];
}

-(void)didTapDeleteButton:(UIButton *)button {

    [self.delegate onDeleteTapped];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {

    NSLog(@"Search button clicked");

    if (![searchBar.text isEqualToString:@""]) {

        if (self.searchSegmentedControl.selectedSegmentIndex == 0) {

            PFQuery *usernameQuery = [PFUser query];
//            [usernameQuery whereKey:@"username" containsString:searchBar.text];
            [usernameQuery whereKey:@"username" matchesRegex:searchBar.text modifiers:@"i"];

            PFQuery *displayNameQuery = [PFUser query];
//            [displayNameQuery whereKey:@"displayName" containsString:searchBar.text];
            [displayNameQuery whereKey:@"displayName" matchesRegex:searchBar.text modifiers:@"i"];

            PFQuery *searchQuery = [PFQuery orQueryWithSubqueries:@[usernameQuery, displayNameQuery]];
            [searchQuery findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {

                if (results && !error) {

                    NSLog(@"%@", results);

                    self.searchResults = results;
                }
            }];
            
        } else {

            PFQuery *searchQuery = [PFQuery queryWithClassName:@"Post"];
//            [searchQuery whereKey:@"descriptionComment" containsString:searchBar.text];
            [searchQuery whereKey:@"descriptionComment" matchesRegex:searchBar.text modifiers:@"i"];

            [searchQuery findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {

                if (results && !error) {

                    self.searchResults = results;

                    NSLog(@"%@", results);
                }
            }];
        }
    }
}

-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {

    if (![searchController.searchBar.text isEqualToString:@""]) {

        NSLog(@"%@", searchController.searchBar.text);

        if (self.searchSegmentedControl.selectedSegmentIndex == 0) {


        }
    } else {
        
        self.searchResults = nil;
    }
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"LikeSegue"]) {

        LikesTableViewController *likesVC = segue.destinationViewController;
        likesVC.post = self.searchResults[((UITapGestureRecognizer *)sender).view.tag];
        likesVC.likesLabel = (UILabel *)((UITapGestureRecognizer *)sender).view;

    } else if ([segue.identifier isEqualToString:@"CommentSegue"]) {

        NSLog(@"Comments VC Segue");

        if ([sender isKindOfClass:[UITapGestureRecognizer class]]) {

            CommentTableViewController *commentsVC = segue.destinationViewController;
            commentsVC.post = self.searchResults[((UITapGestureRecognizer *)sender).view.tag];
            commentsVC.commentsLabel = (UILabel *)((UITapGestureRecognizer *)sender).view;
        } else {

            CommentTableViewController *commentsVC = segue.destinationViewController;
            //            NSLog(@"add comment segue tag: %ld", (long)((UIButton *)sender).superview.superview.tag);
            LikesAndCommentsCell *cell = (LikesAndCommentsCell *)((UIButton *)sender).superview.superview;
            commentsVC.post = self.searchResults[cell.tag];
            commentsVC.commentsLabel = cell.commentsLabel;
        }
    }
}

@end