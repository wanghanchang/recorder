//
//  PNCAudioQueueRecorder.m
//  RecordWave
//
//  Created by 匹诺曹 on 2017/9/18.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import "PNCAudioQueueRecorder.h"
#import <AVFoundation/AVFoundation.h>

#define PNCMAX(a,b) (((a) > (b)) ? (a) : (b))

#define NUM_BUFFERS 5

#define BYTE_NUM 2048
#define SHORT_NUM 1024

#define FULL_VALUE  32767.0
#define HALF_VALUE 16383.5

static SInt64 currentByte;
static AudioStreamBasicDescription audioFormat;
static AudioQueueRef queue;
static AudioQueueBufferRef buffers[NUM_BUFFERS];
static AudioFileID audioFileID;

static PNCAudioQueueRecorder *QueneRC;

@interface PNCAudioQueueRecorder ()
{
    BOOL isNewData;
    float currentFloatData[3];
    dispatch_queue_t q;
}
@property (nonatomic) SInt16 *numData;
@end

@implementation PNCAudioQueueRecorder


void AudioInputCallback(
                        void *inUserData,
                        AudioQueueRef inAQ,
                        AudioQueueBufferRef inBuffer,
                        const AudioTimeStamp *inStartTime,
                        UInt32 inNumberPacketDescriptions,
                        const AudioStreamPacketDescription *inPacketDescs
                        ) {
    PNCAudioQueueRecorder *recorder = (__bridge PNCAudioQueueRecorder*)inUserData;
    //
    UInt32 ioBytes = audioFormat.mBytesPerPacket * inNumberPacketDescriptions;
    //
    SInt16 * data = (SInt16 *)inBuffer->mAudioData;
    //
    long size = inBuffer->mAudioDataByteSize / audioFormat.mBytesPerPacket;
    //
//    NSData *codeData = [[NSData alloc] initWithBytes:data length:size];
    
    [recorder onDataRefresh:data WithNumDataSize:(int)size];
    
    OSStatus status = AudioFileWriteBytes(audioFileID,
                                          false,
                                          currentByte,
                                          &ioBytes,
                                          inBuffer->mAudioData);
        if (status != noErr) {
            printf("Error");
            return;
    }
    currentByte += ioBytes;
    status = AudioQueueEnqueueBuffer(queue, inBuffer, 0, NULL);
    
}

+ (instancetype)shareRecorder {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        QueneRC = [[PNCAudioQueueRecorder alloc] init];
   });
    return QueneRC;
}

#pragma mark - Audio Setup
- (void)setupAudio {
    
    audioFormat.mSampleRate = 22050.0;
    audioFormat.mFormatID = kAudioFormatLinearPCM;
    audioFormat.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    audioFormat.mFramesPerPacket = 1;
    audioFormat.mChannelsPerFrame = 1;
    audioFormat.mBitsPerChannel = 16;
    audioFormat.mBytesPerFrame = audioFormat.mChannelsPerFrame * sizeof(SInt16);
    audioFormat.mBytesPerPacket = audioFormat.mFramesPerPacket * audioFormat.mBytesPerFrame;
}

- (void)prepareRecordeWithURL:(NSURL*)url {
    [self setupAudio];
    currentByte = 0;
    
    NSError *error;
    [[AVAudioSession sharedInstance] setActive:YES error:&error];
    NSAssert(error == nil, @"Error");
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:&error];
    NSAssert(error == nil, @"Error");

//创建音频缓存队列;CallBack回调数据;
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        if (granted) {
            OSStatus status;
            status = AudioQueueNewInput(&audioFormat,
                                        AudioInputCallback, (__bridge void*)self,
                                        CFRunLoopGetCurrent(),
                                        kCFRunLoopCommonModes,
                                        0,
                                        &queue);
            NSAssert(status == noErr, @"Error");
            
            for (int i = 0; i < NUM_BUFFERS; i++) {
                status = AudioQueueAllocateBuffer(queue, 2048, &buffers[i]);
                NSAssert(status == noErr, @"Error");
                status = AudioQueueEnqueueBuffer(queue, buffers[i], 0, NULL);
                NSAssert(status == noErr, @"Error");
            }
        
            status = AudioFileCreateWithURL((__bridge CFURLRef)url,
                                            kAudioFileWAVEType,
                                                 &audioFormat,
                                    kAudioFileFlags_EraseFile,
                                                &audioFileID);
            NSAssert(status == noErr, @"Error");
            
        }
    }];
}

- (void)startRecord {
    AudioQueueStart(queue, NULL);
    q = dispatch_queue_create("quene", NULL);
}


- (void)stopRecord {
    AudioQueueStop(queue, true);
    AudioQueueDispose(queue, true);
    AudioFileClose(audioFileID);
}

- (void)onDataRefresh:(SInt16 *)numData WithNumDataSize:(int)size {
//    NSLog(@"%@",[NSThread currentThread]);
    dispatch_async(q, ^{
        for (int i = 0 ; i < 2; i++) {
            int max = 0;
            for (int j = size / 2 * i; j < size / 2 * (i + 1); j ++ ) {
                max =  PNCMAX(max, numData[j]);
                currentFloatData[i] = max / FULL_VALUE;
            }
        }
        isNewData = YES;
    });
}

- (float)getCurrentData {
    if (isNewData == YES) {
        return currentFloatData[0];
        isNewData = NO;
    } else {
        return currentFloatData[1];
    }
}

@end



