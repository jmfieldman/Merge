//
//  BoardView.h
//  Merge
//
//  Created by Jason Fieldman on 3/14/14.
//  Copyright (c) 2014 Jason Fieldman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShapeCellView.h"
#import "SwipeCatcher.h"

#define BOARD_MAX_SIDE 8

typedef enum SlideDirection {
	SLIDE_DIR_E = 1,
	SLIDE_DIR_W = 2,
	SLIDE_DIR_N = 4,
	SLIDE_DIR_S = 8,
} SlideDirection_t;

@class BoardView;
@protocol BoardViewDelegate <NSObject>
@required
- (void) boardDidSlide:(BoardView*)boardView;
@end

@interface BoardView : UIView <UIGestureRecognizerDelegate, SwipeCatcherDelegate> {
	
	ShapeCellView *_cells[BOARD_MAX_SIDE][BOARD_MAX_SIDE];
	BOOL _mergeCache[BOARD_MAX_SIDE][BOARD_MAX_SIDE];
	
	float _cellSize;
	float _cellPixels;
	float _spacePixels;
	float _spacePixelsHalf;
	float _cellOffset;
	
}

@property (nonatomic, readonly) int sideCount;
@property (nonatomic, weak) id<BoardViewDelegate> delegate;
@property (nonatomic, readonly) BOOL allowSlide;

/* Assumes board is a square */
- (id) initWithFrame:(CGRect)frame sideCount:(int)side cellSize:(int)cellSize;

/* Animate in a shape */
- (void) addShape:(int)shapeId at:(CGPoint)point delay:(float)delay duration:(float)duration;

/* Sliding - returns array of NSValue w/ cgpoints */
- (NSArray*) slideInDirection:(int)direction;

/* Get random empty */
- (BOOL) isFull;
- (CGPoint) randomEmptySpace;

/* State checking */
- (BOOL) canMove;

/* Gestures */
- (void)handleSwipeGesture:(UIGestureRecognizer *)gestureRecognizer;

/* Animate clear board */
- (void) animateClearBoard:(BOOL)animated;

/* Animate bomb effect */
- (void) animateBombAtPoint:(CGPoint)p;

/* What's at a coord? */
- (int) shapeIdAtPoint:(CGPoint)p;

/* Merge multipliers? */
- (int) mergeMultiplierAtPoint:(CGPoint)p;

/* Fill ratio? */
- (float) fillRatio;

@end
