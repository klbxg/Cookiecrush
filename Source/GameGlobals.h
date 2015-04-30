//
//  GameGlobel.h
//  weiligame
//
//  Created by Olivia Li on 4/29/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameGlobals : NSObject
@property (nonatomic,readonly) int highScore1;
@property (nonatomic,assign) int highScore2;
@property (nonatomic,assign) int lastScore1;
@property (nonatomic,assign) int lastScore2;

+ (GameGlobals*) globals;

- (void) store;
@end
