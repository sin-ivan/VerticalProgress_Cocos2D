//////////////////////////GAME PACK/////////////////////////////
//                                                            //
//  GPLoadingBar.h                                            //
//  GPLoadingBarExample                                       //
//                                                            //
//  Created by Techy on 6/17/11.                              //  
//  Copyright 2011 Web-Geeks/Wrensation. All rights reserved. //
//                                                            //
////////////////////////////////////////////////////////////////

#import <Foundation/Foundation.h>
#import "cocos2d.h"

typedef enum{
	kBarTypeRounded, //not implemented
	kBarTypeRectangleHorizontal,
    kBarTypeRectangleVertical
} kBarType;

@class GPLoadingBar;
@protocol GPLoadingBarDelegate <NSObject>
@optional
- (void)progressBarStartedChangingValue:(GPLoadingBar *)progressBar;
- (void)progressBarFinishedChangingValue:(GPLoadingBar *)progressBar;
@end

@interface GPLoadingBar : CCSprite {
    float loadingProgress, progressValueBeforeUpdate;
    BOOL active, spritesheet;
    CGPoint barMid;
    CGSize barSize;
}

@property(nonatomic, retain, readonly)	NSString *bar, *inset;
@property(nonatomic) float loadingProgress;
@property(nonatomic) float loadingProgressAnimated;
@property BOOL active;
@property (nonatomic, assign) CGFloat maxValue;
@property (nonatomic, assign) id <GPLoadingBarDelegate> delegate;
@property (nonatomic, retain) CCLabelTTF *valueLabel;
@property (nonatomic, assign) int progressBarSpeed;
@property (nonatomic, assign) BOOL showPercentSign;
@property (nonatomic, assign) kBarType barType;

+(id) loadingBarWithBar:(NSString *)b inset:(NSString *)i mask:(NSString *)m;
+ (id)positionedLoadingBarWithBar:(NSString *)b inset:(NSString *)i mask:(NSString *)m showProgressValue:(BOOL)showProgressValue;
-(id) initLoadingBarWithBar:(NSString *)b inset:(NSString *)i mask:(NSString *)m;
+(id) loadingBarWithBarFrame:(NSString *)b insetFrame:(NSString *)i maskFrame:(NSString *)m;
-(id) initLoadingBarWithBarFrame:(NSString *)b insetFrame:(NSString *)i maskFrame:(NSString *)m;
- (void)updateValue:(CGFloat)value fromValue:(CGFloat)fromValue toValue:(CGFloat)toValue;

- (void)setLoadingProgressAnimated:(float)lp;
-(void) setLoadingProgress:(float)lv;
-(void) clearRender;
-(void) maskBar;
-(void) drawLoadingBar;

@end
