//
//  Like.h
//  AudioApp
//
//  Created by David Seitz Jr on 6/14/15.
//  Copyright (c) 2015 DavidSights. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface Like : NSObject
@property PFObject *post;
- (instancetype)initPost:(PFObject *)post;
@end
