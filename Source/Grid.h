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

@interface Grid : CCSprite
@property (nonatomic, assign) int totalAlive;
@property (nonatomic, assign) int generation;
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
