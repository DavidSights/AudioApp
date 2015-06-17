//
//  PostTableViewCell.m
//  AudioApp
//
//  Created by David Seitz Jr on 6/16/15.
//  Copyright (c) 2015 DavidSights. All rights reserved.
//

#import "PostTableViewCell.h"

@implementation PostTableViewCell

- (void)awakeFromNib {
    // Initialization code
    NSLog(@"TableViewCell here.");
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)likeButtonPressed:(id)sender {
    NSLog(@"Like button pressed.");
}
- (IBAction)commentsButtonPressed:(id)sender {
    NSLog(@"Comments button pressed.");
}

@end
