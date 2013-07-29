//
//  GameOverLayer.h
//  Demo2d
//
//  Created by GuoTeng on 13-7-29.
//  Copyright (c) 2013年 baroqueworkshop. All rights reserved.
//

#import "CCLayer.h"
#import "cocos2d.h"

@interface GameOverLayer : CCLayerColor

+ (CCScene *)sceneWithWon:(BOOL)won highSocre:(int)score;
- (id)initWithWon:(BOOL)won highSocre:(int)score;

@end
