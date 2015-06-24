//
//  Post.h
//  AudioApp
//
//  Created by David Seitz Jr on 6/14/15.
//  Copyright (c) 2015 DavidSights. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "Comment.h"
#import "Like.h"

@interface Post : PFObject<PFSubclassing>

//@property PFFile *audioFile;
//@property NSString *descriptionComment;

+ (NSString *)parseClassName;

//- (instancetype)initWithAudioFile:(PFFile *)audioFile andComment:(NSString *)comment;

+ (void)queryPostsForFeedWithCompletion:(void(^)(NSArray *posts))complete;

//- (void) save;

@end
