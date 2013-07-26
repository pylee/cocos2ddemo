//
//  HelloWorldLayer.h
//  Demo2d
//
//  Created by GuoTeng on 13-7-26.
//  Copyright baroqueworkshop 2013年. All rights reserved.
//


#import <GameKit/GameKit.h>

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// HelloWorldLayer
@interface HelloWorldLayer : CCLayerColor <GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate>
{
    float moveStep;
    CCSprite *player;
    CCSprite *left;
    CCSprite *right;
}

@property (nonatomic, retain) NSMutableArray *monsters;

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
