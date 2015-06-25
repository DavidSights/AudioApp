//
//  PostViewController.m
//  AudioApp
//
//  Created by Alex Santorineos on 6/16/15.
//  Copyright (c) 2015 DavidSights. All rights reserved.
//

#import "PostViewController.h"
#import <Parse/Parse.h>
#import "Post.h"

@interface PostViewController ()<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *commentTextView;
@property (weak, nonatomic) IBOutlet UIButton *postButton;

@end

@implementation PostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.commentTextView.delegate = self;
}

- (IBAction)onPostTapped:(UIButton *)sender {
    [self uploadPost];
}

- (void)uploadPost {
    PFUser *currentUser = [PFUser currentUser];
    NSData *fileData = [NSData dataWithContentsOfURL:self.recorder.url];
   NSString *colorString = [self hexStringFromColor:self.postColor];

    PFFile *file = [PFFile fileWithName:@"audio.m4a" data:fileData];
    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"An error occurred!"
                                                                message:[NSString stringWithFormat:@"Error: %@", error.localizedDescription]
                                                               delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
        else {
            PFObject *post = [PFObject objectWithClassName:@"Post"];
            [post setObject:file forKey:@"audio"];
            [post setObject:currentUser forKey:@"author"];
            [post setObject:colorString forKey:@"colorHex"];
            if ([self.commentTextView.text isEqualToString:@""]) {
                [post setObject:@"" forKey:@"descriptionComment"];
            }
            NSNumber *number = [[NSNumber alloc]initWithInteger:0];
            [post setObject:self.commentTextView.text forKey:@"descriptionComment"];
            [post setObject:@[] forKey:@"likes"];
            [post setObject:number forKey:@"loops"];
            [post setObject:number forKey:@"numOfComments"];
            [post setObject:number forKey:@"numOfLikes"];
            [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"Test1" object:self];
                    NSLog(@"post successful");
                }
                else{
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"An error occurred!"
                                                                        message:@"Please try posting again."
                                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alertView show];


                }
            }];

       }
    }];
 
    [self.tabBarController setSelectedIndex:0];
    [self.navigationController popToRootViewControllerAnimated:true];
    [self.recorder stop];
//    self.recorder = nil;
    [self.recorder deleteRecording];
}


- (NSString *)hexStringFromColor:(UIColor *)color {
    const CGFloat *components = CGColorGetComponents(color.CGColor);

    CGFloat r = components[0];
    CGFloat g = components[1];
    CGFloat b = components[2];

    return [NSString stringWithFormat:@"#%02lX%02lX%02lX",
            lroundf(r * 255),
            lroundf(g * 255),
            lroundf(b * 255)];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {

    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }

    return YES;
}


@end
