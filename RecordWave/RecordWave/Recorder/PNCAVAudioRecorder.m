//
//  PNCAVAudioRecorder.m
//  RecordWave
//
//  Created by 匹诺曹 on 2017/9/18.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import "PNCAVAudioRecorder.h"
#import <AVFoundation/AVFoundation.h>

@interface PNCAVAudioRecorder ()
@property (nonatomic,strong) AVAudioRecorder *recorder;
@end
static PNCAVAudioRecorder *AudioRC;

@implementation PNCAVAudioRecorder

+ (instancetype)shareRecorder {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        AudioRC = [[PNCAVAudioRecorder alloc] init];
    });
    return AudioRC;
}

- (void)prepareRecordeWithURL:(NSURL*)url {
    NSError *error = nil;
    AVAudioSession * audioSession = [AVAudioSession sharedInstance]; //得到AVAudioSession单例对象
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error: &error];//设置类别,表示该应用同时支持播放和录音
    [audioSession setActive:YES error: &error];//启动音频会话管理,此时会阻断后台音乐的播放.

    NSMutableDictionary *recordSetting = [NSMutableDictionary dictionary];
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:22050.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
    [recordSetting setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    [recordSetting setValue:[NSNumber numberWithBool:YES] forKey:AVLinearPCMIsBigEndianKey];
    [recordSetting setValue:[NSNumber numberWithBool:YES] forKey:AVLinearPCMIsFloatKey];
    
    self.recorder = [[AVAudioRecorder alloc] initWithURL:url settings:recordSetting error:&error];
    self.recorder.meteringEnabled = YES;
    [self.recorder prepareToRecord];
}

- (float)RMS {
    [_recorder updateMeters];
    float   level;                // The linear 0.0 .. 1.0 value we need.
    float   minDecibels = -80.0f; // Or use -60dB, which I measured in a silent room.
    float   decibels = [_recorder averagePowerForChannel:0];
    if (decibels < minDecibels) {
        level = 0.0f;
    } else if (decibels >= 0.0f) {
        level = 1.0f;
    } else {
        float   root            = 2.0f;
        float   minAmp          = powf(10.0f, 0.05f * minDecibels);
        float   inverseAmpRange = 1.0f / (1.0f - minAmp);
        float   amp             = powf(10.0f, 0.05f * decibels);
        float   adjAmp          = (amp - minAmp) * inverseAmpRange;
        level = powf(adjAmp, 1.0f / root);
    }
    return level;
}


- (void)startRecord {
    [_recorder record];
}

- (void)stopRecord {
    if ([_recorder isRecording]) {
        [_recorder stop];
    }
}

- (float)getCurrentData {
    return [self RMS];
}



@end
