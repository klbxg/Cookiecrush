//
//  candy.m
//  weiligame
//
//  Created by Olivia Li on 4/9/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "candy.h"

@implementation candy

- (NSString *)spriteName {
    static NSString * const spriteNames[] = {
        @"image/Croissant",
        @"image/Cupcake",
        @"image/Danish",
        @"image/Donut",
        @"image/Macaroon",
        @"image/SugarCookie",
    };
    
    return spriteNames[self.cookieType - 1];
}

- (NSString *)highlightedSpriteName {
    static NSString * const highlightedSpriteNames[] = {
        @"Croissant-Highlighted",
        @"Cupcake-Highlighted",
        @"Danish-Highlighted",
        @"Donut-Highlighted",
        @"Macaroon-Highlighted",
        @"SugarCookie-Highlighted",
    };
    
    return highlightedSpriteNames[self.cookieType - 1];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"type:%ld square:(%ld,%ld)", (long)self.cookieType,
            (long)self.column, (long)self.row];
}

@end
