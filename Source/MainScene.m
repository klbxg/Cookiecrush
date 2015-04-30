#import "MainScene.h"
#import "GameGlobals.h"

@implementation MainScene

- (void) didLoadFromCCB
{
    [OALSimpleAudio sharedInstance];
    GameGlobals* g = [GameGlobals globals];
    
    _moveHighScore.string = [NSString stringWithFormat:@"%d",g.highScore1];
    _timeHighScore.string = [NSString stringWithFormat:@"%d",g.highScore2];
}

- (void)move {
    [[OALSimpleAudio sharedInstance] playEffect:@"Sounds/click.wav"];
    CCScene *gameplayScene = [CCBReader loadAsScene:@"Gameplay"];
    [[CCDirector sharedDirector] replaceScene:gameplayScene];
}
- (void)time {
    [[OALSimpleAudio sharedInstance] playEffect:@"Sounds/click.wav"];
    CCScene *gameplay2Scene = [CCBReader loadAsScene:@"Gameplay2"];
    [[CCDirector sharedDirector] replaceScene:gameplay2Scene];
}
@end
