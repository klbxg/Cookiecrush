//
//  Pauselayer.m
//  weiligame
//
//  Created by Olivia Li on 4/13/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Pauselayer.h"
#import "Gameplay2.h"

@implementation Pauselayer
- (void) Continue
{
    [[Gameplay2 currentGameScene] pressedContinue];
}

- (void) GiveUp
{
    [[Gameplay2 currentGameScene] pressedGiveUp];
}

@end
