//
//  Pauselayer.m
//  weiligame
//
//  Created by Olivia Li on 4/13/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Pauselayer.h"


@implementation Pauselayer

- (void) Continue
{
    self.visible = NO;
    _gameplay2.paused = NO;
    [_gameplay2 Continue];
    //self.grid.userInteractionEnabled = YES;
}

- (void) giveup
{
    [[OALSimpleAudio sharedInstance] playEffect:@"Sounds/click.wav"];
    [[CCDirector sharedDirector] replaceScene:[CCBReader loadAsScene:@"MainScene"]];}

@end
