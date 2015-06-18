//
//  Post.h
//  AudioApp
//
//  Created by David Seitz Jr on 6/14/15.
//  Copyright (c) 2015 DavidSights. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface Post : NSObject

@property PFFile *audioFile;
@property NSString *descriptionComment;
@property NSArray *comments;
@property NSArray *likes;

- (instancetype)initWithAudioFile:(PFFile *)audioFile andComment:(NSString *)comment;

- (instancetype)initWithPFObject:(PFObject *)post;

-(void)queryCommentsAndLikesWithCompletion:(void(^)(NSArray *comments, NSArray *likes)) complete;

- (void) save;

@end
