//
//  PNCAudioQueueRecorder.h
//  RecordWave
//
//  Created by 匹诺曹 on 2017/9/18.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RecorderInterface.h"

//typedef void(^MyBlock)(NSMutableArray*array);


//typedef void(^ErrorHandleCallback)(int error);


@interface PNCAudioQueueRecorder : NSObject <RecorderInterface>


+ (instancetype)shareRecorder;

- (float)getCurrentData;

@end
