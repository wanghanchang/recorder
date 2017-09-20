//
//  DrawRecordWaveVIew.h
//  RecordWave
//
//  Created by 匹诺曹 on 2017/9/19.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DrawRecordWaveView : UIView

@property float *drawBuffer;
@property int drawBufferCount;

@property int wSize;
@property int bias;
@property int originOffsetY;

@property (nonatomic,strong) NSMutableArray *dataArray;

- (instancetype)initWithFrame:(CGRect)frame;

@end
