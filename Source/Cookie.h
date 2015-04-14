//
//  Cookie.h
//  weiligame
//
//  Created by Olivia Li on 4/13/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCSprite.h"

@interface Cookie : CCSprite
{
    BOOL _gameOver;
}

@property (nonatomic,readwrite) int type;
@property (nonatomic,readwrite) int x;
@property (nonatomic,readwrite) int y;

@property (nonatomic,assign) float speed;

@property (nonatomic,assign) float xSpeed;

@property (nonatomic,assign) BOOL hintMode;

+ (Cookie*) cookieOfType:(int)type;

+ (CCEffectBrightness*) sharedBrightnessHintEffect;

+ (void) cleanup;

- (void) setStartingSpeed;

- (void) setupGameOverSpeeds;

@end
