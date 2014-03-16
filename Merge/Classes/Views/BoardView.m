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
	
	ShapeCellView *newCell = [[ShapeCellView alloc] initWithFrame:CGRectMake(0, 0, _cellSize, _cellSize)];
	newCell.center = CGPointMake(_cellOffset/2 + _cellOffset*x, _cellOffset/2 + _cellOffset*y);
	[newCell setShape:shapeId duration:duration color:[[ColorTheme sharedInstance] colorForShapeId:shapeId]];

	/* pop up */
	newCell.transform = CGAffineTransformMakeScale(0.3, 0.3);
	newCell.alpha = 0;
	[UIView animateWithDuration:duration
						  delay:0
		 usingSpringWithDamping:0.5
		  initialSpringVelocity:0.5
						options:0
					 animations:^{
						 newCell.alpha = 1;
						 newCell.transform = CGAffineTransformIdentity;
					 } completion:^(BOOL finished) {
						 
					 }];
	
	_cells[x][y] = newCell;
	[self addSubview:newCell];
	
}


- (void) slideInDirection:(int)direction {
	
	memset(_mergeCache, 0, sizeof(_mergeCache));
	
	for (int x = ((direction == SLIDE_DIR_E) ? (_sideCount-1) : 0 );
		 ((direction == SLIDE_DIR_E) ? (x >= 0) : (x < _sideCount));
		 ((direction == SLIDE_DIR_E) ? (x--) : (x++)) ) {
		
		for (int y = ((direction == SLIDE_DIR_S) ? (_sideCount-1) : 0 );
			 ((direction == SLIDE_DIR_S) ? (y >= 0) : (y < _sideCount));
			 ((direction == SLIDE_DIR_S) ? (y--) : (y++)) ) {
			
			if (!_cells[x][y]) continue;
			
			CGPoint end;
			BOOL merges;
			[self calculateSlideInDirection:direction forCoord:CGPointMake(x, y) endsAt:&end merges:&merges];
		
			/* Did a slide happen? */
			int fx = (int)end.x;
			int fy = (int)end.y;
			
			NSLog(@"end: %d, %d; %f %f", fx, fy, end.x, end.y);
			
			/* No slide */
			if (fx == x && fy == y) continue;
			
			float duration = 0.5+floatBetween(0, 0.2);
			float idamping = 0.7;
			float velocity = 0.7;
			
			/* Simple slide */
			[UIView animateWithDuration:duration
								  delay:0
				 usingSpringWithDamping:idamping
				  initialSpringVelocity:velocity
								options:0
							 animations:^{
								 _cells[x][y].center = CGPointMake(_cellOffset/2 + _cellOffset*fx, _cellOffset/2 + _cellOffset*fy);
							 } completion:^(BOOL finished) {
								 
							 }];
			
			if (!merges) {
				
				
				_cells[fx][fy] = _cells[x][y];
				_cells[x][y] = nil;
			} else {
				/* Have to deal with merging */
				_mergeCache[fx][fy] = YES;
				
				/* Need to alpha it out near the merge point */
				{
					CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"opacity"];
					anim.fromValue = @(1);
					anim.toValue = @(0);
					anim.duration = duration/2;
					anim.beginTime = CACurrentMediaTime() + duration/5;
					anim.removedOnCompletion = NO;
					anim.fillMode = kCAFillModeForwards;
					anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
					[_cells[x][y].layer addAnimation:anim forKey:@"opacity"];
				}
				
				/* Change shape of merged-into */
				int newShape = _cells[fx][fy].shapeId+1;
				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration/3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
					[_cells[fx][fy] setShape:newShape duration:0.25 color:[[ColorTheme sharedInstance] colorForShapeId:newShape]];
					
					CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
					anim.fromValue = @(1);
					anim.toValue = @(1.3);
					anim.duration = 0.2;
					//anim.beginTime = CACurrentMediaTime() + duration/5;
					anim.removedOnCompletion = NO;
					anim.fillMode = kCAFillModeForwards;
					anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
					anim.autoreverses = YES;
					[_cells[fx][fy].layer addAnimation:anim forKey:@"scale"];
					
				});
				
				/* Merged cells get removed */
				[_cells[x][y] performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:duration];
				
				[_cells[x][y].superview sendSubviewToBack:_cells[x][y]];
				_cells[x][y] = nil;
			}
			
		}
		
	}

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
		[_delegate boardDidSlide:self];
	});
}

- (void) calculateSlideInDirection:(int)direction forCoord:(CGPoint)start endsAt:(CGPoint*)end merges:(BOOL*)merges {
	int x = (int)start.x;
	int y = (int)start.y;
	
	int dx = 1, dy = 0;
	if (direction == SLIDE_DIR_N) { dx = 0; dy = -1; }
	if (direction == SLIDE_DIR_W) { dx = -1; }
	if (direction == SLIDE_DIR_S) { dx = 0; dy = 1; }
	
	NSLog(@"%d (%d, %d) [%d %d]", direction, x, y, dx, dy);
	
	*merges = NO;
	end->x = x;
	end->y = y;
	
	int cshape = _cells[x][y].shapeId;
	
	do {
		switch (direction) {
			case SLIDE_DIR_E:
				if (x == (_sideCount-1)) return;
				if (_cells[x+1][y]) {
					if (_mergeCache[x+1][y] || cshape != _cells[x+1][y].shapeId) return;
					end->x++;
					*merges = YES;
					return;
				}
				break;
				
			case SLIDE_DIR_W:
				if (x == 0) return;
				if (_cells[x-1][y]) {
					if (_mergeCache[x-1][y] || cshape != _cells[x-1][y].shapeId) return;
					end->x--;
					*merges = YES;
					return;
				}
				break;
				
			case SLIDE_DIR_N:
				if (y == 0) return;
				if (_cells[x][y-1]) {
					if (_mergeCache[x][y-1] || cshape != _cells[x][y-1].shapeId) return;
					end->y--;
					*merges = YES;
					return;
				}
				break;
				
			case SLIDE_DIR_S:
				if (y == (_sideCount-1)) return;
				if (_cells[x][y+1]) {
					if (_mergeCache[x][y+1] || cshape != _cells[x][y+1].shapeId) return;
					end->y++;
					*merges = YES;
					return;
				}
				break;
				
			default:
				break;
		}
		
		x += dx;
		y += dy;
		
		end->x = x;
		end->y = y;
		
	} while (1);
	
	return;
}

- (BOOL) canMove {
	for (int i = 0; i < _sideCount; i++) {
		for (int j = 0; j < _sideCount; j++) {
			if (!_cells[i][j]) return YES;
			int cshape = _cells[i][j].shapeId;
			if (i > 0) if (_cells[i-1][j].shapeId == cshape) return YES;
			if (j > 0) if (_cells[i][j-1].shapeId == cshape) return YES;
			if (i < (_sideCount-1)) if (_cells[i+1][j].shapeId == cshape) return YES;
			if (j < (_sideCount-1)) if (_cells[i][j+1].shapeId == cshape) return YES;
		}
	}
	return NO;
}

- (void)handleSwipeGesture:(UIGestureRecognizer *)gestureRecognizer {
	if ([gestureRecognizer isKindOfClass:[UISwipeGestureRecognizer class]]) {
		UISwipeGestureRecognizer *swipe = (UISwipeGestureRecognizer*)gestureRecognizer;
		if (swipe.direction == UISwipeGestureRecognizerDirectionRight)
			[self slideInDirection:SLIDE_DIR_E];
		if (swipe.direction == UISwipeGestureRecognizerDirectionLeft)
			[self slideInDirection:SLIDE_DIR_W];
		if (swipe.direction == UISwipeGestureRecognizerDirectionUp)
			[self slideInDirection:SLIDE_DIR_N];
		if (swipe.direction == UISwipeGestureRecognizerDirectionDown)
			[self slideInDirection:SLIDE_DIR_S];
	}
}

- (BOOL) isFull {
	for (int y = 0; y < _sideCount; y++) {
		for (int x = 0; x < _sideCount; x++) {
			if (!_cells[x][y]) return NO;
		}
	}
	return YES;
}

- (CGPoint) randomEmptySpace {
	NSMutableArray *arr = [NSMutableArray array];
	for (int y = 0; y < _sideCount; y++) {
		for (int x = 0; x < _sideCount; x++) {
			if (!_cells[x][y]) [arr addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
		}
	}
	if (![arr count]) {
		return CGPointMake(-1,-1);
	}
	return [((NSValue*) arr[rand()%[arr count]]) CGPointValue];
}


- (void) logBoardShapes {
	NSMutableString *output = [NSMutableString string];
	for (int y = 0; y < _sideCount; y++) {
		for (int x = 0; x < _sideCount; x++) {
			if (_cells[x][y]) {
				[output appendFormat:@"%d ", _cells[x][y].shapeId];
			} else {
				[output appendString:@"- "];
			}
		}
		[output appendString:@"\n"];
	}
	NSLog(@"\n%@", output);
}

@end
