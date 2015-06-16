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

@interface RecordViewController ()<AVAudioRecorderDelegate, AVAudioPlayerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property AVAudioRecorder *recorder;
@property AVAudioPlayer *player;
@property int recordTimeInt;

@property NSTimer *timer;

@end

@implementation RecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIBarButtonItem *editButton = [[UIBarButtonItem alloc]initWithTitle:@"X" style:UIBarButtonItemStylePlain target:self action:@selector(editButtonPressed:)];

    self.navigationItem.leftBarButtonItem = editButton;
    self.playButton.enabled = NO;

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = paths.lastObject;
    NSString *pathToSave = [documentPath stringByAppendingPathComponent:@".m4a"];
    // File URL
    NSURL *url = [NSURL fileURLWithPath:pathToSave];//FILEPATH];
    //set up sessions
    AVAudioSession *sessions = [AVAudioSession sharedInstance];
    [sessions setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    NSMutableDictionary *recordDictionary = [[NSMutableDictionary alloc]init];
    self.recorder = [[AVAudioRecorder alloc]initWithURL:url settings:recordDictionary error:nil];


    self.recorder.delegate = self;

    self.recorder.meteringEnabled = YES;
    [self.recorder prepareToRecord];
}


//times the recording
-(void)beginRecording {
    [self.recorder record];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                  target:self
                                                selector:@selector(recordingTime)
                                                userInfo:nil
                                                repeats:YES];
}

-(NSTimeInterval)recordingTime {
    if (self.recorder.currentTime >= 9) {
        [self.recorder stop];
        [self.timer invalidate];
        //        self.recordTimeInt = 0;
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"done" message:@"tooo long" delegate:nil cancelButtonTitle:@"cancel" otherButtonTitles:nil, nil];
        //        count = nil;
        
        [alert show];
    }
    self.timeLabel.text = [NSString stringWithFormat:@"%.0f",self.recorder.currentTime];

    return self.recorder.currentTime;
}




#pragma marks IBAction
- (void)editButtonPressed:(id)sender
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Discard" message:nil preferredStyle:UIAlertControllerStyleAlert];
    //adding text field to alert controller

    //cancels alert controller
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    //
    //saves what you wrote
    UIAlertAction *discardAction =  [UIAlertAction actionWithTitle:@"Discard" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

        AVAudioSession *sessions = [AVAudioSession sharedInstance];
        [sessions setActive:NO error:nil];
        [self.recorder stop];
        [self.recorder deleteRecording];

        [self.tabBarController setSelectedIndex:0];
    }];

    //add cancelAction variable to alertController
    [alertController addAction:cancelAction];


    [alertController addAction:discardAction];


    //activates alertcontroler
    [self presentViewController:alertController animated:true completion:nil];
    
    
    
    

}
- (IBAction)onRecordPauseTapped:(id)sender {
    if (self.player.playing)
    {
        [self.player stop];
    }

    //if the recorder is not recording
    if (!self.recorder.recording) {

        //record
        AVAudioSession *sessions = [AVAudioSession sharedInstance];
        [sessions setActive:YES error:nil];
        [self beginRecording];
        //        [self.recorder record];
        [self.recordButton setTitle:@"Pause" forState:UIControlStateNormal];

    }
    else{
        [self.recorder pause];
        [self.recordButton setTitle:@"Record" forState:UIControlStateNormal];
        [self.timer invalidate];
        self.playButton.enabled = true;
    }
}


-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    [self.recordButton setTitle:@"record" forState:UIControlStateNormal];
    self.playButton.enabled = YES;
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"done" message:@"Finished playing" delegate:nil cancelButtonTitle:@"cancel" otherButtonTitles:nil, nil];

    [alert show];
    
    
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    EditViewController *dVc = segue.destinationViewController;
    dVc.recorder = self.recorder;

}



@end
