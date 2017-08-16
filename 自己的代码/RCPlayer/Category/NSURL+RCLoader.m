//
//  NSURL+RCLoader.m
//  InstagramPlayer
//
//  Created by RC on 17/1/23.
//  Copyright © 2017年 RC. All rights reserved.
//

#import "NSURL+RCLoader.h"

@implementation NSURL (RCLoader)

- (NSURL *)customSchemeURL {
    NSURLComponents * components = [[NSURLComponents alloc] initWithURL:self resolvingAgainstBaseURL:NO];
    components.scheme = @"streaming";
    return [components URL];
}

- (NSURL *)originalSchemeURL {
    NSURLComponents * components = [[NSURLComponents alloc] initWithURL:self resolvingAgainstBaseURL:NO];
    components.scheme = @"https";
    return [components URL];
}

@end
