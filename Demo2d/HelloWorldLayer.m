//
//  HelloWorldLayer.m
//  Demo2d
//
//  Created by GuoTeng on 13-7-26.
//  Copyright baroqueworkshop 2013年. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"
#import "CCTouchDispatcher.h"
#import "SimpleAudioEngine.h"

#pragma mark - HelloWorldLayer

#define WINSIZE ([CCDirector sharedDirector].winSize)
#define LEFT YES
#define RIGHT NO

// HelloWorldLayer implementation
@implementation HelloWorldLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(void) registerWithTouchDispatcher
{
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super initWithColor:ccc4(255, 255, 255, 255)]) ) {
        self.monsters = [[[NSMutableArray alloc] init] autorelease];
        
        moveStep = 10;
        
        [self setTouchEnabled:YES];
        
        [self addPlayer];

        [self addControlPad];
        
        [self schedule:@selector(gameLogic:) interval:1.0];
        [self schedule:@selector(update:)];
        
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"background-music-aac.caf"];
	}
	return self;
}

- (void)gameLogic:(ccTime)dt
{
    [self addMonster];
}

- (void)update:(ccTime)delta
{
    NSMutableArray *monstersToDelete = [[NSMutableArray alloc] init];
    for (CCSprite *monster in self.monsters) {
        if (CGRectIntersectsRect(monster.boundingBox, player.boundingBox)) {
            [monstersToDelete addObject:monster];
            [[SimpleAudioEngine sharedEngine] playEffect:@"pew-pew-lei.caf"];
            [self shake:nil];
        }
    }
    
    for (CCSprite *monster in monstersToDelete) {
        [self.monsters removeObject:monster];
        [self removeChild:monster cleanup:YES];
    }
    
    [monstersToDelete release];
}

- (void) addPlayer
{
    CGSize winSize = [CCDirector sharedDirector].winSize;
    player = [CCSprite spriteWithFile:@"player.png"];
    player.position = ccp(winSize.width/2, player.contentSize.height/2 + 60);
    [self addChild:player];
}

- (void) addControlPad
{
    CCSpriteBatchNode *controls = [CCSpriteBatchNode batchNodeWithFile:@"texture.png"];
    [self addChild:controls z:0];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"coordinates.plist"];
    
    left = [CCSprite spriteWithSpriteFrameName:@"left.png"];
    left.position = ccp(left.contentSize.width/2, left.contentSize.height/2);
    [self addChild:left];
    
    right = [CCSprite spriteWithSpriteFrameName:@"right.png"];
    right.position = ccp(WINSIZE.width - right.contentSize.width/2, right.contentSize.height/2);
    [self addChild:right];
}

- (void) addMonster
{
    CCSprite *monster = [CCSprite spriteWithFile:@"monster.png"];
    int minX = monster.contentSize.width/2;
    int maxX = WINSIZE.width - monster.contentSize.width/2;
    int rangeX = maxX - minX;
    int actualX = (arc4random() % rangeX) + minX;
    
    monster.tag = 1;
    [self.monsters addObject:monster];
    monster.position = ccp(actualX, WINSIZE.height + monster.contentSize.height/2);
    [self addChild:monster];
    
    int minDuration = 2.0;
    int maxDuration = 4.0;
    int rangeDuration = maxDuration - minDuration;
    int actualDuration = (arc4random() % rangeDuration) + minDuration;
    
    CCMoveTo *actionMove = [CCMoveTo actionWithDuration:actualDuration position:ccp(actualX, -monster.contentSize.height/2)];
    CCCallBlockN *actionMoveDone = [CCCallBlockN actionWithBlock:^(CCNode *node) {
        [node removeFromParentAndCleanup:YES];
        [self.monsters removeObject:node];
    }];
    [monster runAction:[CCSequence actions:actionMove, actionMoveDone, nil]];
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
    [_monsters release];
    _monsters = nil;
	// don't forget to call "super dealloc"
	[super dealloc];
}

- (void) shake:(id)sender
{
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
}

- (void) movePlayer:(BOOL)direction
{
    CGPoint originPoint = [player position];
    float newX;
    if (direction) { // left
        newX = originPoint.x - moveStep;
        if (newX < [player contentSize].width/2) {
            newX = [player contentSize].width/2;
        }
    }
    else
    {
        newX = originPoint.x + moveStep;
        if (newX > WINSIZE.width - [player contentSize].width/2) {
            newX = WINSIZE.width - [player contentSize].width/2;
        }
    }

    CGPoint newPoint = ccp(newX, originPoint.y);
    [player setPosition:newPoint];
}

#pragma mark GameKit delegate

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}



#pragma mark touch delegate
-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint location = [self convertTouchToNodeSpace:touch];
    
    if (CGRectContainsPoint([left boundingBox], location)) {
        NSLog(@"press left");
        [self movePlayer:LEFT];
        [left setDisplayFrame:[CCSpriteFrame frameWithTextureFilename:@"left_down.png" rect:left.boundingBox]];
    }
    else if (CGRectContainsPoint([right boundingBox], location))
    {
        NSLog(@"press right");
        [self movePlayer:RIGHT];
        [right setDisplayFrame:[CCSpriteFrame frameWithTextureFilename:@"right_down.png" rect:right.boundingBox]];
    }
    return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    [left setDisplayFrame:[CCSpriteFrame frameWithTextureFilename:@"left.png" rect:left.boundingBox]];
    [right setDisplayFrame:[CCSpriteFrame frameWithTextureFilename:@"right.png" rect:right.boundingBox]];
}
@end
