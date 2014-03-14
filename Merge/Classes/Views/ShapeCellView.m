//
//  ShapeCellView.m
//  Merge
//
//  Created by Jason Fieldman on 3/13/14.
//  Copyright (c) 2014 Jason Fieldman. All rights reserved.
//

#import "ShapeCellView.h"


static __strong NSMutableDictionary *s_shapeBezierPaths = nil;



@implementation ShapeCellView

+ (void) createBezierPaths:(int)radius {
	/* Create main dic if needed */
	if (!s_shapeBezierPaths) {
		s_shapeBezierPaths = [NSMutableDictionary dictionary];
	}

	int halfrad = radius / 2;
	
	NSMutableArray *paths = [NSMutableArray array];
	s_shapeBezierPaths[@(radius)] = paths;
	
	UIBezierPath *circle = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(-halfrad, -halfrad, radius, radius)];
	[paths addObject:circle];
	
	UIBezierPath *triangle = [UIBezierPath bezierPath];
	[triangle moveToPoint:CGPointMake(0, -halfrad)];
	[triangle addLineToPoint:CGPointMake(halfrad, halfrad)];
	[triangle addLineToPoint:CGPointMake(-halfrad, halfrad)];
	[triangle addLineToPoint:CGPointMake(0, -halfrad)];
	[paths addObject:triangle];
	
	UIBezierPath *square = [UIBezierPath bezierPath];
	[square moveToPoint:CGPointMake(-halfrad, -halfrad)];
	[square addLineToPoint:CGPointMake(halfrad, -halfrad)];
	[square addLineToPoint:CGPointMake(halfrad, halfrad)];
	[square addLineToPoint:CGPointMake(-halfrad, halfrad)];
	[square addLineToPoint:CGPointMake(-halfrad, -halfrad)];
	[paths addObject:square];
	
}

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {

		/* Create paths if uninitialized */
		_shapeRadius = (int)frame.size.width;
		if (!s_shapeBezierPaths || !s_shapeBezierPaths[@(_shapeRadius)]) {
			[ShapeCellView createBezierPaths:_shapeRadius];
		}
		
		/* Each cell is transparent */
		self.backgroundColor = [UIColor clearColor];
		
		/* Create a container for the shape layer - allow us more transform flexibility */
		_shapeContainer = [[UIView alloc] initWithFrame:self.bounds];
		_shapeContainer.backgroundColor = [UIColor clearColor];
		[self addSubview:_shapeContainer];
		
		/* Create the shape layer in the center of the container */
		_shapeLayer = [CAShapeLayer layer];
		_shapeLayer.position = _shapeContainer.center;
		_shapeLayer.path = ((UIBezierPath*)[s_shapeBezierPaths[@(_shapeRadius)] objectAtIndex:0]).CGPath;
		_shapeLayer.fillColor = [UIColor clearColor].CGColor;
		_currentColor = [UIColor clearColor];
		[_shapeContainer.layer addSublayer:_shapeLayer];
		
	}
	return self;
}


- (void)setShape:(int)shapeId duration:(float)duration color:(UIColor*)color {
	
	_shapeId = shapeId;
	
	{
		CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"path"];
		[anim setFromValue:(__bridge id)_shapeLayer.path];
		[anim setToValue:(__bridge id)((UIBezierPath*)[s_shapeBezierPaths[@(_shapeRadius)] objectAtIndex:shapeId]).CGPath];
		[anim setDuration:duration];
		anim.removedOnCompletion = NO;
		anim.fillMode = kCAFillModeForwards;
		anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
		[_shapeLayer addAnimation:anim forKey:@"path"];
	}
	
	{
		CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"fillColor"];
		[anim setFromValue:(__bridge id)_currentColor.CGColor];
		[anim setToValue:(__bridge id)color.CGColor];
		[anim setDuration:duration];
		anim.removedOnCompletion = NO;
		anim.fillMode = kCAFillModeForwards;
		anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
		[_shapeLayer addAnimation:anim forKey:@"fillColor"];
	}
	
	_shapeLayer.path = ((UIBezierPath*)[s_shapeBezierPaths[@(_shapeRadius)] objectAtIndex:shapeId]).CGPath;
	_currentColor = color;
}


@end
