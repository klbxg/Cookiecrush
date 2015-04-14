//
//  Grid.h
//  weiligame
//
//  Created by Olivia Li on 4/10/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCSprite.h"
//#import "candy.h"

@interface Grid : CCSprite

@property (nonatomic, assign) int totalAlive;
@property (nonatomic, assign) int generation;

//- (candy *)cookieAtColumn:(NSInteger)column row:(NSInteger)row;


@end
