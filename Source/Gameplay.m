//
//  Gameplay.m
//  weiligame
//
//  Created by Olivia Li on 4/12/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Gameplay.h"
#import "Grid.h"

@implementation Gameplay {
    Grid* _grid;
}

- (void) didLoadFromCCB {
    _grid.states = FALSE;
    [_grid set_scoreLabel1:__scoreLabel];
    [_grid set_moveLabel1:__moveLabel];
}
- (void) menu {
    [[CCDirector sharedDirector] replaceScene:[CCBReader loadAsScene:@"MainScene"]];
}
- (void) replay {
    CCScene *gameplayScene = [CCBReader loadAsScene:@"Gameplay"];
    [[CCDirector sharedDirector] replaceScene:gameplayScene];
}

@end
