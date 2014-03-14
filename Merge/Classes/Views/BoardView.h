//
//  BoardView.h
//  Merge
//
//  Created by Jason Fieldman on 3/14/14.
//  Copyright (c) 2014 Jason Fieldman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShapeCellView.h"

#define BOARD_MAX_SIDE 8

@interface BoardView : UIView {
	
	ShapeCellView *_cells[BOARD_MAX_SIDE][BOARD_MAX_SIDE];
	
	float _cellSize;
	float _cellPixels;
	float _spacePixels;
	float _spacePixelsHalf;
	float _cellOffset;
	
}

@property (nonatomic, readonly) int sideCount;

/* Assumes board is a square */
- (id) initWithFrame:(CGRect)frame sideCount:(int)side cellSize:(int)cellSize;

/* Animate in a shape */
- (void) addShape:(int)shapeId at:(CGPoint)point delay:(float)delay duration:(float)duration;

@end
