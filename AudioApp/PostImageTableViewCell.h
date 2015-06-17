//
//  PostImageTableViewCell.h
//  AudioApp
//
//  Created by David Seitz Jr on 6/17/15.
//  Copyright (c) 2015 DavidSights. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PostImageTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end
