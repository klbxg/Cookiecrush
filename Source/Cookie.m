//
//  Cookie.m
//  weiligame
//
//  Created by Olivia Li on 4/13/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Cookie.h"
#import "Gameplay.h"
#import "Gameplay2.h"

static CCEffectReflection* _crystalEffect = NULL;
static CCEffectReflection* _crystalHintEffect = NULL;
static CCEffectBrightness* _lightingEffect = NULL;

@implementation Cookie

- (id) initWithType:(int)type
{
    self = [super initWithImageNamed:[NSString stringWithFormat:@"image/cookie-%d.png", type]];
    
    if (!self) return NULL;
    
    // Setup glass effect
//    self.normalMapSpriteFrame = [CCSpriteFrame frameWithImageNamed:[NSString stringWithFormat:@"image/cookiehighlight-%d.png", type]];
    
    //self.effect = [Cookie sharedCrystalEffect];
    
    self.anchorPoint = ccp(0, 0);
    
    // Remember type
    _type = type;
    
    [self setStartingSpeed];
    
    return self;
}

- (void) setStartingSpeed
{
    _speed = -0.6;
}

+ (Cookie*) cookieOfType:(int)type
{
    return [[Cookie alloc] initWithType:type];
}

- (void) fixedUpdate:(CCTime)delta
{
    if (_gameOver)
    {
        _speed -= 0.1;
    }
    else
    {
        if (_speed < 0) _speed -= 0.6;
    }
}

- (void) setupGameOverSpeeds
{
    _speed = CCRANDOM_MINUS1_1() * 4;
    _xSpeed = CCRANDOM_MINUS1_1() * 4;
    
    _gameOver = YES;
}

//- (void) setHintMode:(BOOL)hintMode
//{
//    if (_hintMode != hintMode)
//    {
//        if (hintMode)
//        {
//            self.effect = [Cookie sharedCrystalHintEffect];
//        }
//        else
//        {
//            self.effect = [Cookie sharedCrystalEffect];
//        }
//        
//        _hintMode = hintMode;
//    }
//}

@end
