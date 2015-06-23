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
    int i = 0;
    for (UITabBarItem *item in self.tabBar.items) {
        if (i < 5) {
            item.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
            i++;
        }
    }

    [self backgroundColors];
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {

    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(void)backgroundColors {

    //    UIButton *cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //    cameraButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    //    cameraButton.frame = CGRectMake(0.0, 0.0, self.tabBar.frame.size.width/5, self.tabBar.frame.size.height);
    //    UIImage *cameraImage = [self imageWithImage:[UIImage imageNamed:@"Camera"] scaledToSize:CGSizeMake(30, 30)];
    //    cameraImage = [cameraImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    //    [cameraButton setImage:cameraImage forState:UIControlStateNormal];
    //    [cameraButton setTintColor:[UIColor whiteColor]];
    //    cameraButton.backgroundColor = [UIColor colorWithRed:0.070 green:0.337 blue:0.533 alpha:1.0];
    //    cameraButton.center = self.tabBar.center;
    //
    //    [cameraButton addTarget:self action:@selector(cameraView) forControlEvents:UIControlEventTouchUpInside];

    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(self.tabBar.frame.origin.x, self.tabBar.frame.origin.y, self.view.frame.size.width, 4.0)];
    backgroundView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;

    float stroke = 4;

    UIView *blueView = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.tabBar.frame.size.height-stroke, self.view.frame.size.width/5.0, stroke)];
    blueView.backgroundColor = [UIColor colorWithRed:160.0/255.0 green:215.0/255.0 blue:231.0/255.0 alpha:1.0];

    UIView *yellowView = [[UIView alloc] initWithFrame:CGRectMake((self.tabBar.frame.size.width/5), self.tabBar.frame.size.height-stroke, self.view.frame.size.width/5.0, stroke)];
    yellowView.backgroundColor = [UIColor colorWithRed:249/255.0 green:217/255.0 blue:119/255.0 alpha:1.0];

    UIView *redView = [[UIView alloc] initWithFrame:CGRectMake(((self.tabBar.frame.size.width/5)*2), self.tabBar.frame.size.height-stroke, self.view.frame.size.width/5.0, stroke)];
    redView.backgroundColor = [UIColor colorWithRed:205/255.0 green:124/255.0 blue:135/255.0 alpha:1.0];

    UIView *purpleView = [[UIView alloc] initWithFrame:CGRectMake(((self.tabBar.frame.size.width/5)*3), self.tabBar.frame.size.height-stroke, self.view.frame.size.width/5.0, stroke)];
    purpleView.backgroundColor = [UIColor colorWithRed:176/255.0 green:150/255.0 blue:193/255.0 alpha:1.0];

    UIView *greenView = [[UIView alloc] initWithFrame:CGRectMake(((self.tabBar.frame.size.width/5)*4), self.tabBar.frame.size.height-stroke, self.view.frame.size.width/5.0, stroke)];
    greenView.backgroundColor = [UIColor colorWithRed:124/255.0 green:191/255.0 blue:183/255.0 alpha:1.0];

    [backgroundView addSubview:blueView];
    [backgroundView addSubview:yellowView];
    [backgroundView addSubview:redView];
    [backgroundView addSubview:purpleView];
    [backgroundView addSubview:greenView];
    [self.view addSubview:backgroundView];
}

@end
