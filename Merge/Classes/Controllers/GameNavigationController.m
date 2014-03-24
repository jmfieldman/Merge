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
#define SPAWN_RATE_MIN        0.2

#define SPECIAL_RATE 0.15 /* 0.15 */
#define BLOCKER_RATE 0.4
#define BOMB_RATE    0.6

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
		
		_nameTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(275, 0, 50, 40)];
		_nameTimeLabel.font = _nameScoreLabel.font;
		_nameTimeLabel.text = @"time";
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
		
		_statTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(170, 0, 100, 36)];
		_statTimeLabel.font = [UIFont fontWithName:SCORE_VALUE_FONT size:20];
		_statTimeLabel.text = @"0:00";
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
		_playButton.frame = CGRectMake(0, _boardContainer.frame.origin.y + 40, 320, 60);
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
		
		[self hideMenu];
	}
	return self;
}

/* We don't want a status bar */
- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (float) currentSpawnDelay {
	float sdelay = SPAWN_INITIAL_DELAY * powf(M_E, _spawnDelayDecay * _spawnBasis);
	return MAX(sdelay, SPAWN_RATE_MIN);
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
	if (!_shouldSpawn) return;
	
	if (![_board isFull]) {
		int newShapeId = 0;
		float special = floatBetween(0, 1);
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
	}
	
	_spawnBasis++;
	
	/* Trigger next spawn */
	//NSLog(@"next spawn: %f", [self currentSpawnDelay]);
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)([self currentSpawnDelay] * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
		[self spawnElement];
	});
}

- (void) restoreSavedState {
	[self showMenu];
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
	
	/* Kill all squares in demo/old game */
	[_board animateClearBoard];
}

- (void) pressedScores:(id)sender {
	
}

- (void) pressedInstr:(id)sender {
	
}

- (void) updateScoreLabel {
	_statScoreLabel.text = [NSString stringWithFormat:@"%d", _score];
}

- (void) updateTimeLabel {
	int curSec = (int)_elapsedTime;
	_statTimeLabel.text = [NSString stringWithFormat:@"%d:%02d", curSec / 60, curSec % 60 ];
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
}

#pragma mark SwipeCatcherDelegate methods

- (void) swipedInDirection:(int)dir {
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
		NSLog(@"score update: (+ %d * %d) %d", scoreAtPoint, multAtPoint, total_score_update);
	}
	
	total_score_update *= [merges count];
	NSLog(@"after merge %d score update: %d", [merges count], total_score_update);
	_score += total_score_update;
	[self updateScoreLabel];
	
	if (bomb_count) [self applyEarthquakeToView:_boardContainer duration:0.3+(bomb_count*0.1) delay:0.2 offset:10+(bomb_count*2)];
}

@end
