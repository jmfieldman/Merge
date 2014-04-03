//
//  GameNavigationController.m
//  Merge
//
//  Created by Jason Fieldman on 3/13/14.
//  Copyright (c) 2014 Jason Fieldman. All rights reserved.
//

#import "GameNavigationController.h"

#define SCORE_LABEL_FONT @"MuseoSansRounded-300"
#define SCORE_VALUE_FONT @"MuseoSansRounded-500"
#define MENU_FONT        @"MuseoSansRounded-700"

#define SPAWN_DELAY_HALF_LIFE 50
#define SPAWN_INITIAL_DELAY   1.0
#define SPAWN_RATE_MIN        0.30

#define SPECIAL_RATE 0.15 /* 0.15 */
#define BLOCKER_RATE 0.5
#define BOMB_RATE    0.5

#define SPAWN_HEALTH_DECREMENT 0.05
#define SPAWN_HEALTH_REGEN     0.004

#define SPAWNS_UNTIL_PENALTY     10
#define SPAWNS_UNTIL_MAX_PENALTY 10

static BOOL _cycleCheck = NO;

@interface GameNavigationController ()

@end

@implementation GameNavigationController

SINGLETON_IMPL(GameNavigationController);

- (id)init {
	if ((self = [super init])) {

		self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
		//self.view.backgroundColor = [UIColor colorWithWhite:248/255.0 alpha:1];
		self.view.backgroundColor = [UIColor colorWithRed:0xF0/255.0 green:0xEF/255.0 blue:0xEC/255.0 alpha:1];
		self.view.backgroundColor = [UIColor colorWithRed:0x10/255.0 green:0x20/255.0 blue:0x30/255.0 alpha:1];
		
		/* Initialize shape cells array */
		_shapeCells = [NSMutableArray array];
		
		/* Initialize board container and board */
		_boardContainer = [[UIView alloc] initWithFrame:CGRectMake(8, 70, 304, 304)];
		_boardContainer.backgroundColor = [UIColor colorWithWhite:1 alpha:0.15];
		_boardContainer.layer.borderColor = [UIColor grayColor].CGColor;
		_boardContainer.layer.cornerRadius = 8;
		_boardContainer.layer.shadowRadius = 2;
		_boardContainer.layer.shadowOpacity = 0.35;
		_boardContainer.layer.shadowOffset = CGSizeMake(0, 0);
		_boardContainer.center = self.view.center;
		[self.view addSubview:_boardContainer];
		
		_board = [[BoardView alloc] initWithFrame:CGRectMake(12, 12, 280, 280) sideCount:8 cellSize:30];
		_board.delegate = self;
		_board.alpha = 0.1;
		[_boardContainer addSubview:_board];
		
		/* This is the swipe catching view */
		_swipeCatcher = [[SwipeCatcher alloc] initWithFrame:self.view.bounds];
		_swipeCatcher.delegate = self;
		_swipeCatcher.userInteractionEnabled = NO;
		[self.view addSubview:_swipeCatcher];
		
		/* This is a test to pre-populate the board */
		#if 0
		for (int i = 0; i <= MAX_POLYGON_ID; i++) {
			[_board addShape:i at:CGPointMake(i&3, i>>2) delay:0 duration:0];
		}
		#endif
		
		#if 0
		UIButton *test = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[test setTitle:@"test" forState:UIControlStateNormal];
		[test addTarget:self action:@selector(test:) forControlEvents:UIControlEventTouchUpInside];
		test.frame = CGRectMake(0, 400, 80, 80);
		[self.view addSubview:test];
		#endif
		
		_spawnBasis  = 10;
		_spawnDelayDecay = (-0.6931471) / SPAWN_DELAY_HALF_LIFE;
		
		[self startDemoMode];
		[self beginSpawning];
		
		
		/* Score fields */
		_nameScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 40)];
		_nameScoreLabel.font = [UIFont fontWithName:SCORE_LABEL_FONT size:14];
		_nameScoreLabel.text = @"score";
		_nameScoreLabel.alpha = 0.65;
		_nameScoreLabel.textAlignment = NSTextAlignmentRight;
		_nameScoreLabel.textColor = [UIColor whiteColor];
		_nameScoreLabel.layer.shadowOpacity = 1;
		_nameScoreLabel.layer.shadowColor = [UIColor whiteColor].CGColor;
		_nameScoreLabel.layer.shadowOffset = CGSizeMake(0, 0);
		_nameScoreLabel.layer.shadowRadius = 2;
		_nameScoreLabel.layer.shouldRasterize = YES;
		_nameScoreLabel.layer.rasterizationScale = [UIScreen mainScreen].scale;
		[self.view addSubview:_nameScoreLabel];
		
		_nameTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(262, 0, 50, 40)];
		_nameTimeLabel.font = _nameScoreLabel.font;
		_nameTimeLabel.text = @"spawns";
		_nameTimeLabel.alpha = _nameScoreLabel.alpha;
		_nameTimeLabel.textAlignment = NSTextAlignmentLeft;
		_nameTimeLabel.textColor = [UIColor whiteColor];
		_nameTimeLabel.layer.shadowOpacity = 1;
		_nameTimeLabel.layer.shadowColor = [UIColor whiteColor].CGColor;
		_nameTimeLabel.layer.shadowOffset = CGSizeMake(0, 0);
		_nameTimeLabel.layer.shadowRadius = 2;
		_nameTimeLabel.layer.shouldRasterize = YES;
		_nameTimeLabel.layer.rasterizationScale = [UIScreen mainScreen].scale;
		[self.view addSubview:_nameTimeLabel];
		
		_statScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, 0, 100, 36)];
		_statScoreLabel.font = [UIFont fontWithName:SCORE_VALUE_FONT size:20];
		_statScoreLabel.text = @"0";
		_statScoreLabel.alpha = 1;
		_statScoreLabel.textAlignment = NSTextAlignmentLeft;
		_statScoreLabel.textColor = [UIColor whiteColor];
		_statScoreLabel.layer.shadowOpacity = 1;
		_statScoreLabel.layer.shadowColor = [UIColor whiteColor].CGColor;
		_statScoreLabel.layer.shadowOffset = CGSizeMake(0, 0);
		_statScoreLabel.layer.shadowRadius = 2;
		_statScoreLabel.layer.shouldRasterize = YES;
		_statScoreLabel.layer.rasterizationScale = [UIScreen mainScreen].scale;
		[self.view addSubview:_statScoreLabel];
		
		_statTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(157, 0, 100, 36)];
		_statTimeLabel.font = [UIFont fontWithName:SCORE_VALUE_FONT size:20];
		_statTimeLabel.text = @"0";
		_statTimeLabel.alpha = 1;
		_statTimeLabel.textAlignment = NSTextAlignmentRight;
		_statTimeLabel.textColor = [UIColor whiteColor];
		_statTimeLabel.layer.shadowOpacity = 1;
		_statTimeLabel.layer.shadowColor = [UIColor whiteColor].CGColor;
		_statTimeLabel.layer.shadowOffset = CGSizeMake(0, 0);
		_statTimeLabel.layer.shadowRadius = 2;
		_statTimeLabel.layer.shouldRasterize = YES;
		_statTimeLabel.layer.rasterizationScale = [UIScreen mainScreen].scale;
		[self.view addSubview:_statTimeLabel];
		
		
		_playButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_playButton.frame = CGRectMake(0, _boardContainer.frame.origin.y + 60, 320, 60);
		_playButton.backgroundColor = [UIColor clearColor];
		_playButton.alpha = 0;
		[_playButton addTarget:self action:@selector(pressedPlay:) forControlEvents:UIControlEventTouchUpInside];
		[_playButton makeBouncy];
		[self.view addSubview:_playButton];
		{
			UILabel *label = [[UILabel alloc] initWithFrame:_playButton.bounds];
			label.text = @"PLAY";
			label.font = [UIFont fontWithName:MENU_FONT size:28];
			label.textAlignment = NSTextAlignmentCenter;
			label.userInteractionEnabled = NO;
			label.textColor = [UIColor whiteColor];
			label.layer.shadowOpacity = 1;
			label.layer.shadowColor = [UIColor whiteColor].CGColor;
			label.layer.shadowOffset = CGSizeMake(0, 0);
			label.layer.shadowRadius = 2;
			label.layer.shouldRasterize = YES;
			label.layer.rasterizationScale = [UIScreen mainScreen].scale;
			[_playButton addSubview:label];
			_playButtonLabel = label;
		}
		
		_scoresButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_scoresButton.frame = CGRectMake(0, _playButton.frame.origin.y + _playButton.frame.size.height, 320, _playButton.frame.size.height);
		_scoresButton.backgroundColor = [UIColor clearColor];
		_scoresButton.alpha = 0;
		[_scoresButton addTarget:self action:@selector(pressedScores:) forControlEvents:UIControlEventTouchUpInside];
		[_scoresButton makeBouncy];
		[self.view addSubview:_scoresButton];
		{
			UILabel *label = [[UILabel alloc] initWithFrame:_scoresButton.bounds];
			label.text = @"HIGH SCORES";
			label.font = [UIFont fontWithName:MENU_FONT size:28];
			label.textAlignment = NSTextAlignmentCenter;
			label.userInteractionEnabled = NO;
			label.textColor = [UIColor whiteColor];
			label.layer.shadowOpacity = 1;
			label.layer.shadowColor = [UIColor whiteColor].CGColor;
			label.layer.shadowOffset = CGSizeMake(0, 0);
			label.layer.shadowRadius = 2;
			label.layer.shouldRasterize = YES;
			label.layer.rasterizationScale = [UIScreen mainScreen].scale;
			[_scoresButton addSubview:label];
		}
		
		_instrButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_instrButton.frame = CGRectMake(0, _scoresButton.frame.origin.y + _scoresButton.frame.size.height, 320, _scoresButton.frame.size.height);
		_instrButton.backgroundColor = [UIColor clearColor];
		_instrButton.alpha = 0;
		[_instrButton addTarget:self action:@selector(pressedInstr:) forControlEvents:UIControlEventTouchUpInside];
		[_instrButton makeBouncy];
		[self.view addSubview:_instrButton];
		{
			UILabel *label = [[UILabel alloc] initWithFrame:_instrButton.bounds];
			label.text = @"INSTRUCTIONS";
			label.font = [UIFont fontWithName:MENU_FONT size:28];
			label.textAlignment = NSTextAlignmentCenter;
			label.userInteractionEnabled = NO;
			label.textColor = [UIColor whiteColor];
			label.layer.shadowOpacity = 1;
			label.layer.shadowColor = [UIColor whiteColor].CGColor;
			label.layer.shadowOffset = CGSizeMake(0, 0);
			label.layer.shadowRadius = 2;
			label.layer.shouldRasterize = YES;
			label.layer.rasterizationScale = [UIScreen mainScreen].scale;
			[_instrButton addSubview:label];
		}
		
		/* Game over */
		_gameOverMsg = [[UILabel alloc] initWithFrame:CGRectMake(10, _boardContainer.frame.origin.y - 30, 300, 30)];
		_gameOverMsg.text = @"GAME OVER :(";
		_gameOverMsg.textColor = [UIColor whiteColor];
		_gameOverMsg.font = [UIFont fontWithName:MENU_FONT size:20];
		_gameOverMsg.textAlignment = NSTextAlignmentCenter;
		_gameOverMsg.userInteractionEnabled = NO;
		_gameOverMsg.layer.shadowOpacity = 1;
		_gameOverMsg.layer.shadowColor = [UIColor whiteColor].CGColor;
		_gameOverMsg.layer.shadowOffset = CGSizeMake(0, 0);
		_gameOverMsg.layer.shadowRadius = 2;
		_gameOverMsg.layer.shouldRasterize = YES;
		_gameOverMsg.layer.rasterizationScale = [UIScreen mainScreen].scale;
		_gameOverMsg.alpha = 0;
		_gameOverMsg.transform = CGAffineTransformMakeScale(0.8, 0.8);
		[self.view addSubview:_gameOverMsg];
		
		/* Health bar */
		_health = 1;
		_healthBar = [[UIView alloc] initWithFrame:CGRectMake(10, _boardContainer.frame.origin.y - 20, 300, 10)];
		_healthBar.layer.borderColor = [UIColor whiteColor].CGColor;
		_healthBar.layer.borderWidth = 1;
		_healthBar.layer.shadowColor = [UIColor whiteColor].CGColor;
		_healthBar.layer.shadowOpacity = 1;
		_healthBar.layer.shadowOffset = CGSizeMake(0, 0);
		_healthBar.layer.shadowRadius = 3;
		_healthBar.backgroundColor = [UIColor redColor];
		_healthBar.alpha = 0;
		[self.view addSubview:_healthBar];
		
		/* Help screen */
		_helpScreen = [UIButton buttonWithType:UIButtonTypeCustom];
		_helpScreen.frame = self.view.bounds;
		_helpScreen.alpha = 0;
		[_helpScreen addTarget:self action:@selector(pressedHelpEscape:) forControlEvents:UIControlEventTouchUpInside];
		[self.view addSubview:_helpScreen];
		
		UIImageView *helpBG = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"help"]];
		helpBG.center = _boardContainer.center;
		[_helpScreen addSubview:helpBG];
		
		[self hideMenu];
	}
	return self;
}

/* We don't want a status bar */
- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (BOOL) gcLogin {
	PersistentDictionary *gc = [PersistentDictionary dictionaryWithName:@"gc"];
	return [gc.dictionary[@"gc"] boolValue];
}

- (void) setGcLogin:(BOOL)gcLogin {
	PersistentDictionary *gc = [PersistentDictionary dictionaryWithName:@"gc"];
	gc.dictionary[@"gc"] = @(gcLogin);
	[gc saveToFile];
}

- (float) currentSpawnDelay {
	float sdelay = SPAWN_INITIAL_DELAY * powf(M_E, _spawnDelayDecay * _spawnBasis);
	float ratio = [_board fillRatio];
	if (ratio > 0.8) ratio = 0.8;
	ratio = ratio * ratio;
	return MAX(sdelay, SPAWN_RATE_MIN) * (1-ratio);
}

- (void) startDemoMode {
	_demoMode = YES;
	_spawnBasis = 100;
	[_board slideInDirection:SLIDE_DIR_N];
}

- (void) demoModeSlide {
	int dir = 1 << (rand()%4);
	[_board slideInDirection:dir];
}

- (void) beginSpawning {
	_shouldSpawn = YES;
	[self spawnElement];
}

- (void) spawnElement {
	/* Update time */
	//double curT = CFAbsoluteTimeGetCurrent();
	//_elapsedTime += (curT - _lastTimeCheck);
	//_lastTimeCheck = curT;
	//[self updateTimeLabel];
	
	if (!_shouldSpawn) return;
		
	//NSLog(@"SPAWN");
	
	BOOL isFull = [_board isFull];
	if (!isFull) {
		int newShapeId = 0;
		float special = floatBetween(0, 1);
		
		/* Penalty for not moving */
		if (_spawnsSinceSlide > SPAWNS_UNTIL_PENALTY) {
			int penaltyCount = _spawnsSinceSlide - SPAWNS_UNTIL_PENALTY;
			if (penaltyCount > SPAWNS_UNTIL_MAX_PENALTY) penaltyCount = SPAWNS_UNTIL_MAX_PENALTY;
			float penaltyRatio = penaltyCount / (float)SPAWNS_UNTIL_MAX_PENALTY;
			special *= (1-penaltyRatio);
		}
		
		if (!_demoMode && special < SPECIAL_RATE) {
			special = floatBetween(0, 1);
			if (special < BLOCKER_RATE) newShapeId = SHAPE_ID_BLOCKER;
			else {
				special -= BLOCKER_RATE;
				if (special < BOMB_RATE) {
					newShapeId = SHAPE_ID_BOMB;
				}
			}
		}
		
		CGPoint newp = [_board randomEmptySpace];
		[_board addShape:newShapeId at:newp delay:0 duration:0.25];
		
		/* Add health */
		_health += SPAWN_HEALTH_REGEN;
		if (_health > 1) _health = 1;
		
		_spawnsSinceSlide++;
	} else if (!_demoMode) {
		/* Board is full and not demo mode; reduce health */
		_health -= SPAWN_HEALTH_DECREMENT;
		if (_health <= 0) {
			_health = 0;
		}
	} else if (_demoMode) {
		/* Board full in demo mode? Wipe the board */
		[_board animateClearBoard:YES];
	}
	
	[self updateHealthBar];
	
	if (_health <= 0 && isFull) {
		[self gameOverOccurred];
		return;
	}
	
	if (!isFull) _spawnBasis++;
	if (!_demoMode) [self updateTimeLabel];
	
	/* Trigger next spawn */
	//NSLog(@"next spawn: %f", [self currentSpawnDelay]);
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)([self currentSpawnDelay] * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
		[self spawnElement];
	});
}

- (void) setBgPause:(BOOL)bgPause {
	_bgPause = bgPause;
	
	if (0) if (!_bgPause && _isPlaying) {
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)([self currentSpawnDelay] * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
			[self spawnElement];
		});
	}
}

- (BOOL) restoreSavedState {
	PersistentDictionary *savedState = [PersistentDictionary dictionaryWithName:@"savedState"];
	
	if (![savedState.dictionary[@"playing"] boolValue]) {
		[self showMenu];
		return NO;
	}
	
	/* Start the game engine */
	[self pressedPlay:nil];
		
	return YES;
}

- (void) saveState {
	PersistentDictionary *savedState = [PersistentDictionary dictionaryWithName:@"savedState"];
	if (!_isPlaying) {
		[self clearState];
		return;
	}
	
	NSMutableArray *boardIds = [NSMutableArray array];
	for (int i = 0; i < BOARD_MAX_SIDE; i++) {
		for (int j = 0; j < BOARD_MAX_SIDE; j++) {
			[boardIds addObject:@([_board shapeIdAtPoint:CGPointMake(i,j)])];
		}
	}
	
	savedState.dictionary[@"board"] = boardIds;
	savedState.dictionary[@"basis"] = @(_spawnBasis);
	savedState.dictionary[@"score"] = @(_score);
	savedState.dictionary[@"playing"] = @(YES);
	[savedState saveToFile];
}

- (void) clearState {
	PersistentDictionary *savedState = [PersistentDictionary dictionaryWithName:@"savedState"];
	[savedState.dictionary removeObjectForKey:@"board"];
	[savedState.dictionary removeObjectForKey:@"basis"];
	[savedState.dictionary removeObjectForKey:@"score"];
	[savedState.dictionary removeObjectForKey:@"playing"];
	[savedState saveToFile];
}

- (void) updateHealthBar {
		
	if (_healthBar.alpha == 0 && _health < 1) {
		[UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
			_healthBar.alpha = 1;
		} completion:nil];
	} else if (_healthBar.alpha == 1 && _health >= 1) {
		[UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
			_healthBar.alpha = 0;
		} completion:nil];
	}
	
	float wd = 300 * _health;
	[UIView animateWithDuration:[self currentSpawnDelay] delay:0 options:0 animations:^{
		_healthBar.frame = CGRectMake(160 - wd/2, _healthBar.frame.origin.y, wd, _healthBar.frame.size.height);
	} completion:nil];
	
	_healthBar.backgroundColor = [UIColor colorWithHue:0 saturation:_health brightness:_health alpha:1];
	_healthBar.layer.borderColor = [UIColor colorWithWhite:_health/2+0.5 alpha:1].CGColor;
	_healthBar.layer.shadowColor = _healthBar.layer.borderColor;
}

- (void) updateScores:(int64_t)lastScore newSpawns:(int64_t)spawnCount {
	
	
	
	
	if (![GKLocalPlayer localPlayer].authenticated && self.gcLogin) {
		[GKLocalPlayer localPlayer].authenticateHandler = ^(UIViewController *viewController, NSError *error) {
			if (viewController) {
				[self presentViewController:viewController animated:YES completion:^{
					[self updateScores:0 newSpawns:0];
					[self showGamecenterInfo];
				}];
			} else {
				if (_cycleCheck) {
					_cycleCheck = NO;
					return;
				}
				_cycleCheck = YES;
				
				[self updateScores:0 newSpawns:0];
			}
		};
	}
	
	
	PersistentDictionary *scores = [PersistentDictionary dictionaryWithName:@"scores"];
	int64_t lastmax = [[scores.dictionary objectForKey:@"max"] longLongValue];
	int64_t spawns  = [[scores.dictionary objectForKey:@"spawns"] longLongValue];
	
	if (lastScore > lastmax) {
		scores.dictionary[@"max"] = [NSNumber numberWithLongLong:lastScore];
		
		if ([GKLocalPlayer localPlayer].authenticated) {
			GKScore *score = [[GKScore alloc] initWithLeaderboardIdentifier:@"MERGESCORE"];
			score.value = lastScore;
			[GKScore reportScores:@[score] withCompletionHandler:^(NSError *error) {}];
		}
	}
	
	spawns += spawnCount;
	scores.dictionary[@"spawns"] = [NSNumber numberWithLongLong:spawns];
	if (spawns > 0 && [GKLocalPlayer localPlayer].authenticated) {
		GKScore *score = [[GKScore alloc] initWithLeaderboardIdentifier:@"TOTALSPAWNS"];
		score.value = spawns;
		[GKScore reportScores:@[score] withCompletionHandler:^(NSError *error) {}];
	}
	
	[scores saveToFile];
}

- (void) gameOverOccurred {
	
	[self updateScores:_score newSpawns:_spawnBasis];
	
	_shouldSpawn = NO;
	
	_isPlaying = NO;
	
	/* Can't swipe anymore */
	_swipeCatcher.userInteractionEnabled = NO;
	
	/* Remove game over message */
	[UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
		_gameOverMsg.alpha = 1;
		_gameOverMsg.transform = CGAffineTransformIdentity;
	} completion:nil];
	
	/* Animate board into alpha state */
	[UIView animateWithDuration:0.75 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
		_board.alpha = 0.1;
	} completion:^(BOOL finished) {
		[self showMenu];
	}];
			
	/* Change play button label */
	_playButtonLabel.text = @"PLAY AGAIN";
	
}

- (void) pressedPlay:(id)sender {
	if (!_isPlaying) {
		/* Start game */
		[self hideMenu];
	}
	
	/* Disable demo */
	_demoMode = NO;
	
	/* Reset spawn basis */
	_spawnBasis = 0;
	_spawnsSinceSlide = 0;
	_health = 1;
	[self updateHealthBar];
	
	/* Reset score */
	_score = 0;
	[self updateScoreLabel];
	
	/* Timing */
	_elapsedTime = 0;
	_lastTimeCheck = CFAbsoluteTimeGetCurrent();
	[self updateTimeLabel];
	
	/* Enable catched */
	_swipeCatcher.userInteractionEnabled = YES;
	
	/* Set that we're playing */
	_isPlaying = YES;
	
	/* Animate board into alpha state */
	[UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
		_board.alpha = 1;
	} completion:nil];
	
	/* Remove game over message */
	[UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
		_gameOverMsg.alpha = 0;
		_gameOverMsg.transform = CGAffineTransformMakeScale(0.8, 0.8);
	} completion:nil];
	
	/* Kill all squares in demo/old game */
	
	
	
	/* RESTORE FROM SAVED STATE */
	{
		PersistentDictionary *savedState = [PersistentDictionary dictionaryWithName:@"savedState"];
		NSLog(@"Save state: %@", savedState.dictionary);
		if ([savedState.dictionary[@"playing"] boolValue]) {
			[_board animateClearBoard:NO];
			
			_score      = [savedState.dictionary[@"score"] intValue];
			_spawnBasis = [savedState.dictionary[@"basis"] intValue];
			[self updateScoreLabel];
			[self updateTimeLabel];
			
			/* Set shapes */
			NSArray *shapeIds = savedState.dictionary[@"board"];
			int idx = 0;
			for (int i = 0; i < BOARD_MAX_SIDE; i++) {
				for (int j = 0; j < BOARD_MAX_SIDE; j++) {
					int shapeId = [shapeIds[idx] intValue];
					if (shapeId == -1) { idx++; continue; }
					[_board addShape:shapeId at:CGPointMake(i, j) delay:0 duration:0.25];
					NSLog(@"Adding %d to %d, %d", shapeId, i, j);
					idx++;
				}
			}
		} else {
			/* This is the animation for normal play button */
			[_board animateClearBoard:YES];
		}
		[self clearState];
	}
	
	
	/* Start spawning */
	if (!_shouldSpawn) {
		_shouldSpawn = YES;
		[self spawnElement];
	}
}

- (void) pressedScores:(id)sender {
	_wantsGCShow = YES;
	
	/* Authorize if needed */
	if (![GKLocalPlayer localPlayer].authenticated) {
		
		if ([[GKLocalPlayer localPlayer] respondsToSelector:@selector(setAuthenticateHandler:)]) {
			[GKLocalPlayer localPlayer].authenticateHandler = ^(UIViewController *viewController, NSError *error) {
				if (viewController) {
					[self presentViewController:viewController animated:YES completion:^{
						[self updateScores:0 newSpawns:0];
						[self showGamecenterInfo];
					}];
				} else {
					self.gcLogin = YES;
					[self updateScores:0 newSpawns:0];
					[self showGamecenterInfo];
				}
			};
		}
		
	} else {
		self.gcLogin = YES;
		[self updateScores:0 newSpawns:0];
		[self showGamecenterInfo];
	}
}

- (void) showGamecenterInfo {
	if (![GKLocalPlayer localPlayer].authenticated) {
		return;
	}
	
	if (!_wantsGCShow) return;
	_wantsGCShow = NO;
	
	GKGameCenterViewController *vc = [[GKGameCenterViewController alloc] init];
	vc.gameCenterDelegate = self;
	vc.viewState = GKGameCenterViewControllerStateLeaderboards;
	[self presentViewController:vc animated:YES completion:nil];
}

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void) pressedInstr:(id)sender {
	[self hideMenu];
	
	[UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
		_board.alpha = 0;
	} completion:nil];
	
	[UIView animateWithDuration:0.5 delay:0.25 options:UIViewAnimationOptionCurveEaseInOut animations:^{
		_helpScreen.alpha = 1;
	} completion:nil];
}

- (void) pressedHelpEscape:(id)sender {
	
	
	[UIView animateWithDuration:0.5 delay:0.25 options:UIViewAnimationOptionCurveEaseInOut animations:^{
		_board.alpha = 0.1;
	} completion:nil];
	
	[UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
		_helpScreen.alpha = 0;
	} completion:nil];
	
	[self showMenu];
}

- (void) updateScoreLabel {
	_statScoreLabel.text = [NSString stringWithFormat:@"%d", _score];
}

- (void) updateTimeLabel {
	//int curSec = (int)_elapsedTime;
	//_statTimeLabel.text = [NSString stringWithFormat:@"%d:%02d", curSec / 60, curSec % 60 ];
	_statTimeLabel.text = [NSString stringWithFormat:@"%d", _spawnBasis];
}

- (void) showMenu {
	if (_menuShown) return;
	_menuShown = YES;
	
	const float dur = 0.75;
	const float del = 0.05;
	
	_playButton.transform   = CGAffineTransformMakeScale(0.8, 0.8);
	_scoresButton.transform = CGAffineTransformMakeScale(0.8, 0.8);
	_instrButton.transform  = CGAffineTransformMakeScale(0.8, 0.8);
	
	_playButton.userInteractionEnabled   = YES;
	_scoresButton.userInteractionEnabled = YES;
	_instrButton.userInteractionEnabled  = YES;
	
	[UIView animateWithDuration:dur delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.7 options:0 animations:^{
		_playButton.alpha = 1;
		_playButton.transform = CGAffineTransformIdentity;
	} completion:nil];
	
	[UIView animateWithDuration:dur delay:del usingSpringWithDamping:0.7 initialSpringVelocity:0.7 options:0 animations:^{
		_scoresButton.alpha = 1;
		_scoresButton.transform = CGAffineTransformIdentity;
	} completion:nil];
	
	[UIView animateWithDuration:dur delay:del*2 usingSpringWithDamping:0.7 initialSpringVelocity:0.7 options:0 animations:^{
		_instrButton.alpha = 1;
		_instrButton.transform = CGAffineTransformIdentity;
	} completion:nil];
}

- (void) hideMenu {
	if (!_menuShown) return;
	_menuShown = NO;
	
	
	const float dur = 0.35;
	const float del = 0.05;
	
	_playButton.userInteractionEnabled   = NO;
	_scoresButton.userInteractionEnabled = NO;
	_instrButton.userInteractionEnabled  = NO;
	
	[UIView animateWithDuration:dur delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.7 options:0 animations:^{
		_playButton.alpha = 0;
		_playButton.transform = CGAffineTransformMakeScale(0.8, 0.8);
	} completion:nil];
	
	[UIView animateWithDuration:dur delay:del usingSpringWithDamping:0.7 initialSpringVelocity:0.7 options:0 animations:^{
		_scoresButton.alpha = 0;
		_scoresButton.transform = CGAffineTransformMakeScale(0.8, 0.8);
	} completion:nil];
	
	[UIView animateWithDuration:dur delay:del*2 usingSpringWithDamping:0.7 initialSpringVelocity:0.7 options:0 animations:^{
		_instrButton.alpha = 0;
		_instrButton.transform = CGAffineTransformMakeScale(0.8, 0.8);
	} completion:nil];
}

- (void) applyEarthquakeToView:(UIView*)v duration:(float)duration delay:(float)delay offset:(int)offset {
	CAKeyframeAnimation *transanimation;
	transanimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
	transanimation.duration = duration;
	transanimation.cumulative = YES;
	int offhalf = offset / 2;
	
	int numFrames = 10;
	NSMutableArray *positions = [NSMutableArray array];
	NSMutableArray *keytimes  = [NSMutableArray array];
	NSMutableArray *timingfun = [NSMutableArray array];
	[positions addObject:[NSValue valueWithCATransform3D:CATransform3DIdentity]];
	[keytimes addObject:@(0)];
	for (int i = 0; i < numFrames; i++) {
		[positions addObject:[NSValue valueWithCATransform3D:CATransform3DMakeTranslation(rand()%offset-offhalf, rand()%offset-offhalf,0)]];
		[keytimes addObject:@( ((float)(i+1))/(numFrames+2) )];
		[timingfun addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	}
	[positions addObject:[NSValue valueWithCATransform3D:CATransform3DIdentity]];
	[keytimes addObject:@(1)];
	[timingfun addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	
	transanimation.values = positions;
	transanimation.keyTimes = keytimes;
	transanimation.calculationMode = kCAAnimationCubic;
	transanimation.timingFunctions = timingfun;
	transanimation.beginTime = CACurrentMediaTime() + delay;
	[v.layer addAnimation:transanimation forKey:nil];
}

#pragma mark BoardViewDelegate methods

- (void) boardDidSlide:(BoardView*)boardView {
	
	/*
	if (![boardView isFull]) {
		for (int i = 0; i < 4; i++) {
			CGPoint newp = [boardView randomEmptySpace];
			if (newp.x >= 0 && newp.y >= 0) [boardView addShape:rand()%2 at:newp delay:0 duration:0.25];
		}
	}
	 */
	
	if (_demoMode) {
		[self demoModeSlide];
		return;
	}
	
	if (_slideQueue) {
		[self swipedInDirection:_slideQueue];
		_slideQueue = 0;
	}
}

#pragma mark SwipeCatcherDelegate methods

- (void) swipedInDirection:(int)dir {
	
	if (!_board.allowSlide) {
		_slideQueue = dir;
	}
	
	NSArray *merges = [_board slideInDirection:dir];
	
	int total_score_update = 0;
	
	int bomb_count = 0;
	for (NSValue *merge in merges) {
		CGPoint p = [merge CGPointValue];
		int shapeid = [_board shapeIdAtPoint:p];
		if (shapeid == SHAPE_ID_BOMB) {
			bomb_count++;
			
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
				[_board animateBombAtPoint:p];
			});
			continue;
		}
		
		int scoreAtPoint = (1 << [_board shapeIdAtPoint:p]);
		int multAtPoint  = [_board mergeMultiplierAtPoint:p];
		total_score_update += scoreAtPoint * multAtPoint;
		//NSLog(@"score update: (+ %d * %d) %d", scoreAtPoint, multAtPoint, total_score_update);
	}
	
	total_score_update *= [merges count];
	//NSLog(@"after merge %d score update: %d", [merges count], total_score_update);
	_score += total_score_update;
	[self updateScoreLabel];
	
	if (bomb_count) {
		[self applyEarthquakeToView:_boardContainer duration:0.35+(bomb_count*0.02) delay:0.2 offset:10+(bomb_count*2)];
		[self applyEarthquakeToView:_healthBar      duration:0.35+(bomb_count*0.02) delay:0.2 offset:7+(bomb_count*1)];
		
		[self applyEarthquakeToView:_statScoreLabel      duration:0.35+(bomb_count*0.05) delay:0.2 offset:2+(bomb_count*1)];
		[self applyEarthquakeToView:_statTimeLabel       duration:0.35+(bomb_count*0.05) delay:0.2 offset:2+(bomb_count*1)];
		[self applyEarthquakeToView:_nameScoreLabel      duration:0.35+(bomb_count*0.05) delay:0.2 offset:2+(bomb_count*1)];
		[self applyEarthquakeToView:_nameTimeLabel       duration:0.35+(bomb_count*0.05) delay:0.2 offset:2+(bomb_count*1)];
	}
	
	_spawnsSinceSlide = 0;
}

@end
