//
//  Chain.m
//  weiligame
//
//  Created by Olivia Li on 4/14/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Chain.h"

@implementation Chain {
    NSMutableArray *_cookies;
}

- (void)addCookie:(Creature *)cookie {
    if (_cookies == nil) {
        _cookies = [NSMutableArray array];
    }
    [_cookies addObject:cookie];
}

- (NSArray *)cookies {
    return _cookies;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"type:%ld cookies:%@", (long)self.chainType, self.cookies];
}

@end
