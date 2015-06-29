//
//  ProfileInfoTableViewCell.h
//  AudioApp
//
//  Created by David Seitz Jr on 6/20/15.
//  Copyright (c) 2015 DavidSights. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileInfoTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *aboutLabel;
@property (weak, nonatomic) IBOutlet UILabel *followingFollowersLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UIButton *profilePicButton;
@property (weak, nonatomic) IBOutlet UIImageView *profileImagevIEW;

@end
