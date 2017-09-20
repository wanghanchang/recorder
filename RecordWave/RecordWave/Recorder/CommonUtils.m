//
//  CommonUtils.m
//  RecordWave
//
//  Created by 匹诺曹 on 2017/9/19.
//  Copyright © 2017年 匹诺曹. All rights reserved.
//

#import "CommonUtils.h"

@implementation CommonUtils


+ (NSString *)generateFilePathWithFileName:(NSString *)fileName andFileManagerName:(NSString *)DirName isTxt:(BOOL)text {
    NSString *docPath = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) [0];
    
    NSString *dirPath = [NSString stringWithFormat:@"%@/%@/%@",docPath,DirName,fileName];
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:NSFileProtectionNone
                                                           forKey:NSFileProtectionKey];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dirPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:attributes error:nil];
        return [CommonUtils generateFilePathWithFileName:fileName andFileManagerName:DirName isTxt:text];
    } else {
        if (text) {
            return [dirPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@_info",fileName]];
        } else {
            return [dirPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",fileName]];
        }
    }
}


+ (NSString *)translateTimeCount:(int)secCount {
    
    NSString *tmphh = [NSString stringWithFormat:@"%d",secCount/3600];
    if ([tmphh length] == 1)
    {
        tmphh = [NSString stringWithFormat:@"0%@",tmphh];
    }
    NSString *tmpmm = [NSString stringWithFormat:@"%d",(secCount/60)%60];
    if ([tmpmm length] == 1)
    {
        tmpmm = [NSString stringWithFormat:@"0%@",tmpmm];
    }
    NSString *tmpss = [NSString stringWithFormat:@"%d",secCount%60];
    if ([tmpss length] == 1)
    {
        tmpss = [NSString stringWithFormat:@"0%@",tmpss];
    }
    return [NSString stringWithFormat:@"%@:%@:%@",tmphh,tmpmm,tmpss];
}

@end
