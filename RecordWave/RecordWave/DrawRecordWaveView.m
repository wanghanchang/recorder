//
//  DrawRecordWaveVIew.m
//  RecordWave
//
//  Created by 匹诺曹 on 2017/9/19.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import "DrawRecordWaveView.h"
#import "CommonUtils.h"
@implementation DrawRecordWaveView

#define KSIZE 20
static double _filterData[2048];


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)improveSpectrum {
    //实现数据偏移
    memset(_filterData, 0x0, sizeof(double) * 1024);
    if (self.dataArray.count < _wSize) {
        for (int i = 0 ; i < _wSize; i ++) {
            if (i < self.dataArray.count) {
                _filterData[i] = [self.dataArray[i] floatValue];
            } else {
                _filterData[i] = 0;
            }
        }
    } else {
        for (int i = 0 ; i < _wSize; i ++) {
            _filterData[i] = [self.dataArray[i + (_bias - _wSize)] floatValue];
        }
    }
}

- (void)drawRect:(CGRect)rect {
    [self improveSpectrum];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect majorRect = rect;
    int OffsetY = self.originOffsetY * 1.5;
//画时间轴
    for ( int i = -30; i < _wSize + 31; i++) {
        int value = _bias - _wSize;
        if (value < 0) {
            value = 0;
        }
        if (i % 30 == 0) {
            CGRect rect = CGRectMake(20, i / 30 * 45 - (value % 30 * 1.5) + 2, 40, 30);
            NSString *text= [CommonUtils translateTimeCount:(i + value) / 30];
            [[UIColor blackColor] set];
            [text drawInRect:rect withAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Arial" size:8.0]}];
            
            [[UIColor grayColor] set];
            CGContextFillRect(context, CGRectMake(0, i / 30 * 45 - (value % 30 * 1.5) + OffsetY, 10, 1));
            CGContextFillRect(context, CGRectMake(majorRect.size.width - 10, i / 30 * 45 - (value % 30 * 1.5) + OffsetY, 10, 1));
            
            CGContextFillRect(context, CGRectMake(0, i / 30 * 45  + (45.0 / 4.0) - (value % 30 * 1.5) + OffsetY, 5, 1));
            CGContextFillRect(context, CGRectMake(majorRect.size.width - 5, i / 30 * 45  + (45.0 / 4.0) - (value % 30 * 1.5) + OffsetY, 5, 1));
            
            CGContextFillRect(context, CGRectMake(0, i / 30 * 45  + (45.0 / 4.0 * 2.0)- (value % 30 * 1.5) + OffsetY, 5, 1));
            CGContextFillRect(context, CGRectMake(majorRect.size.width - 5, i / 30 * 45  + (45.0 / 4.0 * 2.0)- (value % 30 * 1.5) + OffsetY, 5, 1));
            
            CGContextFillRect(context, CGRectMake(0, i / 30 * 45  + (45.0 / 4.0 * 3.0) - (value % 30 * 1.5) + OffsetY, 5, 1));
            CGContextFillRect(context, CGRectMake(majorRect.size.width - 5, i / 30 * 45  + (45.0 / 4.0 * 3.0) - (value % 30 * 1.5) + OffsetY, 5, 1));
            
        }
    }

    
    //halfPath
    CGMutablePathRef halfPath = CGPathCreateMutable();
    CGFloat midX = rect.size.width / 3 + rect.origin.x + 15;
    CGAffineTransform xf = CGAffineTransformIdentity;
    CGPathMoveToPoint(halfPath, nil,midX,0);
    
    for ( int i = 0; i < _wSize; i++) {
        CGPathAddLineToPoint(halfPath, nil, midX - _filterData[i], i * 1.5);
    }
    CGPathAddLineToPoint(halfPath, nil, midX , _wSize * 1.5);
    //fullPath
    CGMutablePathRef fullPath = CGPathCreateMutable();
    CGPathAddPath(fullPath, &xf, halfPath);
    xf = CGAffineTransformTranslate(xf, rect.size.width - rect.size.width / 3 + 30, 0);
    xf = CGAffineTransformScale(xf, -1.0, 1.0);
    CGPathAddPath(fullPath, &xf, halfPath);
    
    CGContextAddPath(context, fullPath);
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    
    CGContextStrokePath(context);

    //画下上下线
    CGContextMoveToPoint(context, rect.origin.x, rect.origin.y);
    [[UIColor grayColor] set];
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y);
    
    CGContextMoveToPoint(context, rect.origin.x, rect.origin.y + rect.size.height);
    [[UIColor grayColor] set];
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
    CGContextStrokePath(context);
    
    CGContextRef context1 = UIGraphicsGetCurrentContext();
    CGContextAddPath(context1, fullPath);
    CGContextSetFillColorWithColor(context1,[UIColor redColor].CGColor);
    CGContextDrawPath(context1, kCGPathFill);
    CGPathRelease(fullPath);
}

@end
