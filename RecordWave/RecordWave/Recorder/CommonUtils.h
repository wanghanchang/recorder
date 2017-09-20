//
//  CommonUtils.h
//  RecordWave
//
//  Created by 匹诺曹 on 2017/9/19.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommonUtils : NSObject

+ (NSString *)generateFilePathWithFileName:(NSString *)fileName andFileManagerName:(NSString *)DirName isTxt:(BOOL)text;

+ (NSString *)translateTimeCount:(int)secCount;

@end
