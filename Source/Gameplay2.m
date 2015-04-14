//
//  Gameplay2.m
//  weiligame
//
//  Created by Olivia Li on 4/12/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Gameplay2.h"
#import "Grid.h"

@implementation Gameplay2

- (void) menu {
    [[CCDirector sharedDirector] replaceScene:[CCBReader loadAsScene:@"MainScene"]];
}
- (void) replay {
    CCScene *gameplay2Scene = [CCBReader loadAsScene:@"Gameplay2"];
    [[CCDirector sharedDirector] replaceScene:gameplay2Scene];
}
- (void) pause {
    CCScene *pauselayerScene = [CCBReader loadAsScene:@"Pauselayer"];
    [[CCDirector sharedDirector] replaceScene:pauselayerScene];
}
- (void) shuffle {
    CCLOG(@"shuffle button pressed");
}
- (void) pressedPause:(CCButton*) sender
{
    [[OALSimpleAudio sharedInstance] playEffect:@"Sounds/click.wav"];
    
    self.grid.paused = YES;
    self.grid.userInteractionEnabled = NO;
    
    _pausedLayer.visible = YES;
}

- (void) pressedContinue
{
    [[OALSimpleAudio sharedInstance] playEffect:@"Sounds/click.wav"];
    
    self.grid.paused = NO;
    self.grid.userInteractionEnabled = YES;
    
    _pausedLayer.visible = NO;
}

- (void) pressedGiveUp
{
    [[OALSimpleAudio sharedInstance] playEffect:@"Sounds/click.wav"];
    
    [self.animationManager runAnimationsForSequenceNamed:@"outro"];
}

@end
