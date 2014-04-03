//
//  GameNavigationController.h
//  Merge
//
//  Created by Jason Fieldman on 3/13/14.
//  Copyright (c) 2014 Jason Fieldman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BoardView.h"

@interface GameNavigationController : UIViewController <BoardViewDelegate, SwipeCatcherDelegate, GKGameCenterControllerDelegate> {
	NSMutableArray *_shapeCells;
	
	UIView    *_boardContainer;
	BoardView *_board;
	
	BOOL       _demoMode;
	BOOL       _isPlaying;
	BOOL       _isPaused;
	int        _slideQueue;
	
	BOOL       _shouldSpawn;
	int        _spawnBasis;  /* Theoretically this should just equal the number of spawns this game */
	float      _spawnDelayDecay;
	
	int        _spawnsWhileSliding;
	
	int        _spawnsSinceSlide;
	
	int        _score;
	
	BOOL       _wantsGCShow;
	
	double     _elapsedTime;
	double     _lastTimeCheck;
	
	SwipeCatcher *_swipeCatcher;
	
	/* Stat labels */
	UILabel   *_statScoreLabel;
	UILabel   *_statTimeLabel;
	UILabel   *_nameScoreLabel;
	UILabel   *_nameTimeLabel;
	
	/* Menu items */
	UIButton  *_playButton;
	UILabel   *_playButtonLabel;
	UIButton  *_scoresButton;
	UIButton  *_instrButton;
	BOOL       _menuShown;
	
	/* Game over */
	UILabel   *_gameOverMsg;
	
	/* Health */
	float      _health;
	UIView    *_healthBar;
	
	/* Help screen */
	UIButton  *_helpScreen;
}

SINGLETON_INTR(GameNavigationController);

@property (nonatomic, assign) BOOL bgPause;
@property (nonatomic, assign) BOOL gcLogin;

- (BOOL) restoreSavedState;
- (void) saveState;

@end
