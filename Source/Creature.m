//
//  Creature.m
//  weiligame
//
//  Created by Olivia Li on 4/13/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Creature.h"

@implementation Creature

- (instancetype)initCreature:(int)type {
    // since we made Creature inherit from CCSprite, 'super' below refers to CCSprite
//    self = [super initWithImageNamed:[NSString stringWithFormat:@"image/cookie-%d.png", type]];
    self = [super init];
    
    if (self) {
        self.sprite = [[CCSprite alloc] init];
        [self addChild:self.sprite];
    }
    
    return self;
}

//- (void)setIsAlive:(BOOL)newState {
//    //when you create an @property as we did in the .h, an instance variable with a leading underscore is automatically created for you
//   // _isAlive = newState;
//    
//    // 'visible' is a property of any class that inherits from CCNode. CCSprite is a subclass of CCNode, and Creature is a subclass of CCSprite, so Creatures have a visible property
//    self.visible = _isAlive;
//}
- (NSString *)description {
    return [NSString stringWithFormat:@"type:%ld square:(%ld,%ld)", (long)self.cookieType, (long)self.column, (long)self.row];
}
@end
