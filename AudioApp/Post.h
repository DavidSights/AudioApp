//
//  Post.h
//  AudioApp
//
//  Created by David Seitz Jr on 6/14/15.
//  Copyright (c) 2015 DavidSights. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface Post : PFObject<PFSubclassing>

//@property PFFile *audioFile;
//@property NSString *descriptionComment;

+ (NSString *)parseClassName;

//- (instancetype)initWithAudioFile:(PFFile *)audioFile andComment:(NSString *)comment;

+(PFQuery *)queryPostsWithFriends:(NSArray *)friends andUser:(PFUser *)user withCompletion:(void(^)(NSArray *posts))complete;

+(void)queryPostsWithFriends:(NSArray *)friends withCompletion:(void(^)(NSArray *posts))complete;

+(void)queryPostsWithUser:(PFUser *)user withCompletion:(void(^)(NSArray *posts, NSError *error))complete;

+(void)queryActivityWithUser:(PFUser *)user forLikedPostsWithCompletion:(void(^)(NSArray *posts, NSError *error))complete;

+ (void)queryPostsForFeedWithCompletion:(void(^)(NSArray *posts))complete;

//- (void) save;

@end
