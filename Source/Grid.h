//
//  Grid.h
//  weiligame
//
//  Created by Olivia Li on 4/13/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCSprite.h"
#import "Creature.h"
#import "Swap.h"
#import "Gameplay.h"

@interface Grid : CCSprite 
@property(assign, nonatomic) CCLabelTTF *_targetLabel1;
@property(assign, nonatomic) CCLabelTTF *_moveLabel1;
@property(assign, nonatomic) CCLabelTTF *_scoreLabel1;
@property (assign, nonatomic) NSUInteger targetScore;
@property (assign, nonatomic) NSUInteger maximumMoves;
@property (assign, nonatomic) NSUInteger movesLeft;
@property (assign, nonatomic) NSUInteger comboMultiplier;
@property (assign, nonatomic) NSUInteger score;
@property (assign, nonatomic) NSInteger swipeFromColumn;
@property (assign, nonatomic) NSInteger swipeFromRow;
@property (strong, nonatomic) NSSet *possibleSwaps;
@property (strong, nonatomic) CCSprite *selectionSprite;
@property (assign, nonatomic) Creature *cookie1;
@property (assign, nonatomic) Creature *cookie2;
@property (strong, nonatomic) CCAction *fallingCookieSound;
@property (strong, nonatomic) CCAction *addCookieSound;
@property (copy, nonatomic) void (^swipeHandler)(Swap *swap);
//- (void) showSelectionIndicatorForCookie:(Creature *)cookie;
- (NSSet *)shuffle;
@end
