//
//  Comment.h
//  AudioApp
//
//  Created by David Seitz Jr on 6/14/15.
//  Copyright (c) 2015 DavidSights. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "Post.h"

@class Post;

@interface Comment : NSObject

@property NSString *objectId;
@property PFObject *commentObject;
@property PFUser *user;
@property NSString *text;
@property PFObject *post;

- (instancetype)initWithText:(NSString *)text andPost:(PFObject *)post;

- (instancetype)initWithCommentObject:(PFObject *)comment;

- (void) save;
@end
