//
//  PreloadedSFX.h
//  ExperimentF
//
//  Created by Jason Fieldman on 11/12/10.
//  Copyright 2010 Jason Fieldman. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum PreloadedSFXType {
	PLSFX_MENUTAP = 0,
	
	PLSFX_BEAT1,
	PLSFX_BEAT2,
	
	PLSFX_BOMB,
	
	PLSFX_GAMEOVER,
	PLSFX_GAMESTART,
	
	PLSFX_MOVE,
	
	PLSFX_SCORE1,
	PLSFX_SCORE2,
	PLSFX_SCORE3,
	PLSFX_SCORE4,
	PLSFX_SCORE5,
	PLSFX_SCORE6,
	PLSFX_SCORE7,
	
	PLSFX_COUNT,
} PreloadedSFXType_t;

#define NUM_BEATS  2
#define NUM_SCORES 7

@interface PreloadedSFX : NSObject {

}

+ (void) setMute:(BOOL)mute;
+ (BOOL) isMute;

+ (void) initializePreloadedSFX;

+ (void) playSFX:(PreloadedSFXType_t)type;

+ (void) setVolume:(float)volume;

@end
