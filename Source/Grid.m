//
//  Grid.m  Weili
//  weiligame
//
//  Created by Olivia Li on 4/13/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Grid.h"
#import "Creature.h"
#import "Swap.h"
#import "Chain.h"

// these are variables that cannot be changed
static const int GRID_COLUMNS = 9;
static const int GRID_ROWS = 9;


@implementation Grid {
    Creature *_cookies[GRID_ROWS][GRID_COLUMNS];
    NSMutableArray *_gridArray;
    float _cellWidth;
    float _cellHeight;
}

- (void)onEnter
{
    [super onEnter];
    
    id block = ^(Swap *swap) {
        
        // While cookies are being matched and new cookies fall down to fill up
        // the holes, we don't want the player to tap on anything.
        self.userInteractionEnabled = NO;
        
        if ([self isPossibleSwap:swap]) {
            [self performSwap:swap];
            [self animateSwap:swap completion:^{
                [self handleMatches];
            }];
        } else {
            [self animateInvalidSwap:swap completion:^{
                self.userInteractionEnabled = YES;
            }];
        }
    };
    
    self.swipeHandler = block;
   
    NSSet *newCookies = [self shuffle];
    [self addSpritesForCookies:newCookies];
    [self removeMatches];
    
    // accept touches on the grid
    self.userInteractionEnabled = YES;
}

- (void)addSpritesForCookies:(NSSet *)cookies {
    for (Creature *cookie in cookies) {
        
        // Create a new sprite for the cookie and add it to the cookiesLayer.
        cookie.sprite.spriteFrame = [CCSpriteFrame frameWithImageNamed:[NSString stringWithFormat:@"image/cookie-%lu.png", (unsigned long)cookie.cookieType]];
//        CCSprite * sprite = [[CCSprite alloc] initWithImageNamed:[NSString stringWithFormat:@"image/cookie-%d.png", cookieType]];
//        sprite.position = [self pointForColumn:cookie.column row:cookie.row];
//        cookie.sprite = sprite;
        [self addChild:cookie];
    }
}

- (NSSet *)createInitialCookies {
    
    NSMutableSet *set = [NSMutableSet set];
    
    // Loop through the rows and columns of the 2D array. Note that column 0,
    // row 0 is in the bottom-left corner of the array.
    for (NSInteger row = 0; row < GRID_ROWS; row++) {
        for (NSInteger column = 0; column < GRID_COLUMNS; column++) {
            
            // Only make a new cookie if there is a tile at this spot.
            //if (_tiles[column][row] != nil) {
                
                // Pick the cookie type at random, and make sure that this never
                // creates a chain of 3 or more. We want there to be 0 matches in
                // the initial state.
                int cookieType;
                do {
                    cookieType = arc4random_uniform(6);
                }
                while ((column >= 2 &&
                        _cookies[column - 1][row].cookieType == cookieType &&
                        _cookies[column - 2][row].cookieType == cookieType)
                       ||
                       (row >= 2 &&
                        _cookies[column][row - 1].cookieType == cookieType &&
                        _cookies[column][row - 2].cookieType == cookieType));
            
                // Create a new cookie and add it to the 2D array.
                Creature *cookie = [self createCookieAtColumn:column row:row withType:cookieType];
            
                // Also add the cookie to the set so we can tell our caller about it.
                [set addObject:cookie];
            //}
        }
    }
    return set;
}

- (Creature *)createCookieAtColumn:(NSInteger)column row:(NSInteger)row withType:(int)cookieType {
    _cellWidth = self.contentSize.width / GRID_COLUMNS;
    _cellHeight = self.contentSize.height / GRID_ROWS;
    CCLOG(@"%f, %f", self.contentSize.width, self.contentSize.height);
    Creature *cookie = [[Creature alloc] initCreature:cookieType];
    cookie.anchorPoint = ccp(0, 0);
    cookie.position = ccp(column * _cellWidth + _cellWidth/2 , row * _cellHeight + _cellHeight/2);
    cookie.cookieType = cookieType;
    cookie.column = column;
    cookie.row = row;
    _cookies[column][row] = cookie;
    CCLOG(@"%ld, %ld, %d", (long)column, (long)row, cookieType);
    return cookie;
}

- (NSSet *)shuffle {
    NSSet *set;
    
    do {
        set = [self createInitialCookies];
        
        [self detectPossibleSwaps];
        
        NSLog(@"possible swaps: %@", self.possibleSwaps);
    }
    while ([self.possibleSwaps count] == 0);
    
    return set;
}

- (BOOL)hasChainAtColumn:(NSInteger)column row:(NSInteger)row {
    NSUInteger cookieType = _cookies[column][row].cookieType;
    
    NSUInteger horzLength = 1;
    for (NSInteger i = column - 1; i >= 0 && _cookies[i][row].cookieType == cookieType; i--, horzLength++) ;
    for (NSInteger i = column + 1; i < GRID_COLUMNS && _cookies[i][row].cookieType == cookieType; i++, horzLength++) ;
    if (horzLength >= 3) return YES;
    
    NSUInteger vertLength = 1;
    for (NSInteger i = row - 1; i >= 0 && _cookies[column][i].cookieType == cookieType; i--, vertLength++) ;
    for (NSInteger i = row + 1; i < GRID_ROWS && _cookies[column][i].cookieType == cookieType; i++, vertLength++) ;
    return (vertLength >= 3);
}

- (void)detectPossibleSwaps {
    
    NSMutableSet *set = [NSMutableSet set];
    
    for (NSInteger row = 0; row < GRID_ROWS; row++) {
        for (NSInteger column = 0; column < GRID_COLUMNS; column++) {
            
            Creature *cookie = _cookies[column][row];
            if (cookie != nil) {
                
                // Is it possible to swap this cookie with the one on the right?
                if (column < GRID_COLUMNS - 1) {
                    // Have a cookie in this spot? If there is no tile, there is no cookie.
                    Creature *other = _cookies[column + 1][row];
                    if (other != nil) {
                        // Swap them
                        _cookies[column][row] = other;
                        _cookies[column + 1][row] = cookie;
                        
                        // Is either cookie now part of a chain?
                        if ([self hasChainAtColumn:column + 1 row:row] ||
                            [self hasChainAtColumn:column row:row]) {
                            
                            Swap *swap = [[Swap alloc] init];
                            swap.cookieA = cookie;
                            swap.cookieB = other;
                            [set addObject:swap];
                        }
                        
                        // Swap them back
                        _cookies[column][row] = cookie;
                        _cookies[column + 1][row] = other;
                    }
                }
                
                if (row < GRID_ROWS - 1) {
                    
                    Creature *other = _cookies[column][row + 1];
                    if (other != nil) {
                        _cookies[column][row] = other;
                        _cookies[column][row + 1] = cookie;
                        
                        if ([self hasChainAtColumn:column row:row + 1] ||
                            [self hasChainAtColumn:column row:row]) {
                            
                            Swap *swap = [[Swap alloc] init];
                            swap.cookieA = cookie;
                            swap.cookieB = other;
                            [set addObject:swap];
                        }
                        
                        _cookies[column][row] = cookie;
                        _cookies[column][row + 1] = other;
                    }
                }
            }
        }
    }
    
    self.possibleSwaps = set;
}
- (void)performSwap:(Swap *)swap {
    NSInteger columnA = swap.cookieA.column;
    NSInteger rowA = swap.cookieA.row;
    NSInteger columnB = swap.cookieB.column;
    NSInteger rowB = swap.cookieB.row;
    
    _cookies[columnA][rowA] = swap.cookieB;
    swap.cookieB.column = columnA;
    swap.cookieB.row = rowA;
    
    _cookies[columnB][rowB] = swap.cookieA;
    swap.cookieA.column = columnB;
    swap.cookieA.row = rowB;
}

- (BOOL)isPossibleSwap:(Swap *)swap {
    return [self.possibleSwaps containsObject:swap];
}


- (void)touchBegan:(CCTouch *)touch withEvent:(UIEvent *)event
{
    //get the x,y coordinates of the touch
    CGPoint touchLocation = [touch locationInNode:self];
    
    CCLOG(@"touchLocation %f, %f", touchLocation.x, touchLocation.y);
    NSInteger column, row;
    if ([self convertPoint:touchLocation toColumn:&column row:&row]) {
        
        // The touch must be on a cookie, not on an empty tile.
        Creature *cookie = [self cookieAtColumn:column row:row];
        if (cookie != nil) {
            
            // Remember in which column and row the swipe started, so we can compare
            // them later to find the direction of the swipe. This is also the first
            // cookie that will be swapped.
            self.swipeFromColumn = column;
            self.swipeFromRow = row;
            
            [self showSelectionIndicatorForCookie:cookie];
        }
    }
    
}

-(void)touchEnded:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
    if (self.selectionSprite.parent != nil && self.swipeFromColumn != NSNotFound) {
        [self hideSelectionIndicator];
    }
    
    // If the gesture ended, regardless of whether if was a valid swipe or not,
    // reset the starting column and row numbers.
    self.swipeFromColumn = self.swipeFromRow = NSNotFound;

}

- (void) showSelectionIndicatorForCookie:(Creature *)cookie {
    NSMutableArray *frames = [NSMutableArray array];
    // If the selection indicator is still visible, then first remove it.
//            if (self.selectionSprite.parent != nil) {
//                [self.selectionSprite removeFromParent];
//            }
    
    // Add the selection indicator as a child to the cookie that the player
    // tapped on and fade it in. Note: simply setting the texture on the sprite
    // doesn't give it the correct size; using an SKAction does.
    CCTexture *texture = [CCTexture textureWithFile:[NSString stringWithFormat:@"image/cookiehighlight-%d.png", cookie.cookieType]];
        //更换贴图
    //CCTexture * texture =[[CCTextureCache sharedTextureCache] addImage: [NSString stringWithFormat:@"image/cookiehighlight-%d.png", cookie.cookieType]];//新建贴图
    //[cookie setTexture:texture];

    //CCSpriteFrame *frame = [CCSpriteFrame frameWithTexture:texture rectInPixels:cookie.x, cookie.y rotated:NO offset:CGPointZero originalSize:cookie.contentSize];
    self.cookie1 = cookie;
    self.selectionSprite = cookie;
    //cookie.texture = texture;
    //self.selectionSprite.contentSize = texture.contentSize;
    //[self.selectionSprite runAction:[CCAction setTexture:texture]];
    //[frames addObject:frame];
    [self.selectionSprite setTexture:texture];
    //[self.selectionSprite addChild:cookie z:100];
    self.selectionSprite.opacity = 1.0;
}
- (void)hideSelectionIndicator {
//    [self.selectionSprite runAction:[SKAction sequence:@[
//                                                         [SKAction fadeOutWithDuration:0.3],
//                                                         [SKAction removeFromParent]]]];
    CCTexture *texture = [CCTexture textureWithFile:[NSString stringWithFormat:@"image/cookie-%d.png", self.cookie1.cookieType]];
    CCLOG(@"%d", self.cookie1.cookieType);
    [self.selectionSprite setTexture:texture];
    self.cookie1 = nil;
}
- (NSSet *)removeMatches {
    NSSet *horizontalChains = [self detectHorizontalMatches];
    NSSet *verticalChains = [self detectVerticalMatches];
    
    // Note: to detect more advanced patterns such as an L shape, you can see
    // whether a cookie is in both the horizontal & vertical chains sets and
    // whether it is the first or last in the array (at a corner). Then you
    // create a new RWTChain object with the new type and remove the other two.
    
    [self removeCookies:horizontalChains];
    [self removeCookies:verticalChains];
    
    //[self fillHoles];
    //[self topUpCookies];
    
    //[self calculateScores:horizontalChains];
    //[self calculateScores:verticalChains];
    
    return [horizontalChains setByAddingObjectsFromSet:verticalChains];
}

- (NSSet *)detectHorizontalMatches {
    
    // Contains the RWTCookie objects that were part of a horizontal chain.
    // These cookies must be removed.
    NSMutableSet *set = [NSMutableSet set];
    
    for (NSInteger row = 0; row < GRID_ROWS; row++) {
        
        // Don't need to look at last two columns.
        // Note: for-loop without increment.
        for (NSInteger column = 0; column < GRID_COLUMNS - 2; ) {
            
            // If there is a cookie/tile at this position...
            if (_cookies[column][row] != nil) {
                NSUInteger matchType = _cookies[column][row].cookieType;
                //CCLOG(@"detect %d, %d, %d", column, row, matchType);

                // And the next two columns have the same type...
                if (_cookies[column + 1][row].cookieType == matchType
                    && _cookies[column + 2][row].cookieType == matchType) {
                    CCLOG(@"detect %d, %d, %d", column, row, matchType);
                    // ...then add all the cookies from this chain into the set.
                    Chain *chain = [[Chain alloc] init];
                    chain.chainType = ChainTypeHorizontal;
                    do {
                        [chain addCookie:_cookies[column][row]];
                        column += 1;
                    }
                    while (column < GRID_COLUMNS && _cookies[column][row].cookieType == matchType);
                    
                    [set addObject:chain];
                    continue;
                }
            }
            
            // Cookie did not match or empty tile, so skip over it.
            column += 1;
        }
    }
    return set;
}

- (void)removeCookies:(NSSet *)chains {
    for (Chain *chain in chains) {
        for (Creature *cookie in chain.cookies) {
            [_cookies[cookie.column][cookie.row] removeFromParent];
            _cookies[cookie.column][cookie.row] = nil;
        }
    }
}

//- (void)calculateScores:(NSSet *)chains {
//    // 3-chain is 60 pts, 4-chain is 120, 5-chain is 180, and so on
//    for (Chain *chain in chains) {
//        chain.score = 60 * ([chain.cookies count] - 2) * self.comboMultiplier;
//        self.comboMultiplier++;
//    }
//}


// Same as the horizontal version but just steps through the array differently.
- (NSSet *)detectVerticalMatches {
    NSMutableSet *set = [NSMutableSet set];
    
    for (NSInteger column = 0; column < GRID_COLUMNS; column++) {
        for (NSInteger row = 0; row < GRID_ROWS - 2; ) {
            if (_cookies[column][row] != nil) {
                NSUInteger matchType = _cookies[column][row].cookieType;
                
                if (_cookies[column][row + 1].cookieType == matchType
                    && _cookies[column][row + 2].cookieType == matchType) {
                    
                    Chain *chain = [[Chain alloc] init];
                    chain.chainType = ChainTypeVertical;
                    do {
                        [chain addCookie:_cookies[column][row]];
                        row += 1;
                    }
                    while (row < GRID_ROWS && _cookies[column][row].cookieType == matchType);
                    
                    [set addObject:chain];
                    continue;
                }
            }
            row += 1;
        }
    }
    return set;
}

- (BOOL)convertPoint:(CGPoint)point toColumn:(NSInteger *)column row:(NSInteger *)row
{
    NSParameterAssert(column);
    NSParameterAssert(row);
    _cellWidth = self.contentSize.width / GRID_COLUMNS;
    _cellHeight = self.contentSize.height / GRID_ROWS;

    // Is this a valid location within the cookies layer? If yes,
    // calculate the corresponding row and column numbers.
    if (point.x >= 0 && point.x < GRID_COLUMNS*_cellWidth &&
        point.y >= 0 && point.y < GRID_ROWS*_cellHeight) {
        
        *column = point.x / _cellWidth;
        *row = point.y / _cellHeight;
        return YES;
        
    } else {
        *column = NSNotFound;  // invalid location
        *row = NSNotFound;
        return NO;
    }
    
}
-(void) touchMoved:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    // 1
    _cellWidth = self.contentSize.width / GRID_COLUMNS;
    _cellHeight = self.contentSize.height / GRID_ROWS;
    if (self.swipeFromColumn == NSNotFound) return;
    
    // 2
    //CCTouch *touch = [touches anyObject];
    //CGPoint touchLocation = [touch locationInNode:self];

    CGPoint location = [touch locationInNode:self];
    
    NSInteger column, row;
    if ([self convertPoint:location toColumn:&column row:&row]) {
        
        // 3
        NSInteger horzDelta = 0, vertDelta = 0;
        if (column < self.swipeFromColumn) {          // swipe left
            horzDelta = -1;
        } else if (column > self.swipeFromColumn) {   // swipe right
            horzDelta = 1;
        } else if (row < self.swipeFromRow) {         // swipe down
            vertDelta = -1;
        } else if (row > self.swipeFromRow) {         // swipe up
            vertDelta = 1;
        }
        CCLOG(@"touchmove %d, %d", horzDelta, vertDelta);
        // 4
        if (horzDelta != 0 || vertDelta != 0) {
            [self trySwapHorizontal:horzDelta vertical:vertDelta];
            [self hideSelectionIndicator];
            // 5
            self.swipeFromColumn = NSNotFound;
        }
    }
}

- (void)animateSwap:(Swap *)swap completion:(dispatch_block_t)completion {
    
    // Put the cookie you started with on top.
    swap.cookieA.zOrder = 100;
    swap.cookieB.zOrder = 90;
    
    const NSTimeInterval Duration = 0.3;
    
    CCActionMoveTo *moveA = [CCActionMoveTo actionWithDuration: Duration position:swap.cookieB.position];
    [swap.cookieA runAction:[CCActionSequence actionWithArray:@[moveA,[CCActionCallBlock actionWithBlock:completion]]]];

    CCLOG(@"animateswap %d, %d", swap.cookieB.column, swap.cookieB.row);
    CCActionMoveTo *moveB = [CCActionMoveTo actionWithDuration: Duration position:swap.cookieA.position];
    [swap.cookieB runAction:moveB];
    //[self runAction:self.swapSound];
}
- (void)animateMatchedCookies:(NSSet *)chains completion:(dispatch_block_t)completion {
    
    for (Chain *chain in chains) {
        //[self animateScoreForChain:chain];
        for (Creature *cookie in chain.cookies) {
            
            if (cookie != nil) {
                CCActionScaleTo *scaleAction = [CCActionScaleTo actionWithDuration:0.3 scale:0.1f];
                //scaleAction.timingMode = SKActionTimingEaseOut;
                [cookie.sprite runAction:scaleAction];
                [cookie.sprite removeFromParent];
                // It may happen that the same RWTCookie object is part of two chains
                // (L-shape match). In that case, its sprite should only be removed
                // once.
                cookie.sprite = nil;
            }
        }
    }
    
    //[self runAction:self.matchSound];
    
    // Continue with the game after the animations have completed.
    [self runAction:[CCActionSequence actionWithArray:@[
                                                [CCActionDelay actionWithDuration:0.3],
                                                [CCActionCallBlock actionWithBlock:completion]
                                                ]]];
}

- (void)animateInvalidSwap:(Swap *)swap completion:(dispatch_block_t)completion {
    swap.cookieA.zOrder= 100;
    swap.cookieB.zOrder = 90;
    
    const NSTimeInterval Duration = 0.2;
    
    CCActionMoveTo *moveA = [CCActionMoveTo actionWithDuration: Duration position:swap.cookieB.position];
    //moveA.timingMode = SKActionTimingEaseOut;
    
    CCActionMoveTo *moveB = [CCActionMoveTo actionWithDuration: Duration position:swap.cookieA.position];
    //moveB.timingMode = SKActionTimingEaseOut;
    [swap.cookieA runAction:[CCActionSequence actionWithArray:@[moveA,moveB, [CCActionCallBlock actionWithBlock:completion]]]];
    //[swap.cookieA.sprite runAction:[SKAction sequence:@[moveA, moveB, [SKAction runBlock:completion]]]];
    [swap.cookieB runAction:[CCActionSequence actionWithArray:@[moveB, moveA]]];
    
    //[self runAction:self.invalidSwapSound];
}
- (void)animateFallingCookies:(NSArray *)columns completion:(dispatch_block_t)completion {
    __block NSTimeInterval longestDuration = 0;
    _cellWidth = self.contentSize.width / GRID_COLUMNS;
    _cellHeight = self.contentSize.height / GRID_ROWS;
    
    for (NSArray *array in columns) {
        NSLog(@"%@", array);
        [array enumerateObjectsUsingBlock:^(Creature *cookie, NSUInteger idx, BOOL *stop) {
            CGPoint newPosition = [self pointForColumn:cookie.column row:cookie.row];
            
            // The further away from the hole you are, the bigger the delay
            // on the animation.
            NSTimeInterval delay = 0.05 + 0.15*idx;
            
            // Calculate duration based on far cookie has to fall (0.1 seconds
            // per tile).
            NSTimeInterval duration = ((cookie.position.y - newPosition.y) / _cellHeight) * 0.1;
            longestDuration = MAX(longestDuration, duration + delay);
            
            CCActionMoveTo *moveAction = [CCActionMoveTo actionWithDuration: duration position:newPosition];
            //moveAction.timingMode = SKActionTimingEaseOut;
            [cookie runAction:[CCActionSequence actionWithArray:@[
                                                                  [CCActionDelay actionWithDuration:delay],moveAction]]];
//                                                          [CCActionSequence actionWithArray:@[moveAction, self.fallingCookieSound]]]]];
        }];
    }
    
    // Wait until all the cookies have fallen down before we continue.
    [self runAction:[CCActionSequence actionWithArray:@[
                                         [CCActionDelay actionWithDuration:longestDuration],
                                         [CCActionCallBlock actionWithBlock:completion]
                                         ]]];
}
- (void)animateNewCookies:(NSArray *)columns completion:(dispatch_block_t)completion {
    
    // We don't want to continue with the game until all the animations are
    // complete, so we calculate how long the longest animation lasts, and
    // wait that amount before we trigger the completion block.
    __block NSTimeInterval longestDuration = 0;
    
    for (NSArray *array in columns) {
        
        // The new sprite should start out just above the first tile in this column.
        // An easy way to find this tile is to look at the row of the first cookie
        // in the array, which is always the top-most one for this column.
        NSInteger startRow = ((Creature *)[array firstObject]).row + 1;
        CCLOG(@"%ld", (long)startRow);
        [array enumerateObjectsUsingBlock:^(Creature *cookie, NSUInteger idx, BOOL *stop) {
            
            // Create a new sprite for the cookie.
            //CCSprite *sprite = [SKSpriteNode spriteNodeWithImageNamed:[cookie spriteName]];
            //int newCookieType = arc4random_uniform(6);
            //Creature *sprite = [super initWithImageNamed:[NSString stringWithFormat:@"image/cookie-%d.png", newCookieType]];
            //CCSprite * sprite = [[CCSprite alloc] initWithImageNamed:[NSString stringWithFormat:@"image/cookie-%d.png", newCookieType]];
            //Creature * sprite = [[Creature alloc] initCreature:newCookieType];
            //sprite.sprite.spriteFrame = [CCSpriteFrame frameWithImageNamed:[NSString stringWithFormat:@"image/cookie-%lu.png", (unsigned long)cookie.cookieType]];
            //cookie.sprite.spriteFrame = [CCSpriteFrame frameWithImageNamed:[NSString stringWithFormat:@"image/cookie-%lu.png", (unsigned long)newCookieType]];
            //[self addSpritesForCookies:];
            //sprite.position = [self pointForColumn:cookie.column row:startRow];
            CCLOG(@"animation %ld, %ld", cookie.column, (long)startRow);
            cookie.sprite.spriteFrame = [CCSpriteFrame frameWithImageNamed:[NSString stringWithFormat:@"image/cookie-%lu.png", cookie.cookieType]];
            CGPoint oldPosition = [self pointForColumn:cookie.column row:startRow];
            CGPoint cookiePos = [self pointForColumn:cookie.column row:cookie.row];
            CGPoint oldPositionDifference = CGPointMake(oldPosition.x - cookiePos.x,  oldPosition.y - cookiePos.y);
            [cookie.sprite setPosition: oldPositionDifference];
            [self addChild:cookie];
            
            NSTimeInterval delay = 0.1 + 0.2*([array count] - idx - 1);
            //            CCLOG(@"delay %f", delay);
            NSTimeInterval duration = (startRow - cookie.row) * 0.1;
            //            CCLOG(@"startRow %ld, %d", (long)startRow, (int)cookie.row);
            longestDuration = MAX(longestDuration, (duration + delay));
            //CGPoint newPosition = [self pointForColumn:cookie.column row:cookie.row];
            CGPoint newPosition = CGPointMake(0.0, 0.0);
            //[cookie.sprite setPosition:newPosition];
            
             CCLOG(@"newPostion %ld, %d", (long)cookie.column, (int)cookie.row);
             CCActionMoveTo *moveAction = [CCActionMoveTo actionWithDuration: duration position:newPosition];
             cookie.sprite.opacity = 0;
             id fadeInAction = [CCActionSpawn actionOne:[CCActionFadeIn actionWithDuration:0.05] two:moveAction];
             id delayAniamtion = [CCActionDelay actionWithDuration:delay];
             [cookie.sprite runAction:[CCActionSequence actions:delayAniamtion,fadeInAction,nil]];
             //                                                          [CCActionSequence actionWithArray:@[
             //                                                                                             [CCActionFadeIn actionWithDuration:0.05], moveAction]]]]]; //self.addCookieSound]]]]];
             
        }];
    }
    // Wait until the animations are done before we continue.
    [self runAction:[CCActionSequence actionWithArray:@[
                                         [CCActionDelay actionWithDuration:longestDuration],
                                         [CCActionCallBlock actionWithBlock:completion]
                                         ]]];
}

- (CGPoint)pointForColumn:(NSInteger)column row:(NSInteger)row {
    _cellWidth = self.contentSize.width / GRID_COLUMNS;
    _cellHeight = self.contentSize.height / GRID_ROWS;
    return CGPointMake(column*_cellWidth + _cellWidth/2, row*_cellHeight + _cellHeight/2);
}

- (void)beginNextTurn {
    //[self resetComboMultiplier];
    [self detectPossibleSwaps];
    self.userInteractionEnabled = YES;
    //[self decrementMoves];
}
- (void)resetComboMultiplier {
    //self.comboMultiplier = 1;
}
- (void)handleMatches {
    // This is the main loop that removes any matching cookies and fills up the
    // holes with new cookies. While this happens, the user cannot interact with
    // the app.
    
    // Detect if there are any matches left.
    NSSet *chains = [self removeMatches];
    
    // If there are no more matches, then the player gets to move again.
    if ([chains count] == 0) {
        [self beginNextTurn];
        return;
    }
    
    // First, remove any matches...
    [self animateMatchedCookies:chains completion:^{
        
        // Add the new scores to the total.
//        for (Chain *chain in chains) {
//            self.score += chain.score;
//        }
//        [self updateLabels];
        
        // ...then shift down any cookies that have a hole below them...
        NSArray *columns = [self fillHoles];
        NSLog(@"falling %@", columns);
        [self animateFallingCookies:columns completion:^{
            
            // ...and finally, add new cookies at the top.
            NSArray *columns = [self topUpCookies];
            NSLog(@"new %@", columns);
            [self animateNewCookies:columns completion:^{
                
                // Keep repeating this cycle until there are no more matches.
                [self handleMatches];
            }];
        }];
    }];
}

- (void)trySwapHorizontal:(NSInteger)horzDelta vertical:(NSInteger)vertDelta {
    // 1
    NSInteger toColumn = self.swipeFromColumn + horzDelta;
    NSInteger toRow = self.swipeFromRow + vertDelta;
    
    // 2
    if (toColumn < 0 || toColumn >= GRID_COLUMNS) return;
    if (toRow < 0 || toRow >= GRID_ROWS) return;
    
    // 3
    Creature *toCookie = [self cookieAtColumn:toColumn row:toRow];
    if (toCookie == nil) return;
    
    // 4
    Creature *fromCookie = [self cookieAtColumn:self.swipeFromColumn row:self.swipeFromRow];
    
    NSLog(@"*** swapping %@ with %@", fromCookie, toCookie);
    if (self.swipeHandler != nil) {
        Swap *swap = [[Swap alloc] init];
        swap.cookieA = fromCookie;
        swap.cookieB = toCookie;
        
        self.swipeHandler(swap);
    }
}


#pragma mark - Util function

- (BOOL)isIndexValidForX:(int)x andY:(int)y
{
    BOOL isIndexValid = YES;
    if(x < 0 || y < 0 || x >= GRID_ROWS || y >= GRID_COLUMNS)
    {
        isIndexValid = NO;
    }
    return isIndexValid;
}

#pragma mark - Game Logic

- (NSArray *)fillHoles {
    NSMutableArray *columns = [NSMutableArray array];
    
    // Loop through the rows, from bottom to top. It's handy that our row 0 is
    // at the bottom already. Because we're scanning from bottom to top, this
    // automatically causes an entire stack to fall down to fill up a hole.
    // We scan one column at a time.
    for (NSInteger column = 0; column < GRID_COLUMNS; column++) {
        
        NSMutableArray *array;
        for (NSInteger row = 0; row < GRID_ROWS; row++) {
            
            // If there is a tile at this position but no cookie, then there's a hole.
            if (_cookies[column][row] == nil) {//_tiles[column][row] != nil &&
                
                // Scan upward to find a cookie.
                for (NSInteger lookup = row + 1; lookup < GRID_ROWS; lookup++) {
                    Creature *cookie = _cookies[column][lookup];
                    if (cookie != nil) {
                        // Swap that cookie with the hole.
                        _cookies[column][lookup] = nil;
//                        CCLOG(@"holes %d, %d, %d", column, lookup, row);
                        _cookies[column][row] = cookie;
                        cookie.row = row;
//                        cookie.position = ccp(column * _cellWidth, row * _cellHeight);

                        // For each column, we return an array with the cookies that have
                        // fallen down. Cookies that are lower on the screen are first in
                        // the array. We need an array to keep this order intact, so the
                        // animation code can apply the correct kind of delay.
                        if (array == nil) {
                            array = [NSMutableArray array];
                            [columns addObject:array];
                        }
                        [array addObject:cookie];
                        
                        // Don't need to scan up any further.
                        break;
                    }
                }
            }
        }
    }
    return columns;
}
-(void) touchCancelled:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
    [self touchEnded:touch withEvent:event];
}

- (NSArray *)topUpCookies {
    NSMutableArray *columns = [NSMutableArray array];
    NSUInteger cookieType = 0;
    
    // Detect where we have to add the new cookies. If a column has X holes,
    // then it also needs X new cookies. The holes are all on the top of the
    // column now, but the fact that there may be gaps in the tiles makes this
    // a little trickier.
    for (NSInteger column = 0; column < GRID_COLUMNS; column++) {
        
        // This time scan from top to bottom. We can end when we've found the
        // first cookie.
        NSMutableArray *array;
        for (NSInteger row = GRID_ROWS - 1; row >= 0 && _cookies[column][row] == nil; row--) {
            
            // Found a hole?
            //if (_tiles[column][row] != nil) {
                
                // Randomly create a new cookie type. The only restriction is that
                // it cannot be equal to the previous type. This prevents too many
                // "freebie" matches.
                NSUInteger newCookieType;
                do {
                    newCookieType = arc4random_uniform(6);
                } while (newCookieType == cookieType);
                cookieType = newCookieType;
//                CCLOG(@"topup %ld, %ld, %lu", (long)column, (long)row, (unsigned long)cookieType);
                // Create a new cookie.
                Creature *cookie = [self createCookieAtColumn:column row:row withType:(int)cookieType];
                
                // Add the cookie to the array for this column.
                // Note that we only allocate an array if a column actually has holes.
                // This cuts down on unnecessary allocations.
                if (array == nil) {
                    array = [NSMutableArray array];
                    [columns addObject:array];
                }
                [array addObject:cookie];
            //}
        }
    }
    return columns;
}

#pragma mark - Querying the Level

//- (RWTTile *)tileAtColumn:(NSInteger)column row:(NSInteger)row {
//    NSAssert1(column >= 0 && column < NumColumns, @"Invalid column: %ld", (long)column);
//    NSAssert1(row >= 0 && row < NumRows, @"Invalid row: %ld", (long)row);
//    
//    return _tiles[column][row];
//}

- (Creature *)cookieAtColumn:(NSInteger)column row:(NSInteger)row {
    NSAssert1(column >= 0 && column < GRID_COLUMNS, @"Invalid column: %ld", (long)column);
    NSAssert1(row >= 0 && row < GRID_ROWS, @"Invalid row: %ld", (long)row);
    
    return _cookies[column][row];
}

@end
