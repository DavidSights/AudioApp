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
//    self.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationBar.tintColor = [UIColor blackColor];
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
