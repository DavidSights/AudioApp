//
//  LabelsAndButtonsTableViewCell.m
//  AudioApp
//
//  Created by David Seitz Jr on 6/17/15.
//  Copyright (c) 2015 DavidSights. All rights reserved.
//

#import "LikesAndCommentsCell.h"

@implementation LikesAndCommentsCell

- (void)awakeFromNib {
    // Initialization code
    self.likesLabel.textColor = [UIColor grayColor];
    self.commentsLabel.textColor = [UIColor grayColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (IBAction)commentsButtonPressed:(UIButton *)button {

    NSLog(@"CommentsButtonPRessed");
    [self.delegate didTapAddCommentButton:button];
}

- (IBAction)likeButtonPressed:(UIButton *)button {
    [self.delegate didTapLikeButton:button];
}

- (IBAction)deleteButtonPressed:(UIButton *)button {
    [self.delegate didTapDeleteButton:button];
}

@end
