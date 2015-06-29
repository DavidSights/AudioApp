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

    // Create an audio file to upload to Parse.
    PFFile *file = [PFFile fileWithName:@"audio.m4a" data:fileData];
    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Uh oh, there was an error."
                                                                message:@"Sorry, we couldn't publish your post. We'll work to fix this error ASAP. Please try posting again later." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
            [alertView show];
        } else {
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
                } else {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Uh oh, there was an error." message:@"Sorry, we couldn't publish your post. We'll work to fix this error ASAP. Please try posting again later." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                    [alertView show];
                    NSLog(@"There was an error publishing the user's post: %@", error.localizedDescription);
                }
            }];
       }
    }];
    [self.tabBarController setSelectedIndex:0];
    [self.navigationController popToRootViewControllerAnimated:true];
    [self.recorder stop];
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

// UITextView has no equivilent to -textFieldShouldReturn. This code provides that basic functionality.
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

-(void)textViewDidBeginEditing:(UITextView *)textView {
    if ([self.commentTextView.text  isEqual: @"Tap here to enter a description, or just tap below to publish your post!"]) {
        self.commentTextView.text = @"";
    }
}


@end
