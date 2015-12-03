//
//  LevelItemElement.m
//  VerticalProgress
//
//  Created by Ivan Sinitsa on 10/11/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "LevelItemElement.h"

@interface LevelItemElement()

@property (nonatomic, retain) CCSprite *mainImageSprite;
//@property ()

@end

@implementation LevelItemElement

+ (LevelItemElement *)buttonWithLevelInfo:(NSDictionary *)levelInfo
{
    LevelItemElement *sprite = [LevelItemElement node];
    if (sprite) {
        sprite.anchorPoint = ccp(0.5, 0.5);
        CCDirector *director = [CCDirectorIOS sharedDirector];
        [[director touchDispatcher] addTargetedDelegate:sprite priority:0 swallowsTouches:YES];

//        image.anchorPoint = ccp(0.5, 0.5);
//        image.position = ccp(image.boundingBox.size.width / 2, image.boundingBox.size.height / 2);
//        [sprite addChild:image];
    }

    return sprite;
}


- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint location = [touch locationInView:[touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    if (CGRectContainsPoint(self.boundingBox,location)) {
        NSLog(@"began");
        return YES;
    }
    return NO;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint location = [touch locationInView:[touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    if (CGRectContainsPoint(self.boundingBox,location)) {
        NSLog(@"moved");
    }
}
- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint location = [touch locationInView:[touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    if (CGRectContainsPoint(self.boundingBox,location)) {
        NSLog(@"ended");
    }
}

@end
