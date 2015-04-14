//
//  candy.h
//  weiligame
//
//  Created by Olivia Li on 4/9/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>

@import SpriteKit;

static const NSUInteger NumCookieTypes = 6;

@interface candy : NSObject

@property (assign, nonatomic) NSInteger column;
@property (assign, nonatomic) NSInteger row;
@property (assign, nonatomic) NSUInteger cookieType;
@property (strong, nonatomic) CCSprite *sprite;

- (NSString *)spriteName;
- (NSString *)highlightedSpriteName;
@end
