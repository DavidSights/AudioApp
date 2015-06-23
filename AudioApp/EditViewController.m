//
//  EditViewController.m
//  AudioApp
//
//  Created by Alex Santorineos on 6/16/15.
//  Copyright (c) 2015 DavidSights. All rights reserved.
//

#import "EditViewController.h"
#import "PostViewController.h"

@interface EditViewController ()<UICollectionViewDataSource, UICollectionViewDelegate,AVAudioPlayerDelegate>

@property (weak, nonatomic) IBOutlet UIView *viewOne;
@property AVAudioPlayer *player;
@property (weak, nonatomic) IBOutlet UIButton *timeButton;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property int recordTimeInt;
@property NSTimer *timer;
@property (weak, nonatomic) IBOutlet UIButton *yellowColorButton;
@property (weak, nonatomic) IBOutlet UIButton *redColorButton;
@property (weak, nonatomic) IBOutlet UIButton *greenColorButton;
@property (weak, nonatomic) IBOutlet UIButton *blackColorButton;
@property (weak, nonatomic) IBOutlet UIButton *blueColorButton;
@property (weak, nonatomic) IBOutlet UIButton *orangeColorButton;
@property (weak, nonatomic) IBOutlet UIButton *purpleColorButton;

@end

@implementation EditViewController



- (void)viewDidLoad {

    self.player.delegate = self;
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc]initWithTitle:@"Restart" style:UIBarButtonItemStylePlain target:self action:@selector(editButtonPressed:)];

    self.navigationItem.leftBarButtonItem = editButton;

    [super viewDidLoad];
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *setCategoryError = nil;
    if (![session setCategory:AVAudioSessionCategoryPlayback
                  withOptions:AVAudioSessionCategoryOptionMixWithOthers
                        error:&setCategoryError]) {
        NSLog(@"%@+++", setCategoryError);
    }

    self.player = [[AVAudioPlayer alloc]initWithContentsOfURL:self.recorder.url error:nil];
    [self.player prepareToPlay];
    [self playRecordedAudio];

    // Make color buttons circles.
    self.yellowColorButton.layer.cornerRadius = self.yellowColorButton.frame.size.width / 3;
    self.blackColorButton.layer.cornerRadius = self.blackColorButton.frame.size.width / 3;
    self.redColorButton.layer.cornerRadius = self.redColorButton.frame.size.width / 3;
    self.greenColorButton.layer.cornerRadius = self.greenColorButton.frame.size.width / 3;
    self.purpleColorButton.layer.cornerRadius = self.greenColorButton.frame.size.width / 3;
    self.orangeColorButton.layer.cornerRadius = self.orangeColorButton.frame.size.width / 3;
    self.blueColorButton.layer.cornerRadius = self.blueColorButton.frame.size.width / 3;
}
- (void)editButtonPressed:(id)sender
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Restart" message:@"Are you sure you want to restart the recording?" preferredStyle:UIAlertControllerStyleAlert];
    //adding text field to alert controller

    //cancels alert controller
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    //
    //saves what you wrote
    UIAlertAction *restartAction =  [UIAlertAction actionWithTitle:@"Restart" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

        AVAudioSession *sessions = [AVAudioSession sharedInstance];
        [sessions setActive:NO error:nil];
        [self.player stop];
        [self.player prepareToPlay];
        [self.player stop];
        [self.recorder stop];
        [self.recorder deleteRecording];

        [self.navigationController popToRootViewControllerAnimated:YES];
    }];

    //add cancelAction variable to alertController
    [alertController addAction:cancelAction];


    [alertController addAction:restartAction];


    //activates alertcontroler
    [self presentViewController:alertController animated:true completion:nil];
    
}

- (void)viewWillAppear:(BOOL)animated {

    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *setCategoryError = nil;
    if (![session setCategory:AVAudioSessionCategoryPlayback
                  withOptions:AVAudioSessionCategoryOptionMixWithOthers
                        error:&setCategoryError]) {
        NSLog(@"%@)))))))))", setCategoryError);
    }
    self.player = [[AVAudioPlayer alloc]initWithContentsOfURL:self.recorder.url error:nil];
    [self.player prepareToPlay];
    [self playRecordedAudio];
}

- (void)playRecordedAudio {
    self.player.numberOfLoops = -1;
    [self.player play];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                  target:self
                                                selector:@selector(playingTime)
                                                userInfo:nil
                                                 repeats:YES];
}

- (NSTimeInterval)playingTime {
    [self.timeButton setTitle:[NSString stringWithFormat:@"%.0f",self.player.currentTime] forState:UIControlStateNormal];
    return self.player.currentTime;
}

- (IBAction)onTimeButtonTapped:(id)sender {
    if (self.player.playing) {
        [self.player pause];
    } else if (!self.player.playing){

        AVAudioSession *session = [AVAudioSession sharedInstance];
        NSError *setCategoryError = nil;
        if (![session setCategory:AVAudioSessionCategoryPlayback
                      withOptions:AVAudioSessionCategoryOptionMixWithOthers
                            error:&setCategoryError]) {
            NSLog(@"%@^^^^^^", setCategoryError);
        }
        [self.player play];
    }
}

- (IBAction)onColorButtonTapped:(UIButton *)sender {
    self.viewOne.backgroundColor = sender.backgroundColor;
}

#pragma mark - TableView

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 6;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"filterCellID" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithRed:249/255.0 green:217.0/255 blue:119/255.0 alpha:1.0];
    cell.layer.cornerRadius = cell.frame.size.width/2;
    return cell;
}

#pragma marks delegateMethod

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:0.5];
    AVAudioSession *session = [AVAudioSession sharedInstance];

    NSError *setCategoryError = nil;
    if (![session setCategory:AVAudioSessionCategoryPlayback
                  withOptions:AVAudioSessionCategoryOptionMixWithOthers
                        error:&setCategoryError]) {

        NSLog(@"%@***", setCategoryError);
        // handle error
    }
    self.player.currentTime = 0;
    [self.player play];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor redColor];
    self.player.currentTime = 0;
    [self.player play];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.player stop];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    PostViewController *dvc = segue.destinationViewController;
    dvc.recorder = self.recorder;
    dvc.postColor = self.viewOne.backgroundColor;
}
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [player stop];
    [player prepareToPlay];
}
@end