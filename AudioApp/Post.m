//
//  Post.m
//  AudioApp
//
//  Created by David Seitz Jr on 6/14/15.
//  Copyright (c) 2015 DavidSights. All rights reserved.
//

#import "Post.h"
#import "Comment.h"

@implementation Post

- (instancetype)initWithAudioFile:(PFFile *)audioFile andComment:(NSString *)comment {
    self = [super init];

    self.audioFile = audioFile;
    self.comment = comment;

    return self;
}

- (void) save {
    if (self) {
        PFObject *post = [PFObject objectWithClassName:@"Post"];
        post[@"audio"] = self.audioFile; // Make sure to pass PFFile instance, or change this init to handle other audio format.
        post[@"user"] = [PFUser currentUser];
        [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                Comment *comment = [[Comment alloc] initWithText:self.comment andPost:post];
                [comment save];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error saving post." message:error.localizedDescription delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
                [alert show];
            }
        }];
    }
}

@end
