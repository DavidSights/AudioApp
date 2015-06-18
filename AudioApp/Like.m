//
//  Like.m
//  AudioApp
//
//  Created by David Seitz Jr on 6/14/15.
//  Copyright (c) 2015 DavidSights. All rights reserved.
//

#import "Like.h"

@implementation Like

-(instancetype)initPost:(PFObject *)post {
    self = [super init];

    self.post = post;

    return self;
}

- (instancetype)initWithLikeObject:(PFObject *)like {

    self = [super init];

    if (self) {

        self.objectId = like[@"objectId"];
        self.user = like[@"user"];
        self.post = like[@"post"];
        self.likeObject = like;

    }

    return self;
}

- (void) save {
    if (self) {
        PFObject *like = [PFObject objectWithClassName:@"Like"];
        like[@"post"] = self.post;
        like[@"author"] = [PFUser currentUser];
        [like saveInBackgroundWithBlock:^(BOOL completed, NSError *error) {
            if (!completed) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error saving like." message:error.localizedDescription delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
                [alert show];
            }
        }];
    }

}

@end
