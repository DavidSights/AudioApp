//
//  LabelsAndButtonsTableViewCell.h
//  AudioApp
//
//  Created by David Seitz Jr on 6/17/15.
//  Copyright (c) 2015 DavidSights. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LikesAndCommentsCellDelegate <NSObject>

- (void)didTapLikeButton:(UIButton *)button;

@end

@interface LikesAndCommentsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *likesLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentsLabel;
@property (weak, nonatomic) IBOutlet UIButton *likesButton;
@property (weak, nonatomic) IBOutlet UIButton *commentsButton;

@property (nonatomic,assign) id<LikesAndCommentsCellDelegate> delegate;

@end
