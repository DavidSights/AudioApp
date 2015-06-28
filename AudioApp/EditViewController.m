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

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *timeButton;
@property (weak, nonatomic) IBOutlet UIButton *yellowColorButton;
@property (weak, nonatomic) IBOutlet UIButton *redColorButton;
@property (weak, nonatomic) IBOutlet UIButton *greenColorButton;
@property (weak, nonatomic) IBOutlet UIButton *blackColorButton;
@property (weak, nonatomic) IBOutlet UIButton *blueColorButton;
@property (weak, nonatomic) IBOutlet UIButton *pinkColorButton;
@property (weak, nonatomic) IBOutlet UIButton *purpleColorButton;
@property (weak, nonatomic) IBOutlet UIView *audioView;
@property AVAudioPlayer *player;
@property int recordTimeInt;
@property NSTimer *timer;
@property UIColor *pink;

@end

@implementation EditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.player.delegate = self;
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc]initWithTitle:@"Restart" style:UIBarButtonItemStylePlain target:self action:@selector(editButtonPressed:)];
    self.navigationItem.leftBarButtonItem = editButton;
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
    self.yellowColorButton.backgroundColor = [UIColor colorWithRed:255/255.0 green:248/255.0 blue:196/255.0 alpha:1.0];
    self.pink = [UIColor colorWithRed:255/255.0 green:187/255.0 blue:208/255.0 alpha:1.0];
    self.pinkColorButton.backgroundColor = self.pink;
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

    // Make color buttons circles.
    self.yellowColorButton.layer.cornerRadius = self.yellowColorButton.frame.size.width / 2;
    self.blackColorButton.layer.cornerRadius = self.blackColorButton.frame.size.width / 2;
    self.redColorButton.layer.cornerRadius = self.redColorButton.frame.size.width / 2;
    self.greenColorButton.layer.cornerRadius = self.greenColorButton.frame.size.width / 2;
    self.purpleColorButton.layer.cornerRadius = self.greenColorButton.frame.size.width / 2;
    self.pinkColorButton.layer.cornerRadius = self.pinkColorButton.frame.size.width / 2;
    self.blueColorButton.layer.cornerRadius = self.blueColorButton.frame.size.width / 2;
}

- (void)viewDidAppear:(BOOL)animated {
}

- (void)editButtonPressed:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Restart" message:@"Are you sure you want to restart the recording? Your current recording will be lost." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *restartAction =  [UIAlertAction actionWithTitle:@"Restart" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        // User decided to go back and start a new recording.
        AVAudioSession *sessions = [AVAudioSession sharedInstance];
        [sessions setActive:NO error:nil];
        [self.player stop];
        [self.player prepareToPlay];
        [self.recorder stop];
        [self.recorder deleteRecording];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:restartAction];
    [self presentViewController:alertController animated:true completion:nil];
}

- (IBAction)onTimeButtonTapped:(id)sender {
    if (self.player.playing) {
        [self.player pause];
    } else if (!self.player.playing){
        AVAudioSession *session = [AVAudioSession sharedInstance];
        NSError *setCategoryError = nil;
        if (![session setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:&setCategoryError]) {
            NSLog(@"%@^^^^^^", setCategoryError);
        }
        [self.player play];
    }
}

- (IBAction)onColorButtonTapped:(UIButton *)sender {
    self.audioView.backgroundColor = sender.backgroundColor;
}

#pragma mark - Audio

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [player stop];
    [player prepareToPlay];
}

- (void)playRecordedAudio {
    self.player.numberOfLoops = -1;
    [self.player play];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(playingTime) userInfo:nil repeats:YES];
}

- (NSTimeInterval)playingTime {
    [self.timeButton setTitle:[NSString stringWithFormat:@"%.0f",self.player.currentTime] forState:UIControlStateNormal];
    return self.player.currentTime;
}

#pragma mark - TableView Customization

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 6;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"filterCellID" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithRed:249/255.0 green:217.0/255 blue:119/255.0 alpha:1.0];
    cell.layer.cornerRadius = cell.frame.size.width/2;
    return cell;
}

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

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    PostViewController *dvc = segue.destinationViewController;
    dvc.recorder = self.recorder;
    dvc.postColor = self.audioView.backgroundColor;
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.player stop];
}

@end