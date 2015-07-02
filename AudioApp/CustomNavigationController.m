//
//  CustomNavigationController.m
//  AudioApp
//
//  Created by David Seitz Jr on 6/23/15.
//  Copyright (c) 2015 DavidSights. All rights reserved.
//

#import "CustomNavigationController.h"
#import <UIKit/UIKit.h>

@interface CustomNavigationController ()

@end

@implementation CustomNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationBar.barTintColor = [UIColor colorWithRed:21/255.0 green:42/255.0 blue:59/255.0 alpha:1.0];
//    self.navigationBar.tintColor = [UIColor whiteColor];
//    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:100/255.0 green:100/255.0 blue:100/255.0 alpha:1.0]}];

    UIImage *logoLoginImage = [UIImage imageNamed:@"logo_navbar"];
    if (logoLoginImage != nil) {
        NSLog(@"Logo image successfully assigned: %@", logoLoginImage);
        self.navigationBar.topItem.titleView = [[UIImageView alloc] initWithImage:logoLoginImage];
    } else {
        NSLog(@"Tried to load navbar image but the iamge was nil.");
    }

//    [self.navigationBar setTranslucent:YES];
}

@end
