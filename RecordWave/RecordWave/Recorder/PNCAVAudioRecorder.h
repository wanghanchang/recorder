//
//  PNCAVAudioRecorder.h
//  RecordWave
//
//  Created by 匹诺曹 on 2017/9/18.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RecorderInterface.h"
@interface PNCAVAudioRecorder : NSObject <RecorderInterface>

+ (instancetype)shareRecorder;

@end
