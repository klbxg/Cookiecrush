#import "MainScene.h"

@implementation MainScene

- (void)move {
    CCScene *gameplayScene = [CCBReader loadAsScene:@"Gameplay"];
    [[CCDirector sharedDirector] replaceScene:gameplayScene];
}
- (void)time {
    CCScene *gameplay2Scene = [CCBReader loadAsScene:@"Gameplay2"];
    [[CCDirector sharedDirector] replaceScene:gameplay2Scene];
}
@end
