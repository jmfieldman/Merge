//
//  PreloadedSFX.m
//  ExperimentF
//
//  Created by Jason Fieldman on 11/12/10.
//  Copyright 2010 Jason Fieldman. All rights reserved.
//

#import "PreloadedSFX.h"
//#import "GlobalAppSettings.h"

#define FX_INSTANCES 3

static BOOL s_initialized = NO;

static AVAudioPlayer *s_players[PLSFX_COUNT][FX_INSTANCES];
static int            s_instance[PLSFX_COUNT];
static BOOL           s_mute = NO;

static NSString *s_filenames[PLSFX_COUNT] = {
	@"tap.wav",
	
	
};

@implementation PreloadedSFX

+ (void) initializePreloadedSFX {
	if (s_initialized) return;
	s_initialized = YES;
	
	NSString *resourceDir = [[NSBundle mainBundle] resourcePath];
	
	[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
	[[AVAudioSession sharedInstance] setActive:YES error:nil];
	
	for (int i = 0; i < PLSFX_COUNT; i++) {
		s_instance[i] = 0;
		
		NSString *pathToSFX = [NSString stringWithFormat:@"%@/%@", resourceDir, s_filenames[i]];
		NSData *data = [NSData dataWithContentsOfFile:pathToSFX];
		for (int n = 0; n < FX_INSTANCES; n++) {
			s_players[i][n] = [[AVAudioPlayer alloc] initWithData:data error:nil];
			[s_players[i][n] prepareToPlay];
			s_players[i][n].volume = 1;
		}
	}
	
	/* load muteness */
	PersistentDictionary *d = [PersistentDictionary dictionaryWithName:@"audiosettings"];
	s_mute = [[d.dictionary objectForKey:@"mute"] boolValue];
}

+ (void) setMute:(BOOL)mute {
	s_mute = mute;
	
	PersistentDictionary *d = [PersistentDictionary dictionaryWithName:@"audiosettings"];
	d.dictionary[@"mute"] = [NSNumber numberWithBool:s_mute];
	[d saveToFile];
}

+ (BOOL) isMute {
	return s_mute;
}

+ (void) playSFX:(PreloadedSFXType_t)type {
	//if (!g_sfxEnabled) return;
	
	if (s_mute) return;
	
	int curInstance = s_instance[type];
	
	[s_players[type][curInstance] stop];
	s_players[type][curInstance].currentTime = 0;
	[s_players[type][curInstance] play];
	
	curInstance++;
	if (curInstance >= FX_INSTANCES) curInstance = 0;
	s_instance[type] = curInstance;
}

+ (void) setVolume:(float)volume {
	for (int i = 0; i < PLSFX_COUNT; i++) {
		for (int n = 0; n < FX_INSTANCES; n++) {
			s_players[i][n].volume = volume;
		}
	}
}

@end
