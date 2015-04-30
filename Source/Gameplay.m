//
//  Gameplay.m
//  weiligame
//
//  Created by Olivia Li on 4/12/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Gameplay.h"
#import "Grid.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

@implementation Gameplay {
    Grid* _grid;
}

- (void) didLoadFromCCB {
    _grid.states = FALSE;
    [_grid set_scoreLabel1:__scoreLabel];
    [_grid set_moveLabel1:__moveLabel];
}
- (void) menu {
    [[OALSimpleAudio sharedInstance] playEffect:@"Sounds/click.wav"];
    [_grid stopSound];
    [[CCDirector sharedDirector] replaceScene:[CCBReader loadAsScene:@"MainScene"]];
}
- (void) replay {
    [[OALSimpleAudio sharedInstance] playEffect:@"Sounds/click.wav"];
    [_grid stopSound];
    CCScene *gameplayScene = [CCBReader loadAsScene:@"Gameplay"];
    [[CCDirector sharedDirector] replaceScene:gameplayScene];
}
- (void) sharemovemode
{
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    // this should link to FB page for your app or AppStore link if published
    content.contentURL = [NSURL URLWithString:@"https://hunt.makeschool.com/posts/133"];
    // URL of image to be displayed alongside post
    //content.imageURL = [NSURL URLWithString:@"https://git.makeschool.com/MakeSchool-Tutorials/News/f744d331484d043a373ee2a33d63626c352255d4//663032db-cf16-441b-9103-c518947c70e1/cover_photo.jpeg"];
    // title of post
    content.contentTitle = [NSString stringWithFormat:@"I just got %zu scores in SushiTime!", _grid.score];
    // description/body of post
    content.contentDescription = @"Come challenge me!";
    [FBSDKShareDialog showFromViewController:[CCDirector sharedDirector]
                                 withContent:content
                                    delegate:nil];

    
}

+(UIImage*) screenshotWithStartNode:(CCNode*)stNode
{
    [CCDirector sharedDirector].nextDeltaTimeZero = YES;
    
    CGSize winSize = [[CCDirector sharedDirector] viewSize];
    CCRenderTexture* renTxture =
    [CCRenderTexture renderTextureWithWidth:winSize.width
                                     height:winSize.height];
    [renTxture begin];
    [stNode visit];
    [renTxture end];
    
    return [renTxture getUIImage];
}
@end
