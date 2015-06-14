//
//  User.m
//  AudioApp
//
//  Created by David Seitz Jr on 6/14/15.
//  Copyright (c) 2015 DavidSights. All rights reserved.
//

#import "User.h"

@implementation User

- (instancetype)initWithEmail:(NSString *)email Password:(NSString *)password andUsername:(NSString *)username {
    self = [super init];

    self.email = email;
    self.password = password;
    self.username = username;

    return self;
}


- (void) save {
    if (self) {
        PFUser *newUser = [PFUser user];
        newUser.email = self.email;
        newUser.password = self.password;
        newUser.username = self.username;

        [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!succeeded) {
                NSString *errorString = [error userInfo][@"error"];   // Show the errorString somewhere and let the user try again.
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Whoops, there was an error." message:errorString delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
                [alert show];
            }
        }];
    }
}
@end
