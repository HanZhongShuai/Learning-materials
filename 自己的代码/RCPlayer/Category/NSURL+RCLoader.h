//
//  NSURL+RCLoader.h
//  InstagramPlayer
//
//  Created by RC on 17/1/23.
//  Copyright © 2017年 RC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (RCLoader)

/**
 *  自定义scheme
 */
- (NSURL *)customSchemeURL;

/**
 *  还原scheme
 */
- (NSURL *)originalSchemeURL;

@end
