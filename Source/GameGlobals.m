//
//  GameGlobel.m
//  weiligame
//
//  Created by Olivia Li on 4/29/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "GameGlobals.h"

static __strong GameGlobals* _globals;

@implementation GameGlobals

+ (GameGlobals*) globals
{
    if (!_globals)
    {
        _globals = [[GameGlobals alloc] init];
    }
    
    return _globals;
}

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    [self load];
    
    return self;
}

- (void) load
{
    NSUserDefaults* d = [NSUserDefaults standardUserDefaults];
    
    _highScore1 = [[d objectForKey:@"highScore1"] intValue];
    _lastScore1 = [[d objectForKey:@"lastScore1"] intValue];
    _highScore2 = [[d objectForKey:@"highScore2"] intValue];
    _lastScore2 = [[d objectForKey:@"lastScore2"] intValue];
}

- (void) store
{
    NSUserDefaults* d = [NSUserDefaults standardUserDefaults];
    
    [d setObject:[NSNumber numberWithInt:_highScore1] forKey:@"highScore1"];
    [d setObject:[NSNumber numberWithInt:_highScore2] forKey:@"highScore2"];
    [d setObject:[NSNumber numberWithInt:_lastScore1] forKey:@"lastScore1"];
    [d setObject:[NSNumber numberWithInt:_lastScore2] forKey:@"lastScore2"];
}

- (void) setLastScore1:(int)lastScore1
{
    if (lastScore1 > _highScore1)
    {
        _highScore1 = lastScore1;
    }
    //_lastScore1 = lastScore1;
    CCLOG(@"%d, %d, %d", _lastScore1, _highScore1, lastScore1);
}
- (void) setLastScore2:(int)lastScore2
{
    if (lastScore2 > _highScore2) {
        _highScore2 = lastScore2;
    }
    //_lastScore2 = lastScore2;
    CCLOG(@"%d, %d, %d", _lastScore2, _highScore2, lastScore2);    
}

@end
