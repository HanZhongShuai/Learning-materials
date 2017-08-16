//
//  NSString+RCLoader.h
//  InstagramPlayer
//
//  Created by RC on 17/1/23.
//  Copyright © 2017年 RC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (RCLoader)

/**
 *  临时文件路径
 */
+ (NSString *)tempFilePath;

/**
 *  缓存文件夹路径
 */
+ (NSString *)cacheFolderPath;

/**
 *  获取网址中的文件名
 */
+ (NSString *)fileNameWithURL:(NSURL *)url;

@end
