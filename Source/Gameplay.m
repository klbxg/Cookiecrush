//
//  Gameplay.m
//  weiligame
//
//  Created by Olivia Li on 4/12/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Gameplay.h"

@implementation Gameplay

- (void) menu {
    [[CCDirector sharedDirector] replaceScene:[CCBReader loadAsScene:@"MainScene"]];
}
- (void) replay {
    CCScene *gameplayScene = [CCBReader loadAsScene:@"Gameplay"];
    [[CCDirector sharedDirector] replaceScene:gameplayScene];
}
- (void) shuffle {
    CCLOG(@"shuffle button pressed");
    Grid* grid;
    //NSSet *set = [grid.shuffle];
}

@end
