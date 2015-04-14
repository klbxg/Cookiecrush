//
//  Grid.m
//  weiligame
//
//  Created by Olivia Li on 4/10/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Grid.h"
#import "Creature.h"


static const NSInteger GRID_COLUMNS = 9;
static const NSInteger GRID_ROWS = 9;

@implementation Grid {
    //candy *_cookies[NumColumns][NumRows];
    NSMutableArray *_gridArray;
    float _cellWidth;
    float _cellHeight;
}
- (void)onEnter
{
    [super onEnter];
    
    [self setupGrid];
    
    // accept touches on the grid
    self.userInteractionEnabled = YES;
}

- (void)setupGrid
{
    // divide the grid's size by the number of columns/rows to figure out the right width and height of each cell
    _cellWidth = self.contentSize.width / GRID_COLUMNS;
    _cellHeight = self.contentSize.height / GRID_ROWS;
    
    float x = 0;
    float y = 0;
    
    // initialize the array as a blank NSMutableArray
    _gridArray = [NSMutableArray array];
    
    // initialize Creatures
    for (int i = 0; i < GRID_ROWS; i++) {
        // this is how you create two dimensional arrays in Objective-C. You put arrays into arrays.
        _gridArray[i] = [NSMutableArray array];
        x = 0;
        
        for (int j = 0; j < GRID_COLUMNS; j++) {
            Creature *creature = [[Creature alloc] initCreature];
            creature.anchorPoint = ccp(0, 0);
            creature.position = ccp(x, y);
            [self addChild:creature];
            
            // this is shorthand to access an array inside an array
            _gridArray[i][j] = creature;
            
            // make creatures visible to test this method, remove this once we know we have filled the grid properly
            creature.isAlive = YES;
            
            x+=_cellWidth;
        }
        
        y += _cellHeight;
    }
}

//- (void)onEnter
//{
//    [super onEnter];
//    
//    [self setupGrid];
//    // accept touches on the grid
//    self.userInteractionEnabled = YES;
//    
//}

//- (candy *)cookieAtColumn:(NSInteger)column row:(NSInteger)row {
//    NSAssert1(column >= 0 && column < NumColumns, @"Invalid column: %ld", (long)column);
//    NSAssert1(row >= 0 && row < NumRows, @"Invalid row: %ld", (long)row);
//    
//    return _cookies[column][row];
//}
//- (NSSet *)createInitialCookies {
//    
//    NSMutableSet *set = [NSMutableSet set];
//    
//    for (NSInteger row = 0; row < NumRows; row++) {
//        for (NSInteger column = 0; column < NumColumns; column++) {
//            
//            if (true) {
//                NSUInteger cookieType;
//                do {
//                    cookieType = arc4random_uniform(NumCookieTypes) + 1;
//                }
//                while ((column >= 2 &&
//                        _cookies[column - 1][row].cookieType == cookieType &&
//                        _cookies[column - 2][row].cookieType == cookieType)
//                       ||
//                       (row >= 2 &&
//                        _cookies[column][row - 1].cookieType == cookieType &&
//                        _cookies[column][row - 2].cookieType == cookieType));
//                
//                candy *cookie = [self createCookieAtColumn:column row:row withType:cookieType];
//                [set addObject:cookie];
//            }
//        }
//    }
//    return set;
//}
//
//- (candy *)createCookieAtColumn:(NSInteger)column row:(NSInteger)row withType:(NSUInteger)cookieType {
//    candy *cookie = [[candy alloc] init];
//    cookie.cookieType = cookieType;
//    cookie.column = column;
//    cookie.row = row;
//    _cookies[column][row] = cookie;
//    return cookie;
//}

//- (void)setupGrid
//{
//    // divide the grid's size by the number of columns/rows to figure out the right width and height of each cell
//    _cellWidth = self.contentSize.width / GRID_COLUMNS;
//    _cellHeight = self.contentSize.height /GRID_ROWS;
//    
//    float x = 0;
//    float y = 0;
//    
//    // initialize the array as a blank NSMutableArray
//    _gridArray = [NSMutableArray array];
//    
//    
//    // initialize Creatures
//    for (int i = 0; i < GRID_ROWS; i++) {
//        // this is how you create two dimensional arrays in Objective-C. You put arrays into arrays.
//        _gridArray[i] = [NSMutableArray array];
//        x = 0;
//        
//        for (int j = 0; j < GRID_COLUMNS; j++) {
//            Creature *creature = [[Creature alloc] initCreature];
//            creature.anchorPoint = ccp(0, 0);
//            creature.position = ccp(x, y);
//            [self addChild:creature];
//            
//            // this is shorthand to access an array inside an array
//            _gridArray[i][j] = creature;
//            
//            // make creatures visible to test this method, remove this once we know we have filled the grid properly
//            creature.isAlive = YES;
//            
//            x+=_cellWidth;
//        }
//        
//        y += _cellHeight;
//    }
//}

@end
