//
//  User.m
//  AudioApp
//
//  Created by David Seitz Jr on 6/14/15.
//  Copyright (c) 2015 DavidSights. All rights reserved.
//

#import "User.h"

NSArray *currentUserFriends;

@implementation User

+(void)queryFriendsWithUser:(PFUser *)user withCompletion:(void(^)(NSArray *friends, NSError *error))complete {

    PFQuery *postQuery = [PFQuery queryWithClassName:@"Activity"];
    [postQuery whereKey:@"fromUser" equalTo:user];
    [postQuery whereKey:@"type" equalTo:@"Follow"];
    [postQuery includeKey:@"toUser"];
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {

        if (!error) {

            NSLog(@"No error");

            NSMutableArray *friends = [NSMutableArray new];

            for (PFObject *activity in activities) {

//                PFUser *user = activity[@"toUser"];
//                [friends addObject:user.objectId];

                [friends addObject:activity[@"toUser"]];
            }

            complete(friends, nil);
        } else {

            complete(nil, error);
        }
    }];
}

@end
