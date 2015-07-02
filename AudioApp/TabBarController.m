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

    self.tabBar.tintColor = [UIColor colorWithRed:50/255.0 green:50/255.0 blue:50/255.0 alpha:1.0];
    //    self.tabBar.barTintColor = [UIColor colorWithRed:40/255.0 green:40/255.0 blue:40/255.0 alpha:1.0];
    [self.tabBar setTranslucent:YES];

    [[UITabBar appearance] setTintColor:[UIColor whiteColor]]; // for unselected items that are gray
    UIColor * unselectedColor = [UIColor greenColor];
    self.tabBar.selectionIndicatorImage = [UIImage imageNamed:@"selectedBackground"];

//        NSArray *tabBarItemImages = [NSArray arrayWithObjects:[UIImage imageNamed:@"selectedBackground"],
//                                     [UIImage imageNamed:@"selectedBackground"],
//                                     [UIImage imageNamed:@"selectedBackground"],
//                                     [UIImage imageNamed:@"selectedBackground"],
//                                     [UIImage imageNamed:@"selectedBackground"] , nil];
    int i = 0;
    for (UITabBarItem *item in self.tabBar.items) {
        if (i < 5) {
            item.imageInsets = UIEdgeInsetsMake(8, 0, -8, 0);
//            NSLog(@"Filling tab %i", i);
//            item.selectedImageind = tabBarItemImages[i];

            // set color of unselected text
            [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:unselectedColor, NSForegroundColorAttributeName, nil]
                                                     forState:UIControlStateNormal];
            i++;
        }
    }
    [self drawColorBar];
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return newImage;
}

-(void)drawColorBar {
    //    UIButton *cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //    cameraButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    //    cameraButton.frame = CGRectMake(0.0, 0.0, self.tabBar.frame.size.width/5, self.tabBar.frame.size.height);
    //    UIImage *cameraImage = [self imageWithImage:[UIImage imageNamed:@"Camera"] scaledToSize:CGSizeMake(30, 30)];
    //    cameraImage = [cameraImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    //    [cameraButton setImage:cameraImage forState:UIControlStateNormal];
    //    [cameraButton setTintColor:[UIColor whiteColor]];
    //    cameraButton.backgroundColor = [UIColor colorWithRed:0.070 green:0.337 blue:0.533 alpha:1.0];
    //    cameraButton.center = self.tabBar.center;

    //    [cameraButton addTarget:self action:@selector(cameraView) forControlEvents:UIControlEventTouchUpInside];

    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(self.tabBar.frame.origin.x, self.tabBar.frame.origin.y, self.view.frame.size.width, 4.0)];
    backgroundView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;

//    Color theme to be used throughout the entire app.
    UIColor *blue =     [UIColor colorWithRed:160/255.0 green:215/255.0 blue:231/255.0 alpha:1.0];
    UIColor *yellow =   [UIColor colorWithRed:255/255.0 green:248/255.0 blue:196/255.0 alpha:1.0];
    UIColor *red =      [UIColor colorWithRed:205/255.0 green:124/255.0 blue:135/255.0 alpha:1.0];
    UIColor *purple =   [UIColor colorWithRed:176/255.0 green:150/255.0 blue:193/255.0 alpha:1.0];
    UIColor *green =    [UIColor colorWithRed:124/255.0 green:191/255.0 blue:183/255.0 alpha:1.0];
//    UIColor *darkBlue = [UIColor colorWithRed:83/255.0 green:153/255.0 blue:174/255.0 alpha:1.0];
//    UIColor *darkYellow = [UIColor colorWithRed:204/255.0 green:164/255.0 blue:42/255.0 alpha:1.0];
//    UIColor *darkRed = [UIColor colorWithRed:166/255.0 green:81/255.0 blue:92/255.0 alpha:1.0];
//    UIColor *darkPurple = [UIColor colorWithRed:121/255.0 green:192/255.0 blue:140/255.0 alpha:1.0];
//    UIColor *darkGreen = [UIColor colorWithRed:75/255.0 green:151/255.0 blue:142/255.0 alpha:1.0];

    float stroke = 4;
    CGFloat top = 0.0;
//    CGFloat bottom =  self.tabBar.frame.size.height-stroke;
    CGFloat y = top;

    UIView *homeButton = [[UIView alloc] initWithFrame:CGRectMake(0.0, y, self.view.frame.size.width/5.0, stroke)];
    homeButton.backgroundColor = purple;

    UIView *searchButton = [[UIView alloc] initWithFrame:CGRectMake((self.tabBar.frame.size.width/5), y, self.view.frame.size.width/5.0, stroke)];
    searchButton.backgroundColor = blue;

    UIView *recordButton = [[UIView alloc] initWithFrame:CGRectMake(((self.tabBar.frame.size.width/5)*2), y, self.view.frame.size.width/5.0, stroke)];
    recordButton.backgroundColor = red;

    UIView *activityButton = [[UIView alloc] initWithFrame:CGRectMake(((self.tabBar.frame.size.width/5)*3), y, self.view.frame.size.width/5.0, stroke)];
    activityButton.backgroundColor = yellow;

    UIView *profileButton = [[UIView alloc] initWithFrame:CGRectMake(((self.tabBar.frame.size.width/5)*4), y, self.view.frame.size.width/5.0, stroke)];
    profileButton.backgroundColor = green;

    [backgroundView addSubview:homeButton];
    [backgroundView addSubview:searchButton];
    [backgroundView addSubview:recordButton];
    [backgroundView addSubview:activityButton];
    [backgroundView addSubview:profileButton];
    [self.view addSubview:backgroundView];
}

@end
