//
//  SearchResultsViewController.h
//  AudioApp
//
//  Created by Tony Dakhoul on 6/29/15.
//  Copyright (c) 2015 DavidSights. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "Post.h"

@protocol SearchResultsViewControllerDelegate <NSObject>

-(void)onLikesLabelTapped:(UILabel *)label andPost:(Post *)post;
-(void)onCommentsLabelTapped:(UILabel *)label andPost:(Post *)post;
-(void)onAddCommentTapped:(UILabel *)label andPost:(Post *)post;
-(void)onDeleteTapped;
-(void)onHeaderCellTapped:(PFUser *)user;

@end

@interface SearchResultsViewController : UIViewController <UISearchResultsUpdating, UISearchBarDelegate>

@property NSArray *testArray;
@property UISearchBar *searchBar;

@property (nonatomic,assign) id<SearchResultsViewControllerDelegate> delegate;

@end
