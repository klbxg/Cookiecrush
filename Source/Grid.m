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
#import "Gameplay2.h"

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
        
        cookie.sprite.spriteFrame = [CCSpriteFrame frameWithImageNamed:[NSString stringWithFormat:@"image/sushi-%lu.png", (unsigned long)cookie.cookieType]];
        [self addChild:cookie];
    }
}

- (NSSet *)createInitialCookies {
    
    self.movesLeft = 20;
    self.score = 0;
    
    NSMutableSet *set = [NSMutableSet set];
    
    
    for (NSInteger row = 0; row < GRID_ROWS; row++) {
        for (NSInteger column = 0; column < GRID_COLUMNS; column++) {
            
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
            
                Creature *cookie = [self createCookieAtColumn:column row:row withType:cookieType];
            
                [set addObject:cookie];
        }
    }
    return set;
}

- (Creature *)createCookieAtColumn:(NSInteger)column row:(NSInteger)row withType:(int)cookieType {
    _cellWidth = self.contentSize.width / GRID_COLUMNS;
    _cellHeight = self.contentSize.height / GRID_ROWS;
    //CCLOG(@"%f, %f", self.contentSize.width, self.contentSize.height);
    Creature *cookie = [[Creature alloc] initCreature:cookieType];
    cookie.anchorPoint = ccp(0, 0);
    cookie.position = ccp(column * _cellWidth + _cellWidth/2 , row * _cellHeight + _cellHeight/2);
    cookie.cookieType = cookieType;
    cookie.column = column;
    cookie.row = row;
    _cookies[column][row] = cookie;
    //CCLOG(@"%ld, %ld, %d", (long)column, (long)row, cookieType);
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
                
                if (column < GRID_COLUMNS - 1) {
                    
                    Creature *other = _cookies[column + 1][row];
                    if (other != nil) {
                        
                        _cookies[column][row] = other;
                        _cookies[column + 1][row] = cookie;
                        
                        if ([self hasChainAtColumn:column + 1 row:row] ||
                            [self hasChainAtColumn:column row:row]) {
                            
                            Swap *swap = [[Swap alloc] init];
                            swap.cookieA = cookie;
                            swap.cookieB = other;
                            [set addObject:swap];
                        }
                        
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
    CGPoint touchLocation = [touch locationInNode:self];
    
    CCLOG(@"touchLocation %f, %f", touchLocation.x, touchLocation.y);
    NSInteger column, row;
    if ([self convertPoint:touchLocation toColumn:&column row:&row]) {
        
        Creature *cookie = [self cookieAtColumn:column row:row];
        if (cookie != nil) {
            
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
    
    self.swipeFromColumn = self.swipeFromRow = NSNotFound;

}

- (void) showSelectionIndicatorForCookie:(Creature *)cookie {
    NSMutableArray *frames = [NSMutableArray array];
    
    cookie.sprite.spriteFrame = [CCSpriteFrame frameWithImageNamed:[NSString stringWithFormat:@"image/sushihighlight-%lu.png", (unsigned long)cookie.cookieType]];
    self.cookie1 = cookie;
    self.selectionSprite = cookie;
    
}
- (void)hideSelectionIndicator {

    self.cookie1.sprite.spriteFrame = [CCSpriteFrame frameWithImageNamed:[NSString stringWithFormat:@"image/sushi-%lu.png", (unsigned long)self.cookie1.cookieType]];
    //CCLOG(@"%lu", (unsigned long)self.cookie1.cookieType);
    self.cookie1 = nil;
}
- (NSSet *)removeMatches {
    NSSet *horizontalChains = [self detectHorizontalMatches];
    NSSet *verticalChains = [self detectVerticalMatches];
    
    [self removeCookies:horizontalChains];
    [self removeCookies:verticalChains];
    
    [self calculateScores:horizontalChains];
    [self calculateScores:verticalChains];
    
    return [horizontalChains setByAddingObjectsFromSet:verticalChains];
}

- (NSSet *)detectHorizontalMatches {
    
    NSMutableSet *set = [NSMutableSet set];
    
    for (NSInteger row = 0; row < GRID_ROWS; row++) {
        
        for (NSInteger column = 0; column < GRID_COLUMNS - 2; ) {
            
            if (_cookies[column][row] != nil) {
                NSUInteger matchType = _cookies[column][row].cookieType;

                if (_cookies[column + 1][row].cookieType == matchType
                    && _cookies[column + 2][row].cookieType == matchType) {
                    //CCLOG(@"detect %d, %d, %d", column, row, matchType);
                    
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

- (void)calculateScores:(NSSet *)chains {
    for (Chain *chain in chains) {
        chain.score = 30 * ([chain.cookies count] - 2) * self.comboMultiplier;
        self.comboMultiplier++;
    }
}


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

    if (point.x >= 0 && point.x < GRID_COLUMNS*_cellWidth &&
        point.y >= 0 && point.y < GRID_ROWS*_cellHeight) {
        
        *column = point.x / _cellWidth;
        *row = point.y / _cellHeight;
        return YES;
        
    } else {
        *column = NSNotFound;
        *row = NSNotFound;
        return NO;
    }
    
}
-(void) touchMoved:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
    _cellWidth = self.contentSize.width / GRID_COLUMNS;
    _cellHeight = self.contentSize.height / GRID_ROWS;
    if (self.swipeFromColumn == NSNotFound) return;

    CGPoint location = [touch locationInNode:self];
    
    NSInteger column, row;
    if ([self convertPoint:location toColumn:&column row:&row]) {
        
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
        //CCLOG(@"touchmove %d, %d", horzDelta, vertDelta);
        if (horzDelta != 0 || vertDelta != 0) {
            [self trySwapHorizontal:horzDelta vertical:vertDelta];
            [self hideSelectionIndicator];
            // 5
            self.swipeFromColumn = NSNotFound;
        }
    }
}

- (void)animateSwap:(Swap *)swap completion:(dispatch_block_t)completion {
    
    swap.cookieA.zOrder = 100;
    swap.cookieB.zOrder = 90;
    
    const NSTimeInterval Duration = 0.3;
    
    CCActionMoveTo *moveA = [CCActionMoveTo actionWithDuration: Duration position:swap.cookieB.position];
    [swap.cookieA runAction:[CCActionSequence actionWithArray:@[moveA,[CCActionCallBlock actionWithBlock:completion]]]];

    //CCLOG(@"animateswap %ld, %d", (long)swap.cookieB.column, swap.cookieB.row);
    CCActionMoveTo *moveB = [CCActionMoveTo actionWithDuration: Duration position:swap.cookieA.position];
    [swap.cookieB runAction:moveB];
}
- (void)animateMatchedCookies:(NSSet *)chains completion:(dispatch_block_t)completion {
    
    for (Chain *chain in chains) {
        //[self animateScoreForChain:chain];
        for (Creature *cookie in chain.cookies) {
            
            if (cookie != nil) {
                CCParticleSystem *explosion = (CCParticleSystem *)[CCBReader load:@"removeeffect"];
                explosion.position = cookie.position;
                [self addChild:explosion];
                explosion.autoRemoveOnFinish = YES;

                CCActionScaleTo *scaleAction = [CCActionScaleTo actionWithDuration:0.3 scale:0.1f];
                [cookie.sprite runAction:[CCActionEaseBackOut actionWithAction:scaleAction]];
                [cookie.sprite removeFromParent];
                cookie.sprite = nil;
            }
        }
    }
    
    //[self runAction:self.matchSound];
    [self runAction:[CCActionSequence actionWithArray:@[
                                                [CCActionDelay actionWithDuration:0.3],
                                                [CCActionCallBlock actionWithBlock:completion]
                                                ]]];
}

- (void)animateInvalidSwap:(Swap *)swap completion:(dispatch_block_t)completion {
    swap.cookieA.zOrder= 100;
    swap.cookieB.zOrder = 90;
    
    const NSTimeInterval Duration = 0.3;
    
    CCActionMoveTo *moveA = [CCActionMoveTo actionWithDuration: Duration position:swap.cookieB.position];
    
    CCActionMoveTo *moveB = [CCActionMoveTo actionWithDuration: Duration position:swap.cookieA.position];
    [swap.cookieA runAction:[CCActionSequence actionWithArray:@[[CCActionEaseBackOut actionWithAction:moveA],[CCActionEaseBackOut actionWithAction:moveB], [CCActionCallBlock actionWithBlock:completion]]]];
    [swap.cookieB runAction:[CCActionSequence actionWithArray:@[[CCActionEaseBackOut actionWithAction:moveB], [CCActionEaseBackOut actionWithAction:moveA]]]];
    
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
            
            NSTimeInterval delay = 0.05 + 0.15*idx;
            NSTimeInterval duration = ((cookie.position.y - newPosition.y) / _cellHeight) * 0.1;
            longestDuration = MAX(longestDuration, duration + delay);
            
            CCActionMoveTo *moveAction = [CCActionMoveTo actionWithDuration: duration position:newPosition];
            [cookie runAction:[CCActionSequence actionWithArray:@[
                                                                  [CCActionDelay actionWithDuration:delay],[CCActionEaseBackOut actionWithAction:moveAction]]]];
//                                                          [CCActionSequence actionWithArray:@[moveAction, self.fallingCookieSound]]]]];
        }];
    }
    
    [self runAction:[CCActionSequence actionWithArray:@[
                                         [CCActionDelay actionWithDuration:longestDuration],
                                         [CCActionCallBlock actionWithBlock:completion]
                                         ]]];
}
- (void)animateNewCookies:(NSArray *)columns completion:(dispatch_block_t)completion {

    __block NSTimeInterval longestDuration = 0;
    
    for (NSArray *array in columns) {

        NSInteger startRow = ((Creature *)[array firstObject]).row + 1;
        CCLOG(@"%ld", (long)startRow);
        [array enumerateObjectsUsingBlock:^(Creature *cookie, NSUInteger idx, BOOL *stop) {
            
            cookie.sprite.spriteFrame = [CCSpriteFrame frameWithImageNamed:[NSString stringWithFormat:@"image/sushi-%lu.png", cookie.cookieType]];
            CGPoint oldPosition = [self pointForColumn:cookie.column row:startRow];
            CGPoint cookiePos = [self pointForColumn:cookie.column row:cookie.row];
            CGPoint oldPositionDifference = CGPointMake(oldPosition.x - cookiePos.x,  oldPosition.y - cookiePos.y);
            [cookie.sprite setPosition: oldPositionDifference];
            [self addChild:cookie];
            
            NSTimeInterval delay = 0.1 + 0.2*([array count] - idx - 1);
            
            NSTimeInterval duration = (startRow - cookie.row) * 0.1;
            
            longestDuration = MAX(longestDuration, (duration + delay));
            
            CGPoint newPosition = CGPointMake(0.0, 0.0);
            
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
- (void)updateLabels {
    [[self _moveLabel1] setString:[NSString stringWithFormat:@"%lu", (long)self.movesLeft]];
    //CCLOG(@"moveleft %lu", self.movesLeft);
    [[self _scoreLabel1] setString:[NSString stringWithFormat:@"%lu", (long)self.score]];
    //CCLOG(@"score %lu", self.score);
}

- (void)decrementMoves{
    self.movesLeft--;
    CCLOG(@"moveleft %lu", self.movesLeft);
    [self updateLabels];
    if (self.states == FALSE) {
        if (self.score >= 2000) {
            //        self.gameOverPanel.image = [UIImage imageNamed:@"LevelComplete"];
            //        [self showGameOver];
            [[CCDirector sharedDirector] replaceScene:[CCBReader loadAsScene:@"MainScene"]];
            
        } else if (self.movesLeft == 0) {
            //        self.gameOverPanel.image = [UIImage imageNamed:@"GameOver"];
            //        [self showGameOver];
            [[CCDirector sharedDirector] replaceScene:[CCBReader loadAsScene:@"MainScene"]];
        }

    }
}


- (void)beginNextTurn {
    [self resetComboMultiplier];
    [self detectPossibleSwaps];
    self.userInteractionEnabled = YES;
    [self decrementMoves];
}
- (void)resetComboMultiplier {
    self.comboMultiplier = 1;
}
- (void)handleMatches {
    
    NSSet *chains = [self removeMatches];
    
    if ([chains count] == 0) {
        [self beginNextTurn];
        return;
    }

    [self animateMatchedCookies:chains completion:^{
        
        for (Chain *chain in chains) {
            self.score += chain.score;
            CCLOG(@"self chain %lu, %lu", self.score, chain.score);
        };
        [self updateLabels];
        
        NSArray *columns = [self fillHoles];
        NSLog(@"falling %@", columns);
        [self animateFallingCookies:columns completion:^{
            
            NSArray *columns = [self topUpCookies];
            NSLog(@"new %@", columns);
            [self animateNewCookies:columns completion:^{
                
                [self handleMatches];
            }];
        }];
    }];
}

- (void)trySwapHorizontal:(NSInteger)horzDelta vertical:(NSInteger)vertDelta {
    
    NSInteger toColumn = self.swipeFromColumn + horzDelta;
    NSInteger toRow = self.swipeFromRow + vertDelta;
    
    if (toColumn < 0 || toColumn >= GRID_COLUMNS) return;
    if (toRow < 0 || toRow >= GRID_ROWS) return;
    
    Creature *toCookie = [self cookieAtColumn:toColumn row:toRow];
    if (toCookie == nil) return;
    
    Creature *fromCookie = [self cookieAtColumn:self.swipeFromColumn row:self.swipeFromRow];
    
    NSLog(@"*** swapping %@ with %@", fromCookie, toCookie);
    if (self.swipeHandler != nil) {
        Swap *swap = [[Swap alloc] init];
        swap.cookieA = fromCookie;
        swap.cookieB = toCookie;
        
        self.swipeHandler(swap);
    }
}


- (BOOL)isIndexValidForX:(int)x andY:(int)y
{
    BOOL isIndexValid = YES;
    if(x < 0 || y < 0 || x >= GRID_ROWS || y >= GRID_COLUMNS)
    {
        isIndexValid = NO;
    }
    return isIndexValid;
}


- (NSArray *)fillHoles {
    NSMutableArray *columns = [NSMutableArray array];
    
    for (NSInteger column = 0; column < GRID_COLUMNS; column++) {
        
        NSMutableArray *array;
        for (NSInteger row = 0; row < GRID_ROWS; row++) {
            
            if (_cookies[column][row] == nil) {
                
                for (NSInteger lookup = row + 1; lookup < GRID_ROWS; lookup++) {
                    Creature *cookie = _cookies[column][lookup];
                    if (cookie != nil) {
                        _cookies[column][lookup] = nil;
//                        CCLOG(@"holes %d, %d, %d", column, lookup, row);
                        _cookies[column][row] = cookie;
                        cookie.row = row;

                        if (array == nil) {
                            array = [NSMutableArray array];
                            [columns addObject:array];
                        }
                        [array addObject:cookie];
                        
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

    for (NSInteger column = 0; column < GRID_COLUMNS; column++) {
        
        NSMutableArray *array;
        for (NSInteger row = GRID_ROWS - 1; row >= 0 && _cookies[column][row] == nil; row--) {

                NSUInteger newCookieType;
                do {
                    newCookieType = arc4random_uniform(6);
                } while (newCookieType == cookieType);
                cookieType = newCookieType;
//                CCLOG(@"topup %ld, %ld, %lu", (long)column, (long)row, (unsigned long)cookieType);
            
                Creature *cookie = [self createCookieAtColumn:column row:row withType:(int)cookieType];
            
                if (array == nil) {
                    array = [NSMutableArray array];
                    [columns addObject:array];
                }
                [array addObject:cookie];
        }
    }
    return columns;
}

- (Creature *)cookieAtColumn:(NSInteger)column row:(NSInteger)row {
    NSAssert1(column >= 0 && column < GRID_COLUMNS, @"Invalid column: %ld", (long)column);
    NSAssert1(row >= 0 && row < GRID_ROWS, @"Invalid row: %ld", (long)row);
    
    return _cookies[column][row];
}

@end
