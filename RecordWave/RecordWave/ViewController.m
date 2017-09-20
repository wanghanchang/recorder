//
//  ViewController.m
//  RecordWave
//
//  Created by 匹诺曹 on 2017/9/18.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import "ViewController.h"
#import "RecorderInterface.h"
#import "PNCAVAudioRecorder.h"
#import "PNCAudioQueueRecorder.h"
#import "CommonUtils.h"
#import "DrawRecordWaveView.h"

typedef NS_ENUM(NSInteger,RecorderType){
    Queue_recorder = 0,
    Audio_recorder = 1
};

@interface ViewController () {
    id<RecorderInterface> currentRecorder;
}

@property (nonatomic,strong) CADisplayLink *link;
@property (nonatomic,strong) DrawRecordWaveView *draw;

@end

@implementation ViewController

//项目的一部分抽出来提供录音波纹思路参考
//分别用AVAduioRecorder 和 AudioQuene 实现录音的波形图;
//前者拿实时缓存直接自定义处理数据; 后者直接调用系统函数;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.link = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateTime)];
    self.link.paused = YES;
    self.link.frameInterval = 2.0;
    [self.link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];

    
    self.draw = [[DrawRecordWaveView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 270)];
    //每秒刷新30次,30个数据,单位高度:45;
    self.draw.wSize = 270 / 1.5;
    [self.view addSubview:self.draw];
    [self refreshData];
    //默认AudioQueneRecorder
    [self loadRecorder:Queue_recorder];
}

- (void)refreshData {
    self.draw.dataArray = [[NSMutableArray alloc] initWithCapacity:30];
    self.draw.bias = 0;
    [self.draw setNeedsDisplay];
}

- (void)loadRecorder:(RecorderType)type {
    if (type == Queue_recorder) {
        currentRecorder = [PNCAudioQueueRecorder shareRecorder];
    } else {
        currentRecorder = [PNCAVAudioRecorder shareRecorder];
    }
}

- (IBAction)stopRecord:(id)sender {
    [currentRecorder stopRecord];
    _link.paused = YES;
}

- (IBAction)RecorderTypeChanged:(id)sender {
    UISegmentedControl *sg = (UISegmentedControl*)sender;
    [self loadRecorder:sg.selectedSegmentIndex];
    NSLog(@"recorder has switched to \n%@",[currentRecorder class]);
    [self start];
}

- (IBAction)startRecord:(id)sender {
    [self start];
}

- (void)start {
    [self refreshData];
    _link.paused = NO;
    NSString *path = [CommonUtils generateFilePathWithFileName:@"test1" andFileManagerName:@"test" isTxt:NO];
    NSLog(@"Your Record File Is At Path \n%@",path);
    [currentRecorder prepareRecordeWithURL:[NSURL URLWithString:[path stringByAppendingString:@".wav"]]];
    [currentRecorder startRecord];
}

- (void)updateTime {
    self.draw.bias += 1.0;
    float creationFloat = 80.0f;
    float width =  [currentRecorder getCurrentData] * creationFloat;
//    NSLog(@"%.f",width);
    [self.draw.dataArray addObject:[NSNumber numberWithFloat:width]];
    [self.draw setNeedsDisplay];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
