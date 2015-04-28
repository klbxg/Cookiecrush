//
//  Gameplay2.m
//  weiligame
//
//  Created by Olivia Li on 4/12/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Gameplay2.h"
#import "Grid.h"
#import "Pauselayer.h"

static __weak Gameplay2* _currentGameScene;

@implementation Gameplay2{
    Grid* _grid1;
    int secs;
}

+ (Gameplay2*) currentGameScene
{
    return _currentGameScene;
}

- (void) didLoadFromCCB
{
    _grid1.states = true;
    _currentGameScene = self;
    secs = 180;
    [_grid1 set_scoreLabel1:__timescore];
    //[_grid set_moveLabel1:__timeLabel];
    [self schedule:@selector(updateTimeDisplay:) interval:1];
    
    self.grid.paused = YES;
}

- (void) updateTimeDisplay:(CCTime)delta
{
    secs -= 1;
    NSString* timeStr = NULL;
    if (secs >= 180) timeStr = @"3:00";
    else if (secs >= 120) {
        timeStr = [NSString stringWithFormat:@"2:%02d", secs%60];
    }
    else if (secs >= 60) {
        timeStr = [NSString stringWithFormat:@"1:%02d", secs%60];
    }
    else timeStr = [NSString stringWithFormat:@"0:%02d", secs];
    NSLog(timeStr);
    self._timeLabel.string = timeStr;
    
    if (secs == 0)
    {
        [[CCDirector sharedDirector] replaceScene:[CCBReader loadAsScene:@"MainScene"]];
    }
    
}


- (void) menu {
    [[CCDirector sharedDirector] replaceScene:[CCBReader loadAsScene:@"MainScene"]];
}
- (void) replay {
    CCScene *gameplay2Scene = [CCBReader loadAsScene:@"Gameplay2"];
    [[CCDirector sharedDirector] replaceScene:gameplay2Scene];
}
- (void) pause {
    self.grid.paused = YES;
    self.paused = YES;
    self.grid.userInteractionEnabled = NO;
    
    _pauselayer.visible = YES;
    CCScene *pauselayerScene = [CCBReader loadAsScene:@"Pauselayer"];
    [[CCDirector sharedDirector] replaceScene:pauselayerScene];
}

- (void) pressedPause:(CCButton*) sender
{
    //[[OALSimpleAudio sharedInstance] playEffect:@"Sounds/click.wav"];
    
    self.grid.paused = YES;
    self.grid.userInteractionEnabled = NO;
    
    _pauselayer.visible = YES;
}

- (void) pressedContinue
{
    //[[OALSimpleAudio sharedInstance] playEffect:@"Sounds/click.wav"];
    
    self.grid.paused = NO;
    self.paused = NO;
    self.grid.userInteractionEnabled = YES;
    
    _pauselayer.visible = NO;
}

- (void) pressedGiveUp
{
    //[[OALSimpleAudio sharedInstance] playEffect:@"Sounds/click.wav"];
    
    [self.animationManager runAnimationsForSequenceNamed:@"outro"];
}

@end
