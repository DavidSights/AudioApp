//
//  Comment.m
//  AudioApp
//
//  Created by David Seitz Jr on 6/14/15.
//  Copyright (c) 2015 DavidSights. All rights reserved.
//

#import "Comment.h"

@implementation Comment

-(instancetype)initWithText:(NSString *)text andPost:(PFObject *)post {

    self = [super init];

    self.text = text;
    self.post = post;

    return self;
}

- (instancetype)initWithCommentObject:(PFObject *)comment {

    self = [super init];

    if (self) {

        self.objectId = [comment objectForKey:@"objectId"];
        self.user = comment[@"author"];
        self.text = comment[@"text"];
        self.post = comment[@"post"];
        self.commentObject = comment;
    }

    return self;
}

- (void) save {
    if (self) {
        PFObject *comment = [PFObject objectWithClassName:@"Comment"];
        comment[@"text"] = self.text;
        comment[@"post"] = self.post;
        comment[@"user"] = [PFUser currentUser];
        [comment saveInBackgroundWithBlock:^(BOOL completed, NSError *error){
            if (!completed) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error saving comment." message:error.localizedDescription delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
                [alert show];
            }
        }];
    }
}

@end
