//
//  GameNavigationController.m
//  Merge
//
//  Created by Jason Fieldman on 3/13/14.
//  Copyright (c) 2014 Jason Fieldman. All rights reserved.
//

#import "GameNavigationController.h"

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
		
	}
	return self;
}

/* We don't want a status bar */
- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark BoardViewDelegate methods

- (void) boardDidSlide:(BoardView*)boardView {
	if (![boardView isFull]) {
		for (int i = 0; i < 4; i++) {
			CGPoint newp = [boardView randomEmptySpace];
			if (newp.x >= 0 && newp.y >= 0) [boardView addShape:rand()%2 at:newp delay:0 duration:0.25];
		}
	}
}

#pragma mark SwipeCatcherDelegate methods

- (void) swipedInDirection:(int)dir {
	[_board slideInDirection:dir];
}

@end
