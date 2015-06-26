//
//  Post.m
//  AudioApp
//
//  Created by David Seitz Jr on 6/14/15.
//  Copyright (c) 2015 DavidSights. All rights reserved.
//

#import <Parse/PFObject+Subclass.h>
#import "Post.h"

@implementation Post

+ (NSString *)parseClassName {
    return @"Post";
}

//- (instancetype)initWithAudioFile:(PFFile *)audioFile andComment:(NSString *)descriptionComment{
//    self = [super init];
//
//    self.audioFile = audioFile;
//    self.descriptionComment = descriptionComment;
//
//    return self;
//}

+(void)queryPostsWithFriends:(NSArray *)friends andUser:(PFUser *)user withCompletion:(void(^)(NSArray *posts))complete {

    NSMutableArray *searchArray = [friends mutableCopy];
    [searchArray addObject:user];

    NSLog(@"search array: %@", searchArray);

    PFQuery *postQuery = [PFQuery queryWithClassName:@"Post"];
    [postQuery whereKey:@"author" containedIn:searchArray];
    [postQuery includeKey:@"author"];
    [postQuery orderByDescending:@"createdAt"];
    postQuery.limit = 5;
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray *posts, NSError *error) {

        if (!error) {

            NSLog(@"No error");

            complete(posts);
        }
    }];
}



+(void)queryPostsWithFriends:(NSArray *)friends withCompletion:(void(^)(NSArray *posts))complete {

    PFQuery *postQuery = [PFQuery queryWithClassName:@"Post"];
    [postQuery whereKey:@"author" containedIn:friends];
    [postQuery includeKey:@"author"];
    postQuery.limit = 5;
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray *posts, NSError *error) {

        if (!error) {

            NSLog(@"No error");

            complete(posts);
        }
    }];
}

+(void)queryPostsWithUser:(PFUser *)user withCompletion:(void(^)(NSArray *posts, NSError *error))complete {

    PFQuery *postQuery = [PFQuery queryWithClassName:@"Post"];
    [postQuery whereKey:@"author" equalTo:user];
//    [postQuery includeKey:@"author"];
    postQuery.limit = 5;
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray *posts, NSError *error) {

        if (!error) {

//            NSLog(@"No error");

//            NSLog(@"Posts: %@", posts);

            complete(posts, nil);
        } else {

            complete(nil, error);
        }
    }];
}

+(void)queryActivityWithUser:(PFUser *)user forLikedPostsWithCompletion:(void(^)(NSArray *posts, NSError *error))complete {

    PFQuery *activityQuery = [PFQuery queryWithClassName:@"Activity"];
    [activityQuery whereKey:@"fromUser" equalTo:user];
    [activityQuery whereKey:@"type" equalTo:@"Like"];
    [activityQuery includeKey:@"post"];
    [activityQuery includeKey:@"toUser"];
    activityQuery.limit = 5;
    [activityQuery findObjectsInBackgroundWithBlock:^(NSArray *likeActivities, NSError *error) {

        if (!error) {

            NSMutableArray *posts = [NSMutableArray new];

            for (PFObject *activity in likeActivities) {

                if (activity[@"post"]) {

                    Post *post = activity[@"post"];
                    post[@"author"] = activity[@"toUser"];
                    [posts addObject: post];
                }
            }

            complete(posts, nil);
        } else {

            complete(nil, error);
        }
    }];
}

+(void)queryPostsForFeedWithCompletion:(void(^)(NSArray *posts))complete {

    PFQuery *postQuery = [PFQuery queryWithClassName:@"Post"];
    [postQuery includeKey:@"author"];
    postQuery.limit = 5;
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray *posts, NSError *error) {

        if (!error) {

            NSLog(@"No error");
            
            complete(posts);
        }
    }];
}
//
//- (void) save {
//    
//    if (self) {
//        
//        PFObject *post = [PFObject objectWithClassName:@"Post"];
//        post[@"audio"] = self.audioFile; // Make sure to pass PFFile instance, or change this init to handle other audio format.
//        post[@"user"] = [PFUser currentUser];
//        [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//            if (succeeded) {
//                Comment *comment = [[Comment alloc] initWithText:self.descriptionComment andPost:post];
//                [comment save];
//            } else {
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error saving post." message:error.localizedDescription delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
//                [alert show];
//            }
//        }];
//    }
//}

@end
