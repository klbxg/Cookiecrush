//
//  Gameplay2.h
//  weiligame
//
//  Created by Olivia Li on 4/12/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCNode.h"
#import "Grid.h"


@class Grid;

@interface Gameplay2 : CCNode

//+ (Gameplay2*) currentGameScene;
@property(assign, nonatomic) CCLabelTTF *_timeLabel;
@property(assign, nonatomic) CCLabelTTF *_timescore;
@property Grid* grid;

-(void) Continue;

@end
