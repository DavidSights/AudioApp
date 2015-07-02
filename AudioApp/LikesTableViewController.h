//
//  LikesTableViewController.h
//  AudioApp
//
//  Created by Tony Dakhoul on 6/24/15.
//  Copyright (c) 2015 DavidSights. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "Post.h"

@interface LikesTableViewController : UITableViewController

@property Post *post;
@property UILabel *likesLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;

@end
