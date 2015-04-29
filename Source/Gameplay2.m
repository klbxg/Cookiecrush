//
//  Gameplay2.m
//  weiligame
//
//  Created by Olivia Li on 4/12/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Gameplay2.h"
#import "Grid.h"
#import "Pauselayer.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

static __weak Gameplay2* _currentGameScene;

@implementation Gameplay2{
    Grid* _grid1;
    Pauselayer * _pauselayer;
    int secs;
    
}

+ (Gameplay2*) currentGameScene
{
    return _currentGameScene;
}

//- (void) menupage {
//    [[OALSimpleAudio sharedInstance] playEffect:@"Sounds/click.wav"];
//    [_grid1 stopSound];
//    [[CCDirector sharedDirector] replaceScene:[CCBReader loadAsScene:@"MainScene"]];
//}

- (void) didLoadFromCCB
{
    _grid1.states = TRUE;
    _currentGameScene = self;
    secs = 10;
    [_grid1 set_scoreLabel1:__timescore];
    [self schedule:@selector(updateTimeDisplay:) interval:1];
    _pauselayer.gameplay2 = self;
    self.grid.paused = YES;
}

- (void) updateTimeDisplay:(CCTime)delta
{
    secs -= 1;
    NSString* timeStr = NULL;
    if (secs >= 180) timeStr = @"3:00";
    else if (secs >= 120) {
        timeStr = [NSString stringWithFormat:@"2:%02d", secs%60];
    }
    else if (secs >= 60) {
        timeStr = [NSString stringWithFormat:@"1:%02d", secs%60];
    }
    else timeStr = [NSString stringWithFormat:@"0:%02d", secs];
    self._timeLabel.string = timeStr;
    if (secs <=5 && secs >0) {
        [[OALSimpleAudio sharedInstance] playEffect:@"Sounds/timer.wav"];
    }
    if (secs == 0)
    {
        [[OALSimpleAudio sharedInstance] playEffect:@"Sounds/endgame.wav"];
        CCNode *popup = [CCBReader load:@"Congrats" owner:self];
        popup.anchorPoint = ccp(0.5,0.5);
        popup.positionType = CCPositionTypeNormalized;
        popup.position = ccp(0.5,0.5);
        [self addChild:popup];
        self.paused = YES;
        _grid1.paused = YES;
        _grid1.userInteractionEnabled = NO;
    }
}
- (void) menu {
    [[OALSimpleAudio sharedInstance] playEffect:@"Sounds/click.wav"];
    [_grid1 stopSound];
    [[CCDirector sharedDirector] replaceScene:[CCBReader loadAsScene:@"MainScene"]];
}
- (void) replay {
    [[OALSimpleAudio sharedInstance] playEffect:@"Sounds/click.wav"];
    [_grid1 stopSound];
    CCScene *gameplay2Scene = [CCBReader loadAsScene:@"Gameplay2"];
    [[CCDirector sharedDirector] replaceScene:gameplay2Scene];
}
- (void) pause {
    [[OALSimpleAudio sharedInstance] playEffect:@"Sounds/click.wav"];
    self.paused = YES;
    _grid1.userInteractionEnabled = NO;
    
    _pauselayer.visible = YES;
}

- (void) Continue
{
    [[OALSimpleAudio sharedInstance] playEffect:@"Sounds/click.wav"];
    _pauselayer.visible = NO;
    self.paused = NO;
    _grid1.userInteractionEnabled = YES;
    
}
- (void) giveup
{
    [[OALSimpleAudio sharedInstance] playEffect:@"Sounds/click.wav"];
    [_grid stopSound];
    [[CCDirector sharedDirector] replaceScene:[CCBReader loadAsScene:@"MainScene"]];
}
- (void) sharetimemode
{
//    CCScene *myScene = [[CCDirector sharedDirector] runningScene];
//    CCNode *node = [myScene.children objectAtIndex:0];
//    UIImage *image = [Gameplay2 screenshotWithStartNode:node];
//    
//    FBSDKSharePhoto *photo = [[FBSDKSharePhoto alloc] init];
//    photo.image = image;
//    photo.userGenerated = YES;
//    FBSDKSharePhotoContent *content = [[FBSDKSharePhotoContent alloc] init];
//    content.photos = @[photo];
//    
//    FBSDKShareDialog *dialog = [[FBSDKShareDialog alloc] init];
//    dialog.fromViewController = [CCDirector sharedDirector];
//    [dialog setShareContent:content];
//    dialog.mode = FBSDKShareDialogModeShareSheet;
//    [dialog show];
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    // this should link to FB page for your app or AppStore link if published
    content.contentURL = [NSURL URLWithString:@"https://https://hunt.makeschool.com/posts/108"];
    // URL of image to be displayed alongside post
    //content.imageURL = [NSURL URLWithString:@"https://git.makeschool.com/MakeSchool-Tutorials/News/f744d331484d043a373ee2a33d63626c352255d4//663032db-cf16-441b-9103-c518947c70e1/cover_photo.jpeg"];
    // title of post
    content.contentTitle = [NSString stringWithFormat:@"I just got %zu scores in SushiTime!", _grid1.score];
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
