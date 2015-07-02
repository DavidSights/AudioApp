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
#import "ProfileViewController.h"
#import "PostHeaderCell.h"
#import "PostCell.h"
#import "DescriptionCell.h"
#import "LikesAndCommentsCell.h"
#import "Post.h"
#import "AudioPlayerWithTag.h"
#import "UIScrollView+SVInfiniteScrolling.h"
#import <Parse/Parse.h>

@interface SearchResultsViewController () <UITableViewDataSource, UITableViewDelegate, LikesAndCommentsCellDelegate, AVAudioPlayerDelegate>

@property (nonatomic)  NSMutableArray *searchResults;
@property AudioPlayerWithTag *player;
@property NSTimer *timer;
@property NSInteger *integer;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *searchSegmentedControl;

@property PFQuery *searchQuery;

@end


@implementation SearchResultsViewController
/*
 
 The search results tableview isn't updating because it's not beng accessed. The data source methods that would fill the tableview are never being called.

 */
- (void) viewDidDisappear:(BOOL)animated{
    [self.player stop];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.searchBar.delegate = self;

    [self.tableView addInfiniteScrollingWithActionHandler:^{

        [self insertToTableViewFromBottom];
    }];
    [self.tableView.infiniteScrollingView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];

}

#pragma mark - Setters

- (void)setSearchResults:(NSMutableArray *)searchResults {
    _searchResults = searchResults;
    [self.tableView reloadData];
}

#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"LikeSegue"]) {
        LikesTableViewController *likesVC = segue.destinationViewController;
        likesVC.post = self.searchResults[((UITapGestureRecognizer *)sender).view.tag];
        likesVC.likesLabel = (UILabel *)((UITapGestureRecognizer *)sender).view;

    } else if ([segue.identifier isEqualToString:@"CommentSegue"]) {

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
    } else if ([segue.identifier isEqualToString:@"profile"]) {
        ProfileViewController *profileVC = segue.destinationViewController;
        NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
        PFUser *user = self.searchResults[indexPath.row];
        profileVC.user = user;
    }
}

#pragma mark - TableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    if (self.searchSegmentedControl.selectedSegmentIndex == 0) {
        return 1;
    } else {
        return self.searchResults.count;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (self.searchSegmentedControl.selectedSegmentIndex == 0) { // This is not being called during reload either... is the TableView actually reloading?
        return self.searchResults.count;
    } else {
        return 3;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {

    if (self.searchSegmentedControl.selectedSegmentIndex == 1) {
        return 50;
    }
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    if (self.searchSegmentedControl.selectedSegmentIndex == 1) { // Customize header cell when posts are selected.
//        PostHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HeaderCell"];
//        UITapGestureRecognizer *headerGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sectionHeaderTapped:)];
//        cell.userInteractionEnabled = YES; // Does this need to be set here if user interaction is already enabled from Storyboard?
//        [cell addGestureRecognizer:headerGestureRecognizer];
//        Post *post = self.searchResults[section];
//        PFUser *user = post[@"author"];
//        NSString *displayNameText = user.username;
//        cell.displayNameLabel.text = displayNameText;
//        [cell.displayNameLabel sizeToFit];
//        cell.backgroundColor = [UIColor whiteColor];
//
//        return cell;

        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 50)];
        UIImageView *profileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 30, 30)];
        profileImageView.clipsToBounds = YES;
        profileImageView.layer.cornerRadius = 15;
        profileImageView.contentMode = UIViewContentModeScaleAspectFill;
        profileImageView.image = [UIImage imageNamed:@"Profile"];

        [headerView addSubview:profileImageView];

        UILabel *displayNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 5, headerView.frame.size.width - 90, headerView.frame.size.height/2 - 5)];
        displayNameLabel.textAlignment = NSTextAlignmentLeft;
        displayNameLabel.center = headerView.center;
        [displayNameLabel setFont:[UIFont fontWithName:@"Helvetica" size:15.0]];
        [headerView addSubview:displayNameLabel];

//        UILabel *createdAtLabel = [[UILabel alloc] initWithFrame:CGRectMake(headerView.frame.size.width - 50, 5, 45, headerView.frame.size.height/2 - 5)];
//        createdAtLabel.backgroundColor = [UIColor greenColor];
//
//        UILabel *loopsLabel = [[UILabel alloc] initWithFrame:CGRectMake(headerView.frame.size.width - 50, headerView.frame.size.height/2, 45, headerView.frame.size.height/2 - 5)];
//        loopsLabel.backgroundColor = [UIColor redColor];

//        createdAtLabel.textAlignment = NSTextAlignmentRight;
//        [createdAtLabel setFont:[UIFont fontWithName:@"Helvetica" size:10.0]];
//        createdAtLabel.text = @"Time";
//        [headerView addSubview:createdAtLabel];

//        loopsLabel.textAlignment = NSTextAlignmentRight;
//        [loopsLabel setFont:[UIFont fontWithName:@"Helvetica" size:10.0]];
//        loopsLabel.text = @"Loops";
//        [headerView addSubview:loopsLabel];

        Post *post = self.searchResults[section];

        PFUser *user = post[@"author"];
        NSLog(@"User: %@", user.username);
        NSString *displayNameText = user.username;
        NSLog(@"Display Name: %@", displayNameText);
        displayNameLabel.text = displayNameText;

        if (!user[@"profileImage"]) {
            profileImageView.image = [UIImage imageNamed:@"emptyPhoto"];
        } else{
            PFFile *file = user[@"profileImage"];
            NSData *data = [file getData];
            UIImage *image = [UIImage imageWithData:data];
            profileImageView.image = image;
        }

        UITapGestureRecognizer *headerGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sectionHeaderTapped:)];
        
        headerView.userInteractionEnabled = YES;
        [headerView addGestureRecognizer:headerGestureRecognizer];
        
        headerView.tag = section;

        headerView.backgroundColor = [UIColor colorWithRed:237/255.0 green:237/255.0 blue:237/255.0 alpha:1.0];
        displayNameLabel.textColor = [UIColor blackColor];

        return headerView;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (self.searchSegmentedControl.selectedSegmentIndex == 1) {
        if (indexPath.row == 0) { // First cell should display the audio view.
            return self.view.frame.size.width; // Height for audio view.
        }
    }
    return  50;
}
//
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Updated tableview cells."); // Not being called - which is why results aren't displaying.
    if (self.searchSegmentedControl.selectedSegmentIndex == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell"];
        PFUser *user = self.searchResults[indexPath.row];
        cell.textLabel.text = user.username;
        cell.detailTextLabel.text = user[@"displayName"];
        NSLog(@"Created a row for a user.");

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

    } else if (indexPath.row == 1) {

        DescriptionCell *descriptionCell = [tableView dequeueReusableCellWithIdentifier:@"DescriptionCell"];

        Post *post = self.searchResults[indexPath.section];

        if ([post[@"descriptionComment"] isEqualToString:@""]) {

            descriptionCell.descriptionLabel.text = @"No description for post";

        } else {

            descriptionCell.descriptionLabel.text = post[@"descriptionComment"];
        }
        
        return descriptionCell;
        
    } else {
            LikesAndCommentsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LikesAndCommentsCell"];
            Post *post = self.searchResults[indexPath.section];
            cell.likesLabel.text = [NSString stringWithFormat:@"%@ Likes", post[@"numOfLikes"]];
            cell.commentsLabel.text = [NSString stringWithFormat:@"%@ Comments", post[@"numOfComments"]];

            if ([post[@"likes"] containsObject:[[PFUser currentUser] objectId]]) {
                
                [cell.likesButton setImage:[UIImage imageNamed:@"heartFilled"] forState:UIControlStateNormal];
            } else {

                [cell.likesButton setImage:[UIImage imageNamed:@"heart"] forState:UIControlStateNormal];
            }

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

#pragma mark - Audio

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
//            NSLog(@"%i_______",self.integer);
        }
    }
}

#pragma mark - User Interaction

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {

    // Search based on selection of 'people' or 'posts' and store results in self.searchResults.

    if (![searchBar.text isEqualToString:@""]) { // Make sure search bar isn't empty

        if (self.searchSegmentedControl.selectedSegmentIndex == 0) { // If 'people' is selected...
            PFQuery *usernameQuery = [PFUser query];
            [usernameQuery whereKey:@"username" matchesRegex:searchBar.text modifiers:@"i"]; // What is happening with that modifier? - David

            PFQuery *displayNameQuery = [PFUser query];
            [displayNameQuery whereKey:@"displayName" matchesRegex:searchBar.text modifiers:@"i"];

            PFQuery *searchQuery = [PFQuery orQueryWithSubqueries:@[usernameQuery, displayNameQuery]];
            searchQuery.skip = 0;
            searchQuery.limit = 20;
            [searchQuery findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
                if (results && !error) {
                    self.searchResults = [results mutableCopy];
                    NSLog(@"Retrieved search results for users. Number of results: %lu And results saved: %lu", (unsigned long)results.count, (unsigned long)self.searchResults.count);
                }
            }];

            self.searchQuery = searchQuery;
        } else { // If 'posts' is selected...
            PFQuery *searchQuery = [PFQuery queryWithClassName:@"Post"];
            [searchQuery whereKey:@"descriptionComment" matchesRegex:searchBar.text modifiers:@"i"];
            searchQuery.limit = 0;
            searchQuery.limit = 5;
            [searchQuery findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
                if (results && !error) {
                    NSLog(@"Retrieved search results for posts. Number of posts retrieved: %lu", (unsigned long)results.count);
                    self.searchResults = [results mutableCopy];;
                }
            }];

            self.searchQuery = searchQuery;
        }
    }
}

-(void)sectionHeaderTapped:(UITapGestureRecognizer *)sender {
    PostHeaderCell *cell = (PostHeaderCell *)((UITapGestureRecognizer *)sender).view;
    Post *post = self.searchResults[cell.tag];
    PFUser *user = post[@"author"];
    [self.delegate onHeaderCellTapped:user];
}

-(void)didTapLikeButton:(UIButton *)button {
    LikesAndCommentsCell *cell = (LikesAndCommentsCell *)button.superview.superview;
    PFUser *currentUser = [PFUser currentUser];
    Post *post = self.searchResults[cell.tag];
    NSMutableArray *likes = [post[@"likes"] mutableCopy];

    if ([likes containsObject:currentUser.objectId]) {
        NSLog(@"User disliked a post.");
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
            } else {
                NSLog(@"Error processing like button in search results: %@", error.localizedDescription);
            }
        }];

        [post removeObject:currentUser.objectId forKey:@"likes"];
        [post incrementKey:@"numOfLikes" byAmount:[NSNumber numberWithInt:-1]];
        [button setImage:[UIImage imageNamed:@"heart"] forState:UIControlStateNormal];

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

        [button setImage:[UIImage imageNamed:@"heartFilled"] forState:UIControlStateNormal];

        [activity saveInBackgroundWithBlock:^(BOOL completed, NSError *error) {

            if (completed && !error) {
                NSLog(@"User like saved to Parse.");
                [post saveInBackgroundWithBlock:^(BOOL completed, NSError *error) {
                    if (completed && !error) {
                        button.enabled = YES;
                    } else {
                        NSLog(@"Error saving like to Post class: %@", error.localizedDescription);
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
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"delete" message:nil preferredStyle:UIAlertControllerStyleAlert];

    //cancels alert controller
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    //
    //saves what you wrote
    UIAlertAction *deleteAction =  [UIAlertAction actionWithTitle:@"DELETE FOREVER!!!" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

        //        self.uploadPhoto = [[UploadPhoto alloc]init];

        //        [self.selectedPhotos deleteInBackground];

        LikesAndCommentsCell *cell = (LikesAndCommentsCell *)button.superview.superview;
        NSIndexPath *indexPath =[self.tableView indexPathForCell:cell];
        Post *post = self.searchResults[indexPath.section];

        PFQuery *activityQuery = [PFQuery queryWithClassName:@"Activity"];
        [activityQuery whereKey:@"post" equalTo:post];

        [activityQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {

            if (!error) {

                for (PFObject *object in objects) {
                    [object deleteInBackground];
                }
                
            }
        }];
        [post deleteInBackgroundWithBlock:^(BOOL completed, NSError *error) {

            if (completed && !error) {
                NSMutableArray *userPostsMutable = [self.searchResults mutableCopy];
                [userPostsMutable removeObjectAtIndex:indexPath.section];
                self.searchResults = userPostsMutable;
            }
        }];
    }];
    //add cancelAction variable to alertController
    [alertController addAction:cancelAction];
    [alertController addAction:deleteAction];

    //activates alertcontroler
    [self presentViewController:alertController animated:true completion:nil];
    [self.delegate onDeleteTapped];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //    self.indexPath = indexPath;
    if (self.searchSegmentedControl.selectedSegmentIndex == 1) { // 'Posts' selected.
        if (indexPath.row == 0) { // Only respond to audio display cell.
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
                        NSLog(@"Error creating new audio session: %@", setCategoryError.localizedDescription);
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
                    NSLog(@"Error creating new audio session: %@", setCategoryError.localizedDescription);
                }

                self.player = [[AudioPlayerWithTag alloc] initWithData:data error:nil];
                self.player.tag = (int)indexPath.section;
                self.integer = 0;

                [self playRecordedAudio];
            }
        }
    }
    else if (self.searchSegmentedControl.selectedSegmentIndex == 0) { // We're in the 'people' segment
        // Grab user from cell
        NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
        PFUser *user = self.searchResults[indexPath.row];
        [self.delegate onHeaderCellTapped:user];
//        [self performSegueWithIdentifier:@"profile" sender:self];
    }
}

- (IBAction)segmentedConrollerChanged:(id)sender { // Search based on selection of 'people' or 'posts' and store results in self.searchResults.

    if (![self.searchBar.text isEqualToString:@""]) { // Make sure search bar isn't empty

        if (self.searchSegmentedControl.selectedSegmentIndex == 0) { // If 'people' is selected...
            PFQuery *usernameQuery = [PFUser query];
            [usernameQuery whereKey:@"username" matchesRegex:self.searchBar.text modifiers:@"i"]; // What is happening with that modifier? - David

            PFQuery *displayNameQuery = [PFUser query];
            [displayNameQuery whereKey:@"displayName" matchesRegex:self.searchBar.text modifiers:@"i"];

            PFQuery *searchQuery = [PFQuery orQueryWithSubqueries:@[usernameQuery, displayNameQuery]];
            [searchQuery findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
                if (results && !error) {
                    self.searchResults = results;
                    NSLog(@"Retrieved search results for users. Number of results: %lu And results saved: %lu", (unsigned long)results.count, (unsigned long)self.searchResults.count);
                }
            }];
        } else { // If 'posts' is selected...
            PFQuery *searchQuery = [PFQuery queryWithClassName:@"Post"];
            [searchQuery whereKey:@"descriptionComment" matchesRegex:self.searchBar.text modifiers:@"i"];
            [searchQuery findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
                if (results && !error) {
                    NSLog(@"Retrieved search results for posts. Number of posts retrieved: %lu", (unsigned long)results.count);
                    self.searchResults = results;
                }
            }];
        }
    }
}

#pragma mark - Update Results

-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {

    if (![searchController.searchBar.text isEqualToString:@""]) {
//        NSLog(@"%@", searchController.searchBar.text);
        if (self.searchSegmentedControl.selectedSegmentIndex == 0) {
            // Do something based on segmented controller being people?
        }
    } else {
        // Do something based on segmented controller being posts?
        self.searchResults = nil; // Why set searchResults to nothing when users selected?
    }
}

- (void)insertToTableViewFromBottom {

    if (self.searchQuery) {

        if (self.searchQuery.limit == 5) {

            self.searchQuery.skip += 5;
        } else {

            self.searchQuery.skip += 20;
        }

        [self.searchQuery findObjectsInBackgroundWithBlock:^(NSArray *posts, NSError *error) {

            if (!error && posts) {

                if (posts.count != 0) {

                    for (Post *post in posts) {

                        NSLog(@"Post: %@", post);

                        int64_t delayInSeconds = 1.0;
                        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                            [self.tableView beginUpdates];

                            [self.searchResults addObject:post];

                            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:self.searchResults.count-1] withRowAnimation:UITableViewRowAnimationMiddle];

                            [self.tableView endUpdates];

                            [self.tableView.infiniteScrollingView stopAnimating];
                        });
                    }
                } else {

                    [self.tableView.infiniteScrollingView stopAnimating];
                }
            }
        }];
    }
}

#pragma mark - Set Color of Posts

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

//UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"delete" message:nil preferredStyle:UIAlertControllerStyleAlert];
//
////cancels alert controller
//UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
////
////saves what you wrote
//UIAlertAction *deleteAction =  [UIAlertAction actionWithTitle:@"DELETE FOREVER!!!" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//
//    //        self.uploadPhoto = [[UploadPhoto alloc]init];
//
//    //        [self.selectedPhotos deleteInBackground];
//
//    LikesAndCommentsCell *cell = (LikesAndCommentsCell *)button.superview.superview;
//    NSIndexPath *indexPath =[self.tableView indexPathForCell:cell];
//    Post *post = self.searchResults[indexPath.section];
//
//
//    [post deleteInBackgroundWithBlock:^(BOOL completed, NSError *error) {
//
//        if (completed && !error) {
//
//            NSMutableArray *userPostsMutable = [self.searchResults mutableCopy];
//            [userPostsMutable removeObjectAtIndex:indexPath.section];
//            self.searchResults = userPostsMutable;
//        }
//    }];
//}];
//
////add cancelAction variable to alertController
//[alertController addAction:cancelAction];
//
//[alertController addAction:deleteAction];
//
////activates alertcontroler
//[self presentViewController:alertController animated:true completion:nil];
//


@end
