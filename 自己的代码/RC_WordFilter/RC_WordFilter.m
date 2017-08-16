//
//  RC_WordFilter.m
//  iOSLivU
//
//  Created by RC on 2017/6/30.
//  Copyright © 2017年 TCH. All rights reserved.
//

#import "RC_WordFilter.h"
#include <stdio.h>

#define EXIST @"isExists"

@interface RC_WordFilter ()

@property (nonatomic,strong) NSMutableDictionary *root;

@property (nonatomic,assign) BOOL isFilterClose;

@end

@implementation RC_WordFilter

- (void)initFilter:(NSString *)filepath{
    
    self.root = [NSMutableDictionary dictionary];
    char word[1024];
    FILE *fp;
    char *p;
    
    //打开文件
    fp = fopen([filepath UTF8String], "r");
    
    //按行读取内容
    while (fgets(word, sizeof(word), fp)) {
        p = word;
        
        while (*p != 0) {
            if (*p == '\r' || *p == '\n' || *p == ' ') {
                *p = 0;
                break;
            }
            p++;
        }
        
        //插入字符，构造节点
        [self insertWords:[NSString stringWithUTF8String:word]];
    }
}

-(void)insertWords:(NSString *)words{
    NSMutableDictionary *node = self.root;
    
    for (int i = 0; i < words.length; i ++) {
        NSString *word = [words substringWithRange:NSMakeRange(i, 1)];
        
        if (node[word] == nil) {
            node[word] = [NSMutableDictionary dictionary];
        }
        
        node = node[word];
    }
    
    //敏感词最后一个字符标识
    node[EXIST] = [NSNumber numberWithInt:1];
}

- (NSString *)filter:(NSString *)str{
    
    if (self.isFilterClose || !self.root) {
        return str;
    }
    
    NSMutableString *result = result = [str mutableCopy];
    
    for (int i = 0; i < str.length; i ++) {
        NSString *subString = [str substringFromIndex:i];
        NSMutableDictionary *node = [self.root mutableCopy] ;
        int num = 0;
        
        for (int j = 0; j < subString.length; j ++) {
            NSString *word = [subString substringWithRange:NSMakeRange(j, 1)];
            
            if (node[word] == nil) {
                break;
            }else{
                num ++;
                node = node[word];
            }
            
            //敏感词匹配成功
            if ([node[EXIST]integerValue] == 1) {
                
                NSMutableString *symbolStr = [NSMutableString string];
                for (int k = 0; k < num; k ++) {
                    [symbolStr appendString:@"*"];
                }
                
                [result replaceCharactersInRange:NSMakeRange(i, num) withString:symbolStr];
                
                i += j;
                break;
            }
        }
    }
    
    return result;
}

- (void)freeFilter{
    self.root = nil;
}

- (void)stopFilter:(BOOL)b{
    self.isFilterClose = b;
}

@end
