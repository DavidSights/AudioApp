//
//  RecordViewController.m
//  AudioApp
//
//  Created by Alex Santorineos on 6/16/15.
//  Copyright (c) 2015 DavidSights. All rights reserved.
//

#import "RecordViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "EditViewController.h"

@interface RecordViewController () <AVAudioRecorderDelegate, AVAudioPlayerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property AVAudioRecorder *recorder;
@property AVAudioPlayer *player;
@property int recordTimeInt;
@property NSTimer *timer;
@property UIColor *blue, *yellow, *red, *purple, *green, *darkBlue, *darkYellow, *darkRed, *darkPurple, *darkGreen;
@property (weak, nonatomic) IBOutlet UIButton *resetButton;

@end

@implementation RecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpRecording];

    // App color theme.
    self.blue = [UIColor colorWithRed:160/255.0 green:215/255.0 blue:231/255.0 alpha:1.0];
    self.yellow = [UIColor colorWithRed:249/255.0 green:217/255.0 blue:119/255.0 alpha:1.0];
    self.red = [UIColor colorWithRed:205/255.0 green:124/255.0 blue:135/255.0 alpha:1.0];
    self.purple = [UIColor colorWithRed:176/255.0 green:150/255.0 blue:193/255.0 alpha:1.0];
    self.green = [UIColor colorWithRed:124/255.0 green:191/255.0 blue:183/255.0 alpha:1.0];
    self.darkBlue = [UIColor colorWithRed:83/255.0 green:153/255.0 blue:174/255.0 alpha:1.0];
    self.darkYellow = [UIColor colorWithRed:204/255.0 green:164/255.0 blue:42/255.0 alpha:1.0];
    self.darkRed = [UIColor colorWithRed:166/255.0 green:81/255.0 blue:92/255.0 alpha:1.0];
    self.darkPurple = [UIColor colorWithRed:121/255.0 green:192/255.0 blue:140/255.0 alpha:1.0];
    self.darkGreen = [UIColor colorWithRed:75/255.0 green:151/255.0 blue:142/255.0 alpha:1.0];
    self.resetButton.alpha = 0;
}

-(void)viewWillAppear:(BOOL)animated{
    [self setUpRecording];
    // Reset button, reset timer.
    [self resetButtonStyle];
}

-(void)viewDidAppear:(BOOL)animated {
//    if (self.recorder != nil) {
//        [self.recorder stop];
//        [self.recorder deleteRecording];
//    }
    [self setUpRecording];
    self.recordButton.layer.cornerRadius = self.recordButton.frame.size.width/2; // Called here instead of view did load because storyboard dimensions not set in view did load.
}

#pragma mark - Buttons

- (IBAction)recordButtonPressed:(id)sender {
    if (![self.recordButton.titleLabel.text  isEqual: @"Done!"]) {
        NSLog(@"Button pressed. Timer at %f seconds, so began recording again.", self.recorder.currentTime);
        if (self.player.playing) { // Stop audio from playing.
            [self.player stop];
        }
        if (!self.recorder.recording) { // Set up a new recording.
            AVAudioSession *sessions = [AVAudioSession sharedInstance];
            [sessions setActive:YES error:nil];
            [self beginRecording];
            self.navigationItem.rightBarButtonItem.enabled = false;
            [UIView animateWithDuration:0.25 animations:^{
                self.recordButton.backgroundColor = self.red;
                [self.recordButton setTitle:[NSString stringWithFormat:@"%.0f",self.recorder.currentTime] forState:UIControlStateNormal];
            }];
//            [self.recordButton setTitleColor:self.darkRed forState:UIControlStateNormal];
        } else { // Already recordng - pause recording.
            [self.recorder pause];
            [self.timer invalidate];
            self.navigationItem.rightBarButtonItem.enabled = true;
            [UIView animateWithDuration:0.25 animations:^{
                self.recordButton.backgroundColor = [UIColor colorWithRed:234/255.0 green:187/255.0 blue:194/255.0 alpha:1.0];
//                [self.recordButton setTitle:@"Record" forState:UIControlStateNormal];
            }];
//            [self.recordButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            self.resetButton.alpha = 1;
        }
    }
}

- (IBAction)resetButtonPressed:(id)sender {
    [self.recorder stop];
    [self.recorder deleteRecording];
    [self.recorder prepareToRecord];
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(resetButtonStyle) userInfo:nil repeats:NO];
}

-(void) resetButtonStyle {
    [self.recordButton setTitle:@"Record" forState:UIControlStateNormal];
    [self.recordButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [UIView animateWithDuration:0.25 animations:^{
        self.recordButton.backgroundColor = [UIColor colorWithRed:234/255.0 green:187/255.0 blue:194/255.0 alpha:1.0];
    }];
    self.resetButton.alpha = 0;
}

#pragma mark - Recording Audio

- (void) setUpRecording {
    self.navigationItem.rightBarButtonItem.enabled = false;
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc]initWithTitle:@"✕" style:UIBarButtonItemStylePlain target:self action:@selector(editButtonPressed:)];
    self.navigationItem.leftBarButtonItem = editButton;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = paths.lastObject;
    NSString *pathToSave = [documentPath stringByAppendingPathComponent:@".m4a"];
    NSURL *url = [NSURL fileURLWithPath:pathToSave];
    AVAudioSession *sessions = [AVAudioSession sharedInstance];
    [sessions setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    NSMutableDictionary *recordDictionary = [[NSMutableDictionary alloc]init];
    self.recorder = [[AVAudioRecorder alloc]initWithURL:url settings:recordDictionary error:nil];
    self.recorder.delegate = self;
    self.recorder.meteringEnabled = YES;
    [self.recorder prepareToRecord];
}

- (void) beginRecording {
    [self.recorder record];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(recordingTime) userInfo:nil repeats:YES];
}

//- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
//    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"done" message:@"Finished playing" delegate:nil cancelButtonTitle:@"cancel" otherButtonTitles:nil, nil];
//    [alert show];
//}

- (NSTimeInterval) recordingTime {
    if (self.recorder.currentTime >= 9) {
//        [self.recorder pause];
        [self.recorder stop];
        [self.timer invalidate];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Limit Reached" message:@"Your recording has reached its 9 second limit." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        self.navigationItem.rightBarButtonItem.enabled = true;
        [alert show];
    } else {
        [self.recordButton setTitle:[NSString stringWithFormat:@"%.0f",self.recorder.currentTime] forState:UIControlStateNormal];
        NSLog(@"Updated timer button to: %f", self.recorder.currentTime);
    }
    return self.recorder.currentTime;
}

- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    [UIView animateWithDuration:0.25 animations:^{
        self.recordButton.backgroundColor = [UIColor colorWithRed:239/255.0 green:239/255.0 blue:244/255.0 alpha:1.0];
    }];
    [self.recordButton setTitle:@"Done!" forState:UIControlStateNormal];
    [self.recordButton setTitleColor:[UIColor colorWithRed:156/255.0 green:234/255.0 blue:135/255.0 alpha:1.0] forState:UIControlStateNormal];
}

#pragma mark - Segue

- (void)editButtonPressed:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Discard" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *discardAction =  [UIAlertAction actionWithTitle:@"Discard" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        AVAudioSession *sessions = [AVAudioSession sharedInstance];
        [sessions setActive:NO error:nil];
        [self.recorder stop];
        [self.recorder deleteRecording];
        [self.tabBarController setSelectedIndex:0];
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:discardAction];
    [self presentViewController:alertController animated:true completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    EditViewController *dVc = segue.destinationViewController;
    dVc.recorder = self.recorder;
}

@end
