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
    
    [self shuffle];
    [self removeMatches];
    
    // accept touches on the grid
    self.userInteractionEnabled = YES;
}

//- (void)setupGrid
//{
//    // divide the grid's size by the number of columns/rows to figure out the right width and height of each cell
//    _cellWidth = self.contentSize.width / GRID_COLUMNS;
//    _cellHeight = self.contentSize.height / GRID_ROWS;
//    CCLOG(@"%f, %f", self.contentSize.width, self.contentSize.height);
//    float x = 0;
//    float y = 0;
//    
//    // initialize the array as a blank NSMutableArray
//    _gridArray = [NSMutableArray array];
//    
//    // initialize Creatures
//    for (int i = 0; i < GRID_ROWS; i++) {
//        // this is how you create two dimensional arrays in Objective-C. You put arrays into arrays.
//        _gridArray[i] = [NSMutableArray array];
//        x = 0;
//        
//        for (int j = 0; j < GRID_COLUMNS; j++) {
//            int value = arc4random() % 6;
//            Creature *creature = [[Creature alloc] initCreature:value];
//            creature.anchorPoint = ccp(0, 0);
//            creature.position = ccp(x, y);
//            [self addChild:creature];
//            
//            // this is shorthand to access an array inside an array
//            _gridArray[i][j] = creature;
//
//            
//            // make creatures visible to test this method, remove this once we know we have filled the grid properly
//            creature.isAlive = YES;
//            
//            x = x + _cellWidth;
//            CCLOG(@"%f, %f, %f", x, y, _cellHeight);
//        }
//        y = y + _cellHeight;
//    }
//}

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
                //do {
                    cookieType = arc4random_uniform(6);
                //}
//                while ((column >= 2 &&
//                        _cookies[column - 1][row].cookieType == cookieType &&
//                        _cookies[column - 2][row].cookieType == cookieType)
//                       ||
//                       (row >= 2 &&
//                        _cookies[column][row - 1].cookieType == cookieType &&
//                        _cookies[column][row - 2].cookieType == cookieType));
            
                // Create a new cookie and add it to the 2D array.
                Creature *cookie = [self createCookieAtColumn:column row:row withType:cookieType];
            
                // Also add the cookie to the set so we can tell our caller about it.
                [self addChild:cookie];
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
    cookie.position = ccp(column * _cellWidth, row * _cellHeight);
    cookie.cookieType = cookieType;
    cookie.column = column;
    cookie.row = row;
    _cookies[column][row] = cookie;
    CCLOG(@"%d, %d, %d", column, row, cookieType);
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
    
    //get the Creature at that location
    Creature *creature = [self creatureForTouchPosition:touchLocation];
    
    //invert it's state - kill it if it's alive, bring it to life if it's dead.
    creature.isAlive = !creature.isAlive;
}

- (Creature *)creatureForTouchPosition:(CGPoint)touchPosition
{
    //get the row and column that was touched, return the Creature inside the corresponding cell
    Creature *creature = nil;
    
    int column = touchPosition.x / _cellWidth;
    int row = touchPosition.y / _cellHeight;
    creature = _gridArray[row][column];
    self.swipeFromColumn = column;
    self.swipeFromRow = row;
    return creature;
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

//- (BOOL)convertPoint:(CGPoint)point toColumn:(NSInteger *)column row:(NSInteger *)row
//{
//    NSParameterAssert(column);
//    NSParameterAssert(row);
//    // Is this a valid location within the cookies layer? If yes,
//    // calculate the corresponding row and column numbers.
//    if (point.x >= 0 && point.x < NumColumns*TileWidth &&
//        point.y >= 0 && point.y < NumRows*TileHeight) {
//        
//        *column = point.x / TileWidth;
//        *row = point.y / TileHeight;
//        return YES;
//        
//    } else {
//        *column = NSNotFound;  // invalid location
//        *row = NSNotFound;
//        return NO;
//    }
//    
//}
//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
//    // 1
//    if (self.swipeFromColumn == NSNotFound) return;
//    
//    // 2
//    UITouch *touch = [touches anyObject];
//    CGPoint location = [touch locationInNode:self.cookiesLayer];
//    
//    NSInteger column, row;
//    if ([self convertPoint:location toColumn:&column row:&row]) {
//        
//        // 3
//        NSInteger horzDelta = 0, vertDelta = 0;
//        if (column < self.swipeFromColumn) {          // swipe left
//            horzDelta = -1;
//        } else if (column > self.swipeFromColumn) {   // swipe right
//            horzDelta = 1;
//        } else if (row < self.swipeFromRow) {         // swipe down
//            vertDelta = -1;
//        } else if (row > self.swipeFromRow) {         // swipe up
//            vertDelta = 1;
//        }
//        
//        // 4
//        if (horzDelta != 0 || vertDelta != 0) {
//            [self trySwapHorizontal:horzDelta vertical:vertDelta];
//            
//            // 5
//            self.swipeFromColumn = NSNotFound;
//        }
//    }
//}
//- (void)trySwapHorizontal:(NSInteger)horzDelta vertical:(NSInteger)vertDelta {
//    // 1
//    NSInteger toColumn = self.swipeFromColumn + horzDelta;
//    NSInteger toRow = self.swipeFromRow + vertDelta;
//    
//    // 2
//    if (toColumn < 0 || toColumn >= GRID_COLUMNS) return;
//    if (toRow < 0 || toRow >= GRID_ROWS) return;
//    
//    // 3
//    Creature *toCookie = [self cookieAtColumn:toColumn row:toRow];
//    if (toCookie == nil) return;
//    
//    // 4
//    Creature *fromCookie = [self cookieAtColumn:self.swipeFromColumn row:self.swipeFromRow];
//    
//    NSLog(@"*** swapping %@ with %@", fromCookie, toCookie);
//}
//
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

- (void)updateCreatures {
    _totalAlive = 0;
    
    for (int i = 0; i < [_gridArray count]; i++) {
        for (int j = 0; j < [_gridArray[i] count]; j++) {
            Creature *currentCreature = _gridArray[i][j];
            if (currentCreature.livingNeighbors == 3) {
                currentCreature.isAlive = YES;
            } else if ( (currentCreature.livingNeighbors <= 1) || (currentCreature.livingNeighbors >= 4)) {
                currentCreature.isAlive = NO;
            }
            
            if (currentCreature.isAlive) {
                _totalAlive++;
            }
        }
    }
}


- (void)countNeighbors {
    // iterate through the rows
    // note that NSArray has a method 'count' that will return the number of elements in the array
    for (int i = 0; i < [_gridArray count]; i++)
    {
        // iterate through all the columns for a given row
        for (int j = 0; j < [_gridArray[i] count]; j++)
        {
            // access the creature in the cell that corresponds to the current row/column
            Creature *currentCreature = _gridArray[i][j];
            
            // remember that every creature has a 'livingNeighbors' property that we created earlier
            currentCreature.livingNeighbors = 0;
            
            // now examine every cell around the current one
            
            // go through the row on top of the current cell, the row the cell is in, and the row past the current cell
            for (int x = (i-1); x <= (i+1); x++)
            {
                // go through the column to the left of the current cell, the column the cell is in, and the column to the right of the current cell
                for (int y = (j-1); y <= (j+1); y++)
                {
                    // check that the cell we're checking isn't off the screen
                    BOOL isIndexValid;
                    isIndexValid = [self isIndexValidForX:x andY:y];
                    
                    // skip over all cells that are off screen AND the cell that contains the creature we are currently updating
                    if (!((x == i) && (y == j)) && isIndexValid)
                    {
                        Creature *neighbor = _gridArray[x][y];
                        if (neighbor.isAlive)
                        {
                            currentCreature.livingNeighbors += 1;
                        }
                    }
                }
            }
        }
    }
}
- (Creature *)cookieAtColumn:(NSInteger)column row:(NSInteger)row {
    NSAssert1(column >= 0 && column < GRID_COLUMNS, @"Invalid column: %ld", (long)column);
    NSAssert1(row >= 0 && row < GRID_ROWS, @"Invalid row: %ld", (long)row);
    
    return _cookies[column][row];
}

@end
