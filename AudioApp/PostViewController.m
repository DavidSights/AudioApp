//
//  PostViewController.m
//  AudioApp
//
//  Created by Alex Santorineos on 6/16/15.
//  Copyright (c) 2015 DavidSights. All rights reserved.
//

#import "PostViewController.h"
#import <Parse/Parse.h>
@interface PostViewController ()
@property (weak, nonatomic) IBOutlet UITextView *commentTextView;
@property (weak, nonatomic) IBOutlet UIButton *postButton;

@end

@implementation PostViewController

- (void)viewDidLoad {
    [super viewDidLoad];


}


- (IBAction)onPostTapped:(UIButton *)sender {


    [self uploadPost];
}

- (void)uploadPost {
    PFUser *currentUser = [PFUser currentUser];
    NSData *fileData = [NSData dataWithContentsOfURL:self.recorder.url];
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:self.theColor];

    PFFile *file = [PFFile fileWithName:@"audio.m4a" data:fileData];
    PFFile *fileColor = [PFFile fileWithData:colorData];
    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"An error occurred!"
                                                                message:@"Please try sending your message again."
                                                               delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
        else {
            PFObject *post = [PFObject objectWithClassName:@"Post"];
            [post setObject:file forKey:@"audio"];
            [post setObject:currentUser forKey:@"author"];
            [post setObject:fileColor forKey:@"color"];



            [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"An error occurred!"
                                                                        message:@"Please try sending your message again."
                                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alertView show];
                }
                else {
                    // Everything was successful!
                    //                    [self reset];
                }
            }];


            PFObject *comment = [PFObject objectWithClassName:@"Comment"];
            [comment setObject:self.commentTextView.text forKey:@"text"];
            [comment setObject:post forKey:@"post"];
            [comment setObject:currentUser forKey:@"author"];

            [comment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"An error occurred!"
                                                                        message:@"Please try sending your message again."
                                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alertView show];
                }
                else {
//                    [self.tabBarController setSelectedIndex:0];
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"Test1" object:self];

                }

            }];

       }
    }];
    [self.tabBarController setSelectedIndex:0];
    [self.navigationController popToRootViewControllerAnimated:true];

    [self.recorder stop];
    [self.recorder deleteRecording];
}




@end
