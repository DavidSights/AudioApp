//
//  CommentTableViewController.h
//  AudioApp
//
//  Created by Alex Santorineos on 6/23/15.
//  Copyright (c) 2015 DavidSights. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "Post.h"

@interface CommentTableViewController : UITableViewController

@property Post *post;
@property UILabel *commentsLabel;

@end
