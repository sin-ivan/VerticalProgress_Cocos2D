//
//  HelloWorldLayer.m
//  VerticalProgress
//
//  Created by Ivan Sinitsa on 10/7/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"

#import "GPLoadingBar.h"
#import "LevelItemElement.h"

#pragma mark - HelloWorldLayer

@interface HelloWorldLayer()

@property (nonatomic, retain) GPLoadingBar *loadingBar;

@end

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

- (BOOL)prepareProgressImage:(NSString *)imageName patternImage:(NSString *)patternImage
{
    //base image data extraction
    CGImageRef imageBaseRef = [[UIImage imageNamed:imageName] CGImage];
    NSUInteger baseImageWidth = CGImageGetWidth(imageBaseRef);
    NSUInteger baseImageHeight = CGImageGetHeight(imageBaseRef);
    CFDataRef basePixelData = CGDataProviderCopyData(CGImageGetDataProvider(imageBaseRef));
    const UInt8* baseData = CFDataGetBytePtr(basePixelData);
    int baseImageDataLength = CFDataGetLength(basePixelData);
    int baseImageOnePixelSize = baseImageDataLength / baseImageHeight / baseImageWidth;

    //pattern image data extraction
    CGImageRef imagePatternRef = [[UIImage imageNamed:patternImage] CGImage];
    NSUInteger patternImageWidth = CGImageGetWidth(imagePatternRef);
    NSUInteger patternImageHeight = CGImageGetHeight(imagePatternRef);
    CFDataRef patternPixelData = CGDataProviderCopyData(CGImageGetDataProvider(imagePatternRef));
    const UInt8* patternData = CFDataGetBytePtr(patternPixelData);

    int sizeOfArray = baseImageWidth * baseImageHeight * baseImageOnePixelSize;
    UInt8 *prepairedPatternData = malloc(sizeOfArray);

    int xOffset = ((patternImageWidth - baseImageWidth) / 2);
    int yOffset = ((patternImageHeight - baseImageHeight) / 2);

    int dataIndex = 0;
    for (int y = 0; y < baseImageHeight; y++) {
        for (int x = 0; x < baseImageWidth; x++) {
            int patternPixelDataIndex = (y * patternImageWidth * baseImageOnePixelSize) + (yOffset * patternImageWidth * baseImageOnePixelSize) + (x * baseImageOnePixelSize) + (xOffset * baseImageOnePixelSize);
            prepairedPatternData[dataIndex] = patternData[patternPixelDataIndex];
            prepairedPatternData[dataIndex+1] = patternData[patternPixelDataIndex+1];
            prepairedPatternData[dataIndex+2] = patternData[patternPixelDataIndex+2];
            prepairedPatternData[dataIndex+3] = patternData[patternPixelDataIndex+3];

            dataIndex += baseImageOnePixelSize;
        }
    }

    //rewriting pixel data
    int byteIndex = 0;
    for (int ii = 0 ; ii < baseImageWidth * baseImageHeight ; ++ii)
    {
        prepairedPatternData[byteIndex + 3] = baseData[byteIndex + 3];
        byteIndex += baseImageOnePixelSize;
    }


	CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, prepairedPatternData, sizeOfArray, NULL);

	CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
	if(colorSpaceRef == NULL) {
		NSLog(@"Error allocating color space");
        CFRelease(basePixelData);
        CFRelease(patternPixelData);
		CGDataProviderRelease(provider);
		return nil;
	}

	CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast;
	CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;

	CGImageRef iref = CGImageCreate(baseImageWidth,
                                    baseImageHeight,
                                    8,
                                    32,
                                    baseImageOnePixelSize * baseImageWidth,
                                    colorSpaceRef,
                                    bitmapInfo, 
                                    provider,	// data provider
                                    NULL,		// decode
                                    YES,			// should interpolate
                                    renderingIntent);

    UIImage *uiimage = [UIImage imageWithCGImage:iref];

    //save new image
    NSURL *filePath = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"img.png"];
    [UIImageJPEGRepresentation(uiimage, 100) writeToFile:filePath.path atomically:YES];

    CGColorSpaceRelease(colorSpaceRef);
	CGImageRelease(iref);
    CFRelease(basePixelData);
    CFRelease(patternPixelData);
	CGDataProviderRelease(provider);
    free(prepairedPatternData);

    return YES;
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super init]) ) {

        [self prepareProgressImage:@"Placeholder.png" patternImage:@"Placeholder_green.png"];

        GPLoadingBar *loadingBar = [GPLoadingBar positionedLoadingBarWithBar:@"img.png"
                                                                       inset:@"Placeholder.png"
                                                                        mask:@"Placeholder_mask.png"
                                                           showProgressValue:YES];
        loadingBar.barType = kBarTypeRectangleVertical;
        loadingBar.loadingProgress = 0;
        loadingBar.position = ccp(500, 500);
        self.loadingBar = loadingBar;
        [self addChild:loadingBar];

        LevelItemElement *button = [LevelItemElement buttonWithLevelInfo:nil];
        button.position = ccp(100, 100);
        [self addChild:button];
    }
	return self;
}
- (void)onEnterTransitionDidFinish
{
    [self schedule:@selector(increaseLoadingProgress) interval:0.2];
}

- (void)increaseLoadingProgress
{
    self.loadingBar.loadingProgress += 1;
}

- (void) dealloc
{
    self.loadingBar = nil;
	[super dealloc];
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
@end
