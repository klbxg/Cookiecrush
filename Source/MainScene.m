#import "MainScene.h"


@implementation MainScene

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
