//
//  Creature.m
//  weiligame
//
//  Created by Olivia Li on 4/10/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Creature.h"


@implementation Creature

- (instancetype)initCreature {
    
    // since we made Creature inherit from CCSprite, 'super' below refers to CCSprite
    //int value = arc4random() % 6;
    //NSString* type = [@(value) stringValue];
    //CCLOG(@"%d", value);
    //self = [super initWithImageNamed:@".png"];//[NSString stringWithFormat:@"image/cookie-%d.png", 1]];
    self = [super initWithImageNamed:@"1.png"];
    if (self) {
        self.isAlive = NO;
    }
    
    return self;
}


- (void)setIsAlive:(BOOL)newState {
    //when you create an @property as we did in the .h, an instance variable with a leading underscore is automatically created for you
    _isAlive = newState;
    
    // 'visible' is a property of any class that inherits from CCNode. CCSprite is a subclass of CCNode, and Creature is a subclass of CCSprite, so Creatures have a visible property
    self.visible = _isAlive;
}
@end
