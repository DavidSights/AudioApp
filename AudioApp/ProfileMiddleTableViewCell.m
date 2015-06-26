//
//  ProfileMiddleTableViewCell.m
//  AudioApp
//
//  Created by Tony Dakhoul on 6/25/15.
//  Copyright (c) 2015 DavidSights. All rights reserved.
//

#import "ProfileMiddleTableViewCell.h"

@implementation ProfileMiddleTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)onProfileSegmentedControlChange:(UISegmentedControl *)sender {

    [self.delegate segmentedControlChanged:sender];
}
@end
