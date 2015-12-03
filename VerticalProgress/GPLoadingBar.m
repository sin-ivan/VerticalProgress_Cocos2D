//////////////////////////GAME PACK/////////////////////////////
//                                                            //
//  GPLoadingBar.m                                            //
//  GPLoadingBarExample                                       //
//                                                            //
//  Created by Techy on 6/17/11.                              //  
//  Copyright 2011 Web-Geeks/Wrensation. All rights reserved. //
//                                                            //
////////////////////////////////////////////////////////////////

#import <CoreGraphics/CoreGraphics.h>
#import "GPLoadingBar.h"

#define kProgressIntervalForAnimation 0.05
#define DEFAULT_SPEED 40

@interface GPLoadingBar() {
    CGFloat loadingProgressForAnimation;
    CGFloat onePercentValue;
    CGFloat startProgressValue;
}

@property (nonatomic, retain) CCSprite *barSprite;
@property (nonatomic, retain) CCSprite *maskSprite;
@property (nonatomic, retain) CCSprite *insetSprite;
@property (nonatomic, retain) CCSprite *masked;
@property (nonatomic, retain) CCRenderTexture *renderMasked;
@property (nonatomic, retain) CCRenderTexture *renderMaskNegative;
@property (nonatomic, retain) NSString *bar;
@property (nonatomic, retain) NSString *inset;
@property (nonatomic, retain) NSString *mask;

@end

@implementation GPLoadingBar
@synthesize active, loadingProgress;

+(id) loadingBarWithBar:(NSString *)b inset:(NSString *)i mask:(NSString *)m {
    return [[[self alloc] initLoadingBarWithBar:b inset:i mask:m] autorelease];
}

+ (id)positionedLoadingBarWithBar:(NSString *)b inset:(NSString *)i mask:(NSString *)m showProgressValue:(BOOL)showProgressValue {
    return [[[self alloc] positionedLoadingBarWithBar:b inset:i mask:m showProgressValue:showProgressValue] autorelease];
}

-(id) positionedLoadingBarWithBar:(NSString *)b inset:(NSString *)i mask:(NSString *)m showProgressValue:(BOOL)showProgressValue {
    if ((self = [super init])) {
        self.bar = [[[NSString alloc] initWithString:b] autorelease];
        self.inset = [[[NSString alloc] initWithString:i] autorelease];
        self.mask = [[[NSString alloc] initWithString:m] autorelease];
        spritesheet = NO;

        self.barSprite = [[[CCSprite alloc] initWithFile:self.bar] autorelease];
        self.barSprite.anchorPoint = ccp(0.5,0.5);

        self.insetSprite = [[[CCSprite alloc] initWithFile:self.inset] autorelease];
        self.insetSprite.anchorPoint = ccp(0.5,0.5);

        self.maskSprite = [[[CCSprite alloc] initWithFile:self.mask] autorelease];
        self.maskSprite.anchorPoint = ccp(1,0.5);

        barSize = self.insetSprite.contentSize;
        barMid = ccp(barSize.width * 0.5f, barSize.height * 0.5f);

        self.barSprite.position = barMid;
        self.insetSprite.position = barMid;
        
        self.progressBarSpeed = DEFAULT_SPEED;

        [self addChild:self.insetSprite z:1];
        self.maskSprite.position = ccp(((barSize.width - self.barSprite.boundingBox.size.width) / 2), barMid.y);

        self.renderMasked = [[[CCRenderTexture alloc] initWithWidth:(int)barSize.width height:(int)barSize.height pixelFormat:kCCTexture2DPixelFormat_RGBA8888] autorelease];
        [[self.renderMasked sprite] setBlendFunc: (ccBlendFunc) {GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA}];
        self.renderMasked.position = self.barSprite.position;
        self.renderMaskNegative = [[[CCRenderTexture alloc] initWithWidth:(int)barSize.width height:(int)barSize.height pixelFormat:kCCTexture2DPixelFormat_RGBA8888] autorelease];
        [[self.renderMaskNegative sprite] setBlendFunc: (ccBlendFunc) {GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA}];
        self.renderMaskNegative.position = self.barSprite.position;

        [self.maskSprite setBlendFunc: (ccBlendFunc) {GL_ZERO, GL_ONE_MINUS_SRC_ALPHA}];

        [self clearRender];

        [self maskBar];

        [self addChild:self.renderMasked z:2];

        if (showProgressValue) {
            int fontSize = 24;
            int labelOffsetY = 8;
            if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
                fontSize /= 2;
                labelOffsetY = 4;
            }
            self.valueLabel = [CCLabelTTF labelWithString:@"" fontName:@"MikadoBold" fontSize:fontSize];
            self.valueLabel.anchorPoint = ccp(0.5, 0);
            self.valueLabel.position = ccp(barMid.x, labelOffsetY);
            [self addChild:self.valueLabel z:3];
        }

        self.barType = kBarTypeRectangleHorizontal;
    }
    return self;
}

- (CGSize)contentSize
{
    return self.barSprite.contentSize;
}

-(id) initLoadingBarWithBar:(NSString *)b inset:(NSString *)i mask:(NSString *)m {
    if ((self = [super init])) {
        self.bar = [[[NSString alloc] initWithString:b] autorelease];
        self.inset = [[[NSString alloc] initWithString:i] autorelease];
        self.mask = [[[NSString alloc] initWithString:m] autorelease];
        spritesheet = NO;

        barSize = [[CCDirector sharedDirector] winSize];

        barMid = ccp(barSize.width * 0.5f, barSize.height * 0.5f);

        self.barSprite = [[[CCSprite alloc] initWithFile:self.bar] autorelease];
        self.barSprite.anchorPoint = ccp(0.5,0.5);
        self.barSprite.position = barMid;

        self.insetSprite = [[[CCSprite alloc] initWithFile:self.inset]autorelease];
        self.insetSprite.anchorPoint = ccp(0.5,0.5);
        self.insetSprite.position = barMid;
        [self addChild:self.insetSprite z:1];

        self.maskSprite = [[[CCSprite alloc] initWithFile:self.mask] autorelease];
        self.maskSprite.anchorPoint = ccp(1,0.5);
        self.maskSprite.position = ccp(((barSize.width - self.barSprite.boundingBox.size.width) / 2), barMid.y);
        
        self.progressBarSpeed = DEFAULT_SPEED;

        self.renderMasked = [[[CCRenderTexture alloc] initWithWidth:barSize.width height:barSize.height pixelFormat:kCCTexture2DPixelFormat_RGBA8888] autorelease];
        [[self.renderMasked sprite] setBlendFunc: (ccBlendFunc) {GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA}];
        self.renderMasked.position = self.barSprite.position;
        self.renderMaskNegative = [[[CCRenderTexture alloc] initWithWidth:barSize.width height:barSize.height pixelFormat:kCCTexture2DPixelFormat_RGBA8888] autorelease];
        [[self.renderMaskNegative sprite] setBlendFunc: (ccBlendFunc) {GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA}];
        self.renderMaskNegative.position = self.barSprite.position;

        [self.maskSprite setBlendFunc: (ccBlendFunc) {GL_ZERO, GL_ONE_MINUS_SRC_ALPHA}];

        [self clearRender];

        [self maskBar];

        [self addChild:self.renderMasked z:2];
    }
    return self;
}

+(id) loadingBarWithBarFrame:(NSString *)b insetFrame:(NSString *)i maskFrame:(NSString *)m {
    return [[[self alloc] initLoadingBarWithBarFrame:b insetFrame:i maskFrame:m] autorelease];
}
-(id) initLoadingBarWithBarFrame:(NSString *)b insetFrame:(NSString *)i maskFrame:(NSString *)m {
    if ((self = [super init])) {
        self.bar = [[[NSString alloc] initWithString:b] autorelease];
        self.inset = [[[NSString alloc] initWithString:i] autorelease];
        self.mask = [[[NSString alloc] initWithString:m] autorelease];
        spritesheet = YES;
		
		barSize = [[CCDirector sharedDirector] winSize];
        
        barMid = ccp(barSize.width * 0.5f, barSize.height * 0.5f);
        
        self.barSprite = [[[CCSprite alloc] initWithSpriteFrameName:self.bar] autorelease];
        self.barSprite.anchorPoint = ccp(0.5,0.5);
        self.barSprite.position = barMid;
		
        self.insetSprite = [[[CCSprite alloc] initWithSpriteFrameName:self.inset] autorelease];
        self.insetSprite.anchorPoint = ccp(0.5,0.5);
        self.insetSprite.position = barMid;
        [self addChild:self.insetSprite z:1];
		
        self.maskSprite = [[[CCSprite alloc] initWithSpriteFrameName:self.mask] autorelease];
        self.maskSprite.anchorPoint = ccp(1,0.5);
        self.maskSprite.position = ccp(((barSize.width - self.barSprite.boundingBox.size.width) / 2), barMid.y);
        
        self.progressBarSpeed = DEFAULT_SPEED;
        
        self.renderMasked = [[[CCRenderTexture alloc] initWithWidth:barSize.width height:barSize.height pixelFormat:kCCTexture2DPixelFormat_RGBA8888] autorelease];
        [[self.renderMasked sprite] setBlendFunc: (ccBlendFunc) {GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA}];
        self.renderMasked.position = self.barSprite.position;
        self.renderMaskNegative = [[[CCRenderTexture alloc] initWithWidth:barSize.width height:barSize.height pixelFormat:kCCTexture2DPixelFormat_RGBA8888] autorelease];
        [[self.renderMaskNegative sprite] setBlendFunc: (ccBlendFunc) {GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA}];
        self.renderMaskNegative.position = self.barSprite.position;
        
        [self.maskSprite setBlendFunc: (ccBlendFunc) {GL_ZERO, GL_ONE_MINUS_SRC_ALPHA}];
        
        [self clearRender];
        
        [self maskBar];
        
        [self addChild:self.renderMasked z:2];
    }
    return self;
}
-(void) clearRender {
    [self.renderMasked beginWithClear:0.0f g:0.0f b:0.0f a:0.0f];
    
    [self.barSprite visit];
    
    [self.renderMasked end];
    
    [self.renderMaskNegative beginWithClear:0.0f g:0.0f b:0.0f a:0.0f];

    [self.barSprite visit];
    
    [self.renderMaskNegative end];
}
-(void) maskBar{
    [self.renderMaskNegative begin];
    
    glColorMask(0.0f, 0.0f, 0.0f, 1.0f);
    
    [self.maskSprite visit];
    
    glColorMask(1.0f, 1.0f, 1.0f, 1.0f);
    
    [self.renderMaskNegative end];
        
    self.masked = self.renderMaskNegative.sprite;
    self.masked.position = barMid;

    [self.masked setBlendFunc: (ccBlendFunc) { GL_ZERO, GL_ONE_MINUS_SRC_ALPHA }];
    
    [self.renderMasked begin];
    
    glColorMask(0.0f, 0.0f, 0.0f, 1.0f);
    
    [self.masked visit];

    glColorMask(1.0f, 1.0f, 1.0f, 1.0f);

    [self.renderMasked end];
}

- (void)updateValue:(CGFloat)value fromValue:(CGFloat)fromValue toValue:(CGFloat)toValue
{
    if (self.valueLabel) {
        startProgressValue = fromValue;
        onePercentValue = (toValue - fromValue) / 100;
    }
}

- (void)setLoadingProgressAnimated:(float)lp
{
    loadingProgressForAnimation = lp;

    if (loadingProgress >= 100) {
        loadingProgress = 0;
    }
    if ([self.delegate respondsToSelector:@selector(progressBarStartedChangingValue:)]) {
        [self.delegate progressBarStartedChangingValue:self];
    }
    
    [self schedule:@selector(updateProgress:)];
    [self schedule:@selector(updateTextLabel) interval:0.05];
}

- (float)loadingProgressAnimated
{
    return loadingProgressForAnimation;
}

-(void) updateProgress:(ccTime)dt{
    loadingProgress = loadingProgress + (dt * self.progressBarSpeed);

    if (loadingProgress > 100) {
        loadingProgress = 100;
        [self unscheduleUpdateSelectorsAndPerformLastBarUpdate];
    } else {
        if (loadingProgress >= loadingProgressForAnimation) {
            loadingProgress = loadingProgressForAnimation;
            [self unscheduleUpdateSelectorsAndPerformLastBarUpdate];
        }
    }

    [self setLoadingProgress:loadingProgress];
}

- (void)unscheduleUpdateSelectorsAndPerformLastBarUpdate {
    if ([self.delegate respondsToSelector:@selector(progressBarFinishedChangingValue:)]) {
        [self.delegate progressBarFinishedChangingValue:self];
    }

    [self updateTextLabel];
    [self unschedule:@selector(updateProgress:)];
    [self unschedule:@selector(updateTextLabel)];
    loadingProgressForAnimation = 0;
    
    NSDictionary *notifDictionary = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:loadingProgress] forKey:@"progress"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ProgressBarUnscheduled" object:nil userInfo:notifDictionary];
}

- (void)updateTextLabel
{
    if (self.valueLabel) {
        CGFloat pointValue = startProgressValue + (onePercentValue * loadingProgress);
        NSString *valueString = [NSString stringWithFormat:@"%.0f", pointValue];
        
        if (self.maxValue) {
            valueString = [valueString stringByAppendingFormat:@"/%.0f", self.maxValue];
        }

        if (self.showPercentSign) {
            valueString = [valueString stringByAppendingString:@"%"];
        }
        [self.valueLabel setString:valueString];
    }
}

-(void) setLoadingProgress:(float)lp {
    loadingProgress = lp;
    if (loadingProgress > 100) {
        loadingProgress = 100;
    }
    [self drawLoadingBar];
    [self updateTextLabel];
}

-(void) drawLoadingBar {

    CGPoint newPosition = CGPointZero;
    switch (self.barType) {
        case kBarTypeRectangleHorizontal:
            newPosition = ccp(((barSize.width - self.barSprite.boundingBox.size.width) / 2) +(loadingProgress / 100 * self.barSprite.boundingBox.size.width), barMid.y);
            break;
        case kBarTypeRectangleVertical:
            newPosition = ccp(self.barSprite.boundingBox.size.width, -(self.barSprite.boundingBox.size.height / 2) + (loadingProgress / 100 * self.barSprite.boundingBox.size.height));
            break;
        case kBarTypeRounded:
            //not implemented
            break;
        default:
            break;
    }
    self.maskSprite.position = newPosition;
    [self clearRender];
    [self maskBar];
}

- (void)setOpacity:(GLubyte)opacity {
    self.masked.opacity = opacity;
    self.insetSprite.opacity = opacity;
    self.maskSprite.opacity = opacity;
    self.barSprite.opacity = opacity;
    self.valueLabel.opacity = opacity;
    if (opacity < 50) {
        self.renderMasked.visible = NO;
        self.renderMaskNegative.visible = NO;
    }
}

-(void)dealloc{
    [self unscheduleAllSelectors];
    [self removeAllChildrenWithCleanup:YES];

    self.masked = nil;
    self.renderMasked = nil;
    self.renderMaskNegative = nil;
    self.maskSprite = nil;
    self.barSprite = nil;
    self.insetSprite = nil;
    self.mask = nil;
    self.bar = nil;
    self.inset = nil;
    self.valueLabel = nil;
    
    [super dealloc];
}

@end
