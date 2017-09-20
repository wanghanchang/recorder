//
//  RecorderInterface.h
//  RecordWave
//
//  Created by 匹诺曹 on 2017/9/18.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import <Foundation/Foundation.h>

//typedef void(^RecordDataBlock)(SInt16* data);

@protocol RecorderInterface <NSObject>

- (void)prepareRecordeWithURL:(NSURL*)url;

//- (void)startRecordWithRecordData:(void(^)(SInt16* data))block;

- (void)startRecord;

- (void)stopRecord;

- (float)getCurrentData;


@end
