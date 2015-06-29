//
//  ActivityTableViewCell.h
//  AudioApp
//
//  Created by David Seitz Jr on 6/29/15.
//  Copyright (c) 2015 DavidSights. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivityTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *statLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end
