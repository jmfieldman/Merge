//
//  GameNavigationController.h
//  Merge
//
//  Created by Jason Fieldman on 3/13/14.
//  Copyright (c) 2014 Jason Fieldman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BoardView.h"

@interface GameNavigationController : UIViewController <BoardViewDelegate, SwipeCatcherDelegate> {
	NSMutableArray *_shapeCells;
	
	UIView    *_boardContainer;
	BoardView *_board;
	
	BOOL       _demoMode;
	
	BOOL       _shouldSpawn;
	int        _spawnBasis;  /* Theoretically this should just equal the number of spawns this game */
	float      _spawnDelayDecay;
}

SINGLETON_INTR(GameNavigationController);

@end
