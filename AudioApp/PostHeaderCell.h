//
//  CommentTableViewCell.h
//  AudioApp
//
//  Created by David Seitz Jr on 6/17/15.
//  Copyright (c) 2015 DavidSights. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PostHeaderCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *displayNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *createdAtLabel;
@property (weak, nonatomic) IBOutlet UILabel *loopsLabel;

@end
