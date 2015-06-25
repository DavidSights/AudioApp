//
//  LikeCell.h
//  AudioApp
//
//  Created by Tony Dakhoul on 6/25/15.
//  Copyright (c) 2015 DavidSights. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LikeCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIButton *followButton;

- (IBAction)onFollowTapped:(UIButton *)sender;
@end
