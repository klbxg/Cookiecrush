//
//  Gameplay2.h
//  weiligame
//
//  Created by Olivia Li on 4/12/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCNode.h"
#import "Grid.h"

@interface Gameplay2 : CCNode
{
    CCNode* _pauselayer;
    long _frame;
}
+ (Gameplay2*) currentGameScene;

@property (nonatomic,strong) CCLabelBMFont* lblScore;
@property (nonatomic,strong) CCLabelBMFont* lblTime;
@property (nonatomic,strong) Grid* grid;

// Callbacks from PauseLayer
- (void) pressedContinue;
- (void) pressedGiveUp;

@end
