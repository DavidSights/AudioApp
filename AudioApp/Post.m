//
//  Post.m
//  AudioApp
//
//  Created by David Seitz Jr on 6/14/15.
//  Copyright (c) 2015 DavidSights. All rights reserved.
//

#import "Post.h"

@implementation Post

- (instancetype)initWithAudioFile:(PFFile *)audioFile andComment:(NSString *)descriptionComment{
    self = [super init];

    self.audioFile = audioFile;
    self.descriptionComment = descriptionComment;

    return self;
}

- (instancetype)initWithPFObject:(PFObject *)post {

    self = [super init];

    if (self) {

        self.objectId = post[@"objectId"];
        self.audioFile = post[@"audio"];
        self.descriptionComment = post[@"descriptionComment"];
        self.postObject = post;
        self.colorHex = post[@"colorHex"];
    }

    return self;
}

+(void)queryCommentsAndLikesWithPost:(PFObject *)post andCompletion:(void(^)(NSArray *comments, NSArray *likes)) complete {

    PFQuery *commentsQuery = [[PFQuery alloc] initWithClassName:@"Comment"];
    [commentsQuery whereKey:@"post" equalTo:post];
    [commentsQuery orderByDescending:@"createdAt"];

    [commentsQuery findObjectsInBackgroundWithBlock:^(NSArray *comments, NSError *error) {

        NSMutableArray *commentsMutable = [NSMutableArray new];
        for (PFObject *commentObject in comments) {

            Comment *comment = [[Comment alloc] initWithCommentObject:commentObject];
            [commentsMutable addObject:comment];
        }

        PFQuery *likesQuery = [[PFQuery alloc] initWithClassName:@"Like"];
        [likesQuery whereKey:@"post" equalTo:post];

        [likesQuery findObjectsInBackgroundWithBlock:^(NSArray *likes, NSError *error) {

            NSLog(@"Likes.count: %d", likes.count);

            NSMutableArray *likesMutable = [NSMutableArray new];
            for (PFObject *likeObject in likes) {

                Like *like = [[Like alloc] initWithLikeObject:likeObject];
                [likesMutable addObject:like];
            }

            complete(commentsMutable, likesMutable);
        }];
    }];

}

- (void) save {
    if (self) {
        
        PFObject *post = [PFObject objectWithClassName:@"Post"];
        post[@"audio"] = self.audioFile; // Make sure to pass PFFile instance, or change this init to handle other audio format.
        post[@"user"] = [PFUser currentUser];
        [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                Comment *comment = [[Comment alloc] initWithText:self.descriptionComment andPost:post];
                [comment save];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error saving post." message:error.localizedDescription delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
                [alert show];
            }
        }];
    }
}

@end
