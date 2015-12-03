//
//  LevelItemElement.h
//  VerticalProgress
//
//  Created by Ivan Sinitsa on 10/11/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface LevelItemElement : CCNode <CCTargetedTouchDelegate> {
    
}

+ (LevelItemElement *)buttonWithLevelInfo:(NSDictionary *)levelInfo;

@end
