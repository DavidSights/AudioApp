//
//  EditViewController.m
//  AudioApp
//
//  Created by Alex Santorineos on 6/16/15.
//  Copyright (c) 2015 DavidSights. All rights reserved.
//

#import "EditViewController.h"

@interface EditViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>
@property AVAudioPlayer *player;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *timeButton;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property int recordTimeInt;
@property NSTimer *timer;
@end

@implementation EditViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.player = [[AVAudioPlayer alloc]initWithContentsOfURL:self.recorder.url error:nil];
    [self beginRecording];

}
-(void)viewWillAppear:(BOOL)animated{

    self.player = [[AVAudioPlayer alloc]initWithContentsOfURL:self.recorder.url error:nil];

    [self beginRecording];
}

-(void)beginRecording {
    [self.player play];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                  target:self
                                                selector:@selector(playingTime)
                                                userInfo:nil
                                                 repeats:YES];
}

-(NSTimeInterval)playingTime {

//    self.timeLabel.text = [NSString stringWithFormat:@"%.0f",self.player.currentTime];

    [self.timeButton setTitle:[NSString stringWithFormat:@"%.0f",self.player.currentTime] forState:UIControlStateNormal];

    return self.player.currentTime;
}

- (IBAction)onTimeButtonTapped:(id)sender {
    if (self.player.playing) {
        [self.player pause];
    }else if(!self.player.playing){
        [self.player play];

    }
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{

    return 6;

}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"filterCellID" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor redColor];
    return cell;

}


@end
