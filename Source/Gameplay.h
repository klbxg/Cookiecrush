//
//  Gameplay.h
//  weiligame
//
//  Created by Olivia Li on 4/12/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCNode.h"

@class Grid;

@interface Gameplay : CCNode

@property Grid* grid;
@property(assign, nonatomic) CCLabelTTF *_targetLabel;
@property(assign, nonatomic) CCLabelTTF *_moveLabel;
@property(assign, nonatomic) CCLabelTTF *_scoreLabel;
@property(assign, nonatomic) CCLabelTTF *_hint;
@end
