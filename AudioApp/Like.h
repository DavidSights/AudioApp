//
//  Like.h
//  AudioApp
//
//  Created by David Seitz Jr on 6/14/15.
//  Copyright (c) 2015 DavidSights. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "Post.h"

@class Post;

@interface Like : NSObject

@property NSString *objectId;
@property PFUser *user;
@property PFObject *likeObject;
@property PFObject *post;

- (instancetype)initPost:(PFObject *)post;

- (instancetype)initWithLikeObject:(PFObject *)like;
@end
