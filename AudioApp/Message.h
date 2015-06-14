//
//  Message.h
//  AudioApp
//
//  Created by David Seitz Jr on 6/14/15.
//  Copyright (c) 2015 DavidSights. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface Message : NSObject

@property NSString *text;
@property PFUser *recipient;
- (instancetype)initWithText:(NSString *)text andRecipient:(PFUser *)recipient;

@end
