//
//  TabBarController.m
//  AudioApp
//
//  Created by David Seitz Jr on 6/19/15.
//  Copyright (c) 2015 DavidSights. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TabBarController.h"

@interface TabBarController ()

@end

@implementation TabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.tabBar.tintColor = [UIColor colorWithRed:176/255.0 green:150/255.0 blue:193/255.0 alpha:1.0];
//    self.tabBar.barTintColor = [UIColor colorWithRed:40/255.0 green:40/255.0 blue:40/255.0 alpha:1.0];
//    [[UINavigationBar appearance] setTranslucent:YES];
//
//    NSArray *tabBarItemImages = [NSArray arrayWithObjects:[[UIImage imageNamed:@"HomeIcon02"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal],
//                                 [[UIImage imageNamed:@"Discover"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal],
//                                 [UIImage imageNamed:@"Record"],
//                                 [UIImage imageNamed:@"Heart"],
//                                 [UIImage imageNamed:@"Profile"] , nil];
//    int i = 0;
//    for (UITabBarItem *item in self.tabBar.items) {
//        if (i < 3) {
//            item.image = [self imageWithImage:tabBarItemImages[i] scaledToSize:CGSizeMake(30, 30)];
//            item.image.cont
////            item aa
//            item.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
//            i++;
//        }
//    }
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {

    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
