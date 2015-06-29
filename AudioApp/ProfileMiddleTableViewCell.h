//
//  ProfileMiddleTableViewCell.h
//  AudioApp
//
//  Created by Tony Dakhoul on 6/25/15.
//  Copyright (c) 2015 DavidSights. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ProfileMiddleTableViewCellDelegate <NSObject>

-(void) segmentedControlChanged:(UISegmentedControl *)segmentedControl;

-(void) middleCellButtonTapped:(UIButton *)button;

@end

@interface ProfileMiddleTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *cellButton;

@property (weak, nonatomic) IBOutlet UISegmentedControl *profileSegmentedControl;

@property (nonatomic,assign) id<ProfileMiddleTableViewCellDelegate> delegate;

@end
