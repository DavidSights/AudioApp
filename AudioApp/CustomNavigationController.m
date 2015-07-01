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
    // Do any additional setup after loading the view.
    self.navigationBar.barTintColor = [UIColor colorWithRed:21/255.0 green:42/255.0 blue:59/255.0 alpha:1.0];
    self.navigationBar.tintColor = [UIColor whiteColor];
//    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:100/255.0 green:100/255.0 blue:100/255.0 alpha:1.0]}];

    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_login"]];


//    [self.navigationBar setTranslucent:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
