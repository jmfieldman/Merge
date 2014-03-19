//
//  GameNavigationController.m
//  Merge
//
//  Created by Jason Fieldman on 3/13/14.
//  Copyright (c) 2014 Jason Fieldman. All rights reserved.
//

#import "GameNavigationController.h"

#define SPAWN_DELAY_HALF_LIFE 50
#define SPAWN_INITIAL_DELAY   1.0
#define SPAWN_RATE_MIN        0.1

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
		[self.view addSubview:_boardContainer];
		
		_board = [[BoardView alloc] initWithFrame:CGRectMake(12, 12, 280, 280) sideCount:8 cellSize:30];
		_board.delegate = self;
		_board.alpha = 0.1;
		[_boardContainer addSubview:_board];
		
		/* This is the swipe catching view */
		SwipeCatcher *catcher = [[SwipeCatcher alloc] initWithFrame:self.view.bounds];
		catcher.delegate = self;
		[self.view addSubview:catcher];
		
		/* This is a test to pre-populate the board */
		#if 0
		for (int i = 0; i <= MAX_POLYGON_ID; i++) {
			[_board addShape:i at:CGPointMake(i&3, i>>2) delay:0 duration:0];
		}
		#endif
		
		UIButton *test = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[test setTitle:@"test" forState:UIControlStateNormal];
		[test addTarget:self action:@selector(test:) forControlEvents:UIControlEventTouchUpInside];
		test.frame = CGRectMake(0, 400, 80, 80);
		//[self.view addSubview:test];
		
		_spawnBasis  = 10;
		_spawnDelayDecay = (-0.6931471) / SPAWN_DELAY_HALF_LIFE;
		
		[self startDemoMode];
		[self beginSpawning];
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
	_spawnBasis = 0;
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
		CGPoint newp = [_board randomEmptySpace];
		[_board addShape:0 at:newp delay:0 duration:0.25];
	}
	
	if (_demoMode) _spawnBasis++;
	
	/* Trigger next spawn */
	NSLog(@"next spawn: %f", [self currentSpawnDelay]);
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)([self currentSpawnDelay] * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
		[self spawnElement];
	});
}

- (void) test:(id)sender {
	static int foo = 0;
	
	[UIView animateWithDuration:0.45
						  delay:0
		 usingSpringWithDamping:0.7
		  initialSpringVelocity:0.7
						options:0
					 animations:^{
						 if (foo) {
							 _boardContainer.transform = CGAffineTransformIdentity;
						 } else {
							 _boardContainer.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(70, -65), 0.4, 0.4);
						 }
						 foo = !foo;
					 } completion:^(BOOL finished) {
						 
					 }];
	
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
	[_board slideInDirection:dir];
}

@end
