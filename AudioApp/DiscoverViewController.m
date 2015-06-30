//
//  DiscoverViewController.m
//  
//
//  Created by David Seitz Jr on 6/15/15.
//
//

#import "DiscoverViewController.h"
#import "SearchResultsViewController.h"
#import "LikesAndCommentsCell.h"
#import "LikesTableViewController.h"
#import "CommentTableViewController.h"
#import "ProfileViewController.h"

@interface DiscoverViewController () <UISearchControllerDelegate, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, SearchResultsViewControllerDelegate>

@property SearchResultsViewController *searchResultsViewController;
@property UISearchController *searchController;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property PFUser *searchResultsUser;
@property Post *searchResultsVCPost;
@property UILabel *searchResultsVCLabel;

@property NSArray *tests;

@end

@implementation DiscoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.searchResultsViewController = [storyboard instantiateViewControllerWithIdentifier:@"SearchResultsViewController"];
    self.searchResultsViewController.delegate = self;

    self.searchController = [[UISearchController alloc] initWithSearchResultsController:self.searchResultsViewController];

    self.searchResultsViewController.searchBar = self.searchController.searchBar;
    self.searchController.searchResultsUpdater = self.searchResultsViewController;
    self.searchController.delegate = self;
    self.searchController.searchBar.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = YES;
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    self.navigationItem.titleView = self.searchController.searchBar;
    self.definesPresentationContext = YES;

    self.tests = @[@1, @2, @3, @4, @5, @6];
}

-(void)willPresentSearchController:(UISearchController *)searchController {

    NSLog(@"%d", self.searchController.active);

    //    self.searchController.active = YES;
    //    searchController.searchResultsController.view.hidden = NO;

    //    dispatch_async(dispatch_get_main_queue(), ^{
    //        searchController.searchResultsController.view.hidden = NO;
    //    });
}

-(void)didPresentSearchController:(UISearchController *)searchController {

    NSLog(@"%d", self.searchController.active);

    //    searchController.searchResultsController.view.hidden = NO;
}

-(void)presentSearchController:(UISearchController *)searchController {

    NSLog(@"Present search controller");
    dispatch_async(dispatch_get_main_queue(), ^{
        searchController.searchResultsController.view.hidden = NO;
    });
}

-(void)willDismissSearchController:(UISearchController *)searchController {

    NSLog(@"Will dismiss");
}

-(void)didDismissSearchController:(UISearchController *)searchController {

    NSLog(@"Did dismiss");
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {

    NSLog(@"%@", searchBar.text);
    //Prevents searchController from disappearing
    if ([searchText isEqualToString:@""])
    {
        [self presentSearchController:self.searchController];
    }
}

//-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
//
//    NSLog(@"Search bar tapped");
//
//}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.tests.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellID"];

    cell.textLabel.text = [NSString stringWithFormat:@"%@", self.tests[indexPath.row]];

    return cell;
}

-(void)onHeaderCellTapped:(PFUser *)user {

    self.searchResultsUser = user;
    [self performSegueWithIdentifier:@"ProfileSegue" sender:self];
}

-(void)onLikesLabelTapped:(UILabel *)label andPost:(Post *)post {

    self.searchResultsVCPost = post;
    self.searchResultsVCLabel = label;
    [self performSegueWithIdentifier:@"LikeSegue" sender:self];
}

-(void)onCommentsLabelTapped:(UILabel *)label andPost:(Post *)post {

    self.searchResultsVCPost = post;
    self.searchResultsVCLabel = label;
    [self performSegueWithIdentifier:@"CommentSegue" sender:self];
}

-(void)onAddCommentTapped:(UILabel *)label andPost:(Post *)post {

    self.searchResultsVCPost = post;
    self.searchResultsVCLabel = label;
    [self performSegueWithIdentifier:@"CommentSegue" sender:self];
}

-(void)onDeleteTapped {

}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"LikeSegue"]) {

        LikesTableViewController *likesVC = segue.destinationViewController;
        likesVC.post = self.searchResultsVCPost;
        likesVC.likesLabel = self.searchResultsVCLabel;
    } else if ([segue.identifier isEqualToString:@"CommentSegue"]) {

        CommentTableViewController *commentVC = segue.destinationViewController;
        commentVC.post = self.searchResultsVCPost;
        commentVC.commentsLabel = self.searchResultsVCLabel;
    }else if ([segue.identifier isEqualToString:@"ProfileSegue"]) {

        ProfileViewController *profileVC = segue.destinationViewController;

        profileVC.user = self.searchResultsUser;
        
    }
}

@end
