//
//  User.m
//  AudioApp
//
//  Created by David Seitz Jr on 6/14/15.
//  Copyright (c) 2015 DavidSights. All rights reserved.
//

#import "User.h"

NSArray *currentUserFriends;
NSDictionary *currentUserFollowDictionary;

@implementation User

+(void)queryFriendsWithUser:(PFUser *)user withCompletion:(void(^)(NSArray *friends, NSError *error))complete {

    PFQuery *postQuery = [PFQuery queryWithClassName:@"Activity"];
    [postQuery whereKey:@"fromUser" equalTo:user];
    [postQuery whereKey:@"type" equalTo:@"Follow"];
    [postQuery includeKey:@"toUser"];
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {

        if (!error) {

            NSLog(@"No error");

            NSMutableDictionary *followDictionaryMutable = [NSMutableDictionary new];

            NSMutableArray *friends = [NSMutableArray new];

            for (PFObject *activity in activities) {

                [followDictionaryMutable setObject:activity forKey:[activity[@"toUser"] objectId]];

//                PFUser *user = activity[@"toUser"];
//                [friends addObject:user.objectId];

                [friends addObject:activity[@"toUser"]];
            }
            currentUserFollowDictionary = followDictionaryMutable;
            complete(friends, nil);
        } else {

            complete(nil, error);
        }
    }];
}

@end
