//
//  RCFileHandle.m
//  InstagramPlayer
//
//  Created by RC on 17/1/23.
//  Copyright © 2017年 RC. All rights reserved.
//

#import "RCFileHandle.h"

@interface RCFileHandle ()

@property (nonatomic, strong) NSFileHandle * writeFileHandle;
@property (nonatomic, strong) NSFileHandle * readFileHandle;

@end

@implementation RCFileHandle

+ (BOOL)createTempFile {
    NSFileManager * manager = [NSFileManager defaultManager];
    NSString * path = [NSString tempFilePath];
    if ([manager fileExistsAtPath:path]) {
        [manager removeItemAtPath:path error:nil];
    }
    return [manager createFileAtPath:path contents:nil attributes:nil];
}

+ (void)writeTempFileData:(NSData *)data {
    NSFileHandle * handle = [NSFileHandle fileHandleForWritingAtPath:[NSString tempFilePath]];
    [handle seekToEndOfFile];
    [handle writeData:data];
}

+ (NSData *)readTempFileDataWithOffset:(NSUInteger)offset length:(NSUInteger)length {
    NSFileHandle * handle = [NSFileHandle fileHandleForReadingAtPath:[NSString tempFilePath]];
    [handle seekToFileOffset:offset];
    return [handle readDataOfLength:length];
}

+ (void)cacheTempFileWithFileName:(NSString *)name {
    NSFileManager * manager = [NSFileManager defaultManager];
    NSString * cacheFolderPath = [NSString cacheFolderPath];
    if (![manager fileExistsAtPath:cacheFolderPath]) {
        [manager createDirectoryAtPath:cacheFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString * cacheFilePath = [NSString stringWithFormat:@"%@/%@", cacheFolderPath, name];
    BOOL success = [[NSFileManager defaultManager] copyItemAtPath:[NSString tempFilePath] toPath:cacheFilePath error:nil];
    NSLog(@"cache file : %@", success ? @"success" : @"fail");
}

+ (NSString *)cacheFileExistsWithURL:(NSURL *)url {
    NSString * cacheFilePath = [NSString stringWithFormat:@"%@/%@", [NSString cacheFolderPath], [NSString fileNameWithURL:url]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:cacheFilePath]) {
        return cacheFilePath;
    }
    return nil;
}

+ (BOOL)clearCache {
    NSFileManager * manager = [NSFileManager defaultManager];
    return [manager removeItemAtPath:[NSString cacheFolderPath] error:nil];
}

@end
