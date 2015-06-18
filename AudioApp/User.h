//
//  User.h
//  AudioApp
//
//  Created by David Seitz Jr on 6/14/15.
//  Copyright (c) 2015 DavidSights. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface User : NSObject

@property NSString *objectId;
@property NSString *email, *password, *username;

- (instancetype)initWithEmail:(NSString *)email Password:(NSString *)password andUsername:(NSString *)username;
- (void) save;

@end
