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

+(void)queryPostsForFeedWithCompletion:(void(^)(NSArray *posts))complete {

    PFQuery *postQuery = [PFQuery queryWithClassName:@"Post"];
    [postQuery includeKey:@"user"];
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
