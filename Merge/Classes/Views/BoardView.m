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
		
		_allowSlide = YES;
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

- (void) animateClearBoard {
	for (int i = 0; i < BOARD_MAX_SIDE; i++) {
		for (int j = 0; j < BOARD_MAX_SIDE; j++) {
			UIView *cell = _cells[i][j];
			_cells[i][j] = nil;
			float delay = floatBetween(0, 0.3);
			[UIView animateWithDuration:0.35
								  delay:delay
								options:UIViewAnimationOptionCurveEaseInOut
							 animations:^{
								 cell.alpha = 0;
								 float scale = floatBetween(1.2, 1.4);
								 cell.transform = CGAffineTransformMakeScale(scale, scale);
							 } completion:^(BOOL finished) {
								 [cell removeFromSuperview];
							 }];
		}
	}
}


- (NSArray*) slideInDirection:(int)direction {
	
	if (!_allowSlide) return nil;
	
	memset(_mergeCache, 0, sizeof(_mergeCache));
	
	NSMutableArray *mergeReturn = [NSMutableArray array];
	
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
			
			//NSLog(@"end: %d, %d; %f %f", fx, fy, end.x, end.y);
			
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
				[mergeReturn addObject:[NSValue valueWithCGPoint:CGPointMake(fx, fy)]];
				
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
				CGPoint middle = _cells[fx][fy].center;
				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration/3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
					if (newShape != (SHAPE_ID_BOMB+1)) {
						[_cells[fx][fy] setShape:newShape duration:0.25 color:[[ColorTheme sharedInstance] colorForShapeId:newShape]];
					}
					
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
					
					/* Animate score */
					if (0) {
						UILabel *score = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _cellSize * 2, _cellSize * 2)];
						score.text = [NSString stringWithFormat:@"+%d", 1 << (newShape-1)];
						score.textColor = [UIColor whiteColor];
						score.textAlignment = NSTextAlignmentCenter;
						score.font = [UIFont fontWithName:@"MuseoSansRounded-700" size:10];
						score.backgroundColor = [UIColor clearColor];
						score.center = middle;
						score.layer.shadowColor = [UIColor blackColor].CGColor;
						score.layer.shadowOpacity = 1;
						score.layer.shadowOffset = CGSizeMake(0, 0);
						score.layer.shadowRadius = 3;
						score.layer.shouldRasterize = YES;
						score.layer.rasterizationScale = [UIScreen mainScreen].scale;
						[self addSubview:score];
						
						[UIView animateWithDuration:0.75 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
							score.alpha = 0;
							score.transform = CGAffineTransformMakeScale(3, 3);
						} completion:^(BOOL finished) {
							[score removeFromSuperview];
						}];
						
					}
				});
				
				
				
				/* Merged cells get removed */
				[_cells[x][y] performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:duration];
				
				[_cells[x][y].superview sendSubviewToBack:_cells[x][y]];
				_cells[x][y] = nil;
			}
			
		}
		
	}

	_allowSlide = NO;
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
		_allowSlide = YES;
		[_delegate boardDidSlide:self];
	});
	
	return mergeReturn;
}

- (void) calculateSlideInDirection:(int)direction forCoord:(CGPoint)start endsAt:(CGPoint*)end merges:(BOOL*)merges {
	int x = (int)start.x;
	int y = (int)start.y;
	
	int dx = 1, dy = 0;
	if (direction == SLIDE_DIR_N) { dx = 0; dy = -1; }
	if (direction == SLIDE_DIR_W) { dx = -1; }
	if (direction == SLIDE_DIR_S) { dx = 0; dy = 1; }
	
	//NSLog(@"%d (%d, %d) [%d %d]", direction, x, y, dx, dy);
	
	*merges = NO;
	end->x = x;
	end->y = y;
	
	int cshape = _cells[x][y].shapeId;
	
	/* Blockers */
	if (cshape == SHAPE_ID_BLOCKER) {
		cshape = -1111;
	}
	
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

- (void) swipedInDirection:(int)dir {
	[self slideInDirection:dir];
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

- (void) animateBombAtPoint:(CGPoint)p {
	int x = p.x;
	int y = p.y;
	
	//if (!_cells[x][y]) return;
	
	{
		/* Insert smoke emitter */
		CAEmitterCell *ecell = [CAEmitterCell emitterCell];
		ecell.contents = (id)[UIImage imageNamed:@"smoke"].CGImage;
		ecell.birthRate = 5;
		ecell.name = @"smoke";
		[ecell setVelocity:30];
		[ecell setVelocityRange:5];
		[ecell setYAcceleration:0];
		[ecell setEmissionLongitude:0];
		[ecell setEmissionRange:2*M_PI];
		[ecell setScale:0.35f];
		[ecell setScaleSpeed:0.2f];
		[ecell setScaleRange:0.1f];
		//[ecell setColor:[UIColor colorWithRed:1.0
		//								green:0.5
		//								 blue:0.1
		//								alpha:0.5].CGColor];
		ecell.color = [UIColor whiteColor].CGColor;
		//ecell.greenRange = 0.35;
		//ecell.blueRange = 0.35;
		ecell.alphaSpeed = -1;
		ecell.spin = 0;
		ecell.spinRange = 3;
		
		[ecell setLifetime:1.5f];
		[ecell setLifetimeRange:0.1f];
		
		
		CAEmitterLayer *elayer = [CAEmitterLayer layer];
		elayer.emitterCells = @[ecell];
		//elayer.emitterPosition = _cells[x][y].layer.position;//CGPointMake(self.bounds.size.width*0.5f,self.bounds.size.height*0.3f);
		elayer.emitterPosition = CGPointMake(_cellOffset/2 + _cellOffset*x, _cellOffset/2 + _cellOffset*y);
		elayer.emitterSize = CGSizeMake(10, 10);
		elayer.emitterShape = kCAEmitterLayerRectangle;
		elayer.renderMode = kCAEmitterLayerBackToFront;
		elayer.seed = rand();
		[elayer setEmitterCells:@[ecell]];
		[self.layer addSublayer:elayer];
		
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
			elayer.birthRate = 0;
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
				[elayer removeFromSuperlayer];
			});
		});
	}
	
	/* Clear spaces */
	for (int i = (x-1); i <= (x+1); i++) {
		for (int j = (y-1); j <= (y+1); j++) {
			if (i < 0 || j < 0 || i >= BOARD_MAX_SIDE || j >= BOARD_MAX_SIDE) continue;
			if (!_cells[i][j]) continue;
			
			ShapeCellView *cell = _cells[i][j];
			_cells[i][j] = nil;
			[UIView animateWithDuration:0.35
								  delay:0
								options:UIViewAnimationOptionCurveEaseOut
							 animations:^{
								 cell.alpha = 0;
								 //float scale = floatBetween(1.2, 1.4);
								 //cell.transform = CGAffineTransformMakeScale(scale, scale);
								 
								 CGPoint center = cell.center;
								 center.x += (i-x)*(fastRand()%10+10);
								 center.y += (j-y)*(fastRand()%10+10);
								 cell.center = center;
								 
							 } completion:^(BOOL finished) {
								 [cell removeFromSuperview];
							 }];
		}
	}
	
}

- (int) shapeIdAtPoint:(CGPoint)p {
	ShapeCellView *cell = _cells[(int)p.x][(int)p.y];
	if (!cell) return -1;
	return cell.shapeId;
}

- (int) mergeMultiplierAtPoint:(CGPoint)p {
	int x = p.x;
	int y = p.y;
	int mult = 1;
	if (x > 0) { if (_cells[x-1][y].shapeId > MAX_POLYGON_ID && _cells[x-1][y].shapeId < MAX_BONUS_ID) { mult *= (_cells[x-1][y].shapeId - MAX_POLYGON_ID)+1; } }
	if (y > 0) { if (_cells[x][y-1].shapeId > MAX_POLYGON_ID && _cells[x][y-1].shapeId < MAX_BONUS_ID) { mult *= (_cells[x][y-1].shapeId - MAX_POLYGON_ID)+1; } }
	if (x < (BOARD_MAX_SIDE-1)) { if (_cells[x+1][y].shapeId > MAX_POLYGON_ID && _cells[x+1][y].shapeId < MAX_BONUS_ID) { mult *= (_cells[x+1][y].shapeId - MAX_POLYGON_ID)+1; } }
	if (y < (BOARD_MAX_SIDE-1)) { if (_cells[x][y+1].shapeId > MAX_POLYGON_ID && _cells[x][y+1].shapeId < MAX_BONUS_ID) { mult *= (_cells[x][y+1].shapeId - MAX_POLYGON_ID)+1; } }
	return mult;
}

- (float) fillRatio {
	int count = 0;
	for (int i = 0; i < _sideCount; i++) {
		for (int j = 0; j < _sideCount; j++) {
			if (_cells[i][j]) count++;
		}
	}
	return (count / (float)(_sideCount * _sideCount));
}

@end
