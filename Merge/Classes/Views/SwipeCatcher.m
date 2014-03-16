//
//  SwipeCatcher.m
//  Merge
//
//  Created by Jason Fieldman on 3/16/14.
//  Copyright (c) 2014 Jason Fieldman. All rights reserved.
//

#import "SwipeCatcher.h"


#define DIR_E 1
#define DIR_W 2
#define DIR_N 4
#define DIR_S 8

@implementation SwipeCatcher

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		
	}
	return self;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	NSArray *t = [touches allObjects];
	if (![t count]) return;
	UITouch *touch = [t objectAtIndex:0];
	_startPoint = [touch locationInView:self];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	NSArray *t = [touches allObjects];
	if (![t count]) return;
	UITouch *touch = [t objectAtIndex:0];
	CGPoint p = [touch locationInView:self];
	
	float dx = p.x - _startPoint.x;
	float dy = p.y - _startPoint.y;
	
	float fdx = fabs(dx);
	float fdy = fabs(dy);
	
	if (fdx < SWIPE_TOLERANCE && fdy < SWIPE_TOLERANCE) return;
	
	if (fdx > fdy) {
		if (dx < 0) [_delegate swipedInDirection:DIR_W];
		else [_delegate swipedInDirection:DIR_E];
	} else {
		if (dy < 0) [_delegate swipedInDirection:DIR_N];
		else [_delegate swipedInDirection:DIR_S];
	}
}

@end
