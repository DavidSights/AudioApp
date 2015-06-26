//
//  CommentTableViewCell.m
//  AudioApp
//
//  Created by David Seitz Jr on 6/17/15.
//  Copyright (c) 2015 DavidSights. All rights reserved.
//

#import "PostHeaderCell.h"

@implementation PostHeaderCell

- (void)awakeFromNib {
    // Initialization code
    self.displayNameLabel.textColor = [UIColor grayColor];
    self.loopsLabel.textColor = [UIColor grayColor];
    self.createdAtLabel.textColor = [UIColor grayColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)userButtonPressed:(id)sender {

}

@end
