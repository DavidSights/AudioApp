//
//  Message.m
//  AudioApp
//
//  Created by David Seitz Jr on 6/14/15.
//  Copyright (c) 2015 DavidSights. All rights reserved.
//

#import "Message.h"

@implementation Message

- (instancetype)initWithText:(NSString *)text andRecipient:(PFUser *)recipient {
    self = [super init];

    self.text = text;
    self.recipient = recipient;

    return self;
}

- (void) save {
    PFObject *message = [PFObject objectWithClassName:@"Message"];
    message[@"text"] = self.text;
    message[@"recipient"] = self.recipient;
    message[@"user"] = [PFUser currentUser];
    [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!succeeded) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error sending message." message:error.localizedDescription delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
            [alert show];
        }
    }];
}

@end
