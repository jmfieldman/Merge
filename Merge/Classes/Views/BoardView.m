//
//  BoardView.m
//  Merge
//
//  Created by Jason Fieldman on 3/14/14.
//  Copyright (c) 2014 Jason Fieldman. All rights reserved.
//

#import "BoardView.h"
#import "ColorTheme.h"

@implementation BoardView

- (id) initWithFrame:(CGRect)frame sideCount:(int)side cellSize:(int)cellSize {
	if ((self = [super initWithFrame:frame])) {
		
		self.backgroundColor = [UIColor clearColor];
		
		_sideCount = side;
		_cellSize = cellSize;
		
		_cellPixels = cellSize * side;
		_spacePixels = frame.size.width - _cellPixels;
		_spacePixelsHalf = _spacePixels / 2;
		_cellOffset = frame.size.width / side;
		
		for (int x = 0; x < side; x++) {
			for (int y = 0; y < side; y++) {
				_cells[x][y] = nil;
			}
		}
	}
	return self;
}


- (void) addShape:(int)shapeId at:(CGPoint)point delay:(float)delay duration:(float)duration {
	
	int x = (int)point.x;
	int y = (int)point.y;
	
	/* Check cell already exists */
	if (_cells[x][y]) return;
	
	ShapeCellView *newCell = [[ShapeCellView alloc] initWithFrame:CGRectMake(x * _cellOffset + _spacePixelsHalf, y * _cellOffset + _spacePixelsHalf, _cellSize, _cellSize)];
	[newCell setShape:shapeId duration:duration color:[[ColorTheme sharedInstance] colorForShapeId:shapeId]];

	_cells[x][y] = newCell;
	[self addSubview:newCell];
	
}

@end
