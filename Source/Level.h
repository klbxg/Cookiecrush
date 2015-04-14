//
//  Level.h
//  weiligame
//
//  Created by Olivia Li on 4/10/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "candy.h"



@interface Level : NSObject

- (NSSet *)shuffle;

- (candy *)cookieAtColumn:(NSInteger)column row:(NSInteger)row;

@end
