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

+ (void) createBezierPaths:(int)width {
	/* Create main dic if needed */
	if (!s_shapeBezierPaths) {
		s_shapeBezierPaths = [NSMutableDictionary dictionary];
	}

	int halfwidth = width / 2;
	
	NSMutableArray *paths = [NSMutableArray array];
	s_shapeBezierPaths[@(width)] = paths;
	
	float cir_sz = width * 0.86;
	UIBezierPath *circle = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(-cir_sz/2, -cir_sz/2, cir_sz, cir_sz)];
	[paths addObject:circle];
	
	UIBezierPath *triangle = [UIBezierPath bezierPath];
	[triangle moveToPoint:CGPointMake(0, -halfwidth)];
	[triangle addLineToPoint:CGPointMake(halfwidth, halfwidth*0.86)];
	[triangle addLineToPoint:CGPointMake(-halfwidth, halfwidth*0.86)];
	[triangle addLineToPoint:CGPointMake(0, -halfwidth)];
	[paths addObject:triangle];
	
	float sq_radius = halfwidth * 0.86;
	UIBezierPath *square = [UIBezierPath bezierPath];
	[square moveToPoint:CGPointMake(sq_radius, -sq_radius)];
	[square addLineToPoint:CGPointMake(sq_radius, sq_radius)];
	[square addLineToPoint:CGPointMake(-sq_radius, sq_radius)];
	[square addLineToPoint:CGPointMake(-sq_radius, -sq_radius)];
	[square addLineToPoint:CGPointMake(sq_radius, -sq_radius)];
	[paths addObject:square];
	
	float pent_c1 = 0.309017 * halfwidth;
	float pent_c2 = 0.809017 * halfwidth;
	float pent_s1 = 0.951057 * halfwidth;
	float pent_s2 = 0.587785 * halfwidth;
	UIBezierPath *pentagon = [UIBezierPath bezierPath];
	[pentagon moveToPoint:CGPointMake(pent_s1, -pent_c1)];
	[pentagon addLineToPoint:CGPointMake(pent_s2, pent_c2)];
	[pentagon addLineToPoint:CGPointMake(-pent_s2, pent_c2)];
	[pentagon addLineToPoint:CGPointMake(-pent_s1, -pent_c1)];
	[pentagon addLineToPoint:CGPointMake(0, -halfwidth)];
	[pentagon addLineToPoint:CGPointMake(pent_s1, -pent_c1)];
	[paths addObject:pentagon];
	
	float hex_x = 0.5 * halfwidth;
	float hex_y = 0.86 * halfwidth;
	UIBezierPath *hexagon = [UIBezierPath bezierPath];
	[hexagon moveToPoint:CGPointMake(halfwidth, 0)];
	[hexagon addLineToPoint:CGPointMake(hex_x, hex_y)];
	[hexagon addLineToPoint:CGPointMake(-hex_x, hex_y)];
	[hexagon addLineToPoint:CGPointMake(-halfwidth, 0)];
	[hexagon addLineToPoint:CGPointMake(-hex_x, -hex_y)];
	[hexagon addLineToPoint:CGPointMake(hex_x, -hex_y)];
	[hexagon addLineToPoint:CGPointMake(halfwidth, 0)];
	[paths addObject:hexagon];
	
	float hept_rad = halfwidth;
	UIBezierPath *heptagon = [UIBezierPath bezierPath];
	[heptagon moveToPoint:CGPointMake(hept_rad *  0.9749, hept_rad * 0.2225)];
	[heptagon addLineToPoint:CGPointMake(hept_rad *  0.4339, hept_rad * 0.901)];
	[heptagon addLineToPoint:CGPointMake(hept_rad * -0.4339, hept_rad * 0.901)];
	[heptagon addLineToPoint:CGPointMake(hept_rad * -0.9749, hept_rad * 0.2225)];
	[heptagon addLineToPoint:CGPointMake(hept_rad * -0.7818, hept_rad * -0.6235)];
	[heptagon addLineToPoint:CGPointMake(hept_rad * 0.00000, hept_rad * -1.0000)];
	[heptagon addLineToPoint:CGPointMake(hept_rad *  0.7818, hept_rad * -0.6235)];
	[heptagon addLineToPoint:CGPointMake(hept_rad *  0.9749, hept_rad * 0.2225)];
	[paths addObject:heptagon];
	
	float oct_rad  = halfwidth * 0.98;
	float oct_diff = 0.38 * oct_rad;
	UIBezierPath *octogon = [UIBezierPath bezierPath];
	[octogon moveToPoint:CGPointMake(oct_rad, oct_diff)];
	[octogon addLineToPoint:CGPointMake(oct_diff, oct_rad)];
	[octogon addLineToPoint:CGPointMake(-oct_diff, oct_rad)];
	[octogon addLineToPoint:CGPointMake(-oct_rad, oct_diff)];
	[octogon addLineToPoint:CGPointMake(-oct_rad, -oct_diff)];
	[octogon addLineToPoint:CGPointMake(-oct_diff, -oct_rad)];
	[octogon addLineToPoint:CGPointMake(oct_diff, -oct_rad)];
	[octogon addLineToPoint:CGPointMake(oct_rad, -oct_diff)];
	[octogon addLineToPoint:CGPointMake(oct_rad, oct_diff)];
	
	[paths addObject:octogon];
}

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {

		/* Create paths if uninitialized */
		_shapeWidth = (int)frame.size.width;
		if (!s_shapeBezierPaths || !s_shapeBezierPaths[@(_shapeWidth)]) {
			[ShapeCellView createBezierPaths:_shapeWidth];
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
		_shapeLayer.path = ((UIBezierPath*)[s_shapeBezierPaths[@(_shapeWidth)] objectAtIndex:0]).CGPath;
		_shapeLayer.fillColor = [UIColor clearColor].CGColor;
		_currentColor = [UIColor clearColor];
		[_shapeContainer.layer addSublayer:_shapeLayer];
		
		_shapeLayer.strokeColor = [UIColor grayColor].CGColor;
		_shapeLayer.lineWidth = 1;
		
		_shapeLayer.shadowOpacity = 0.3;
		_shapeLayer.shadowOffset = CGSizeMake(0, 0);
		_shapeLayer.shadowRadius = 3;
		
		_shapeLayer.shouldRasterize = YES;
		_shapeLayer.rasterizationScale = [UIScreen mainScreen].scale;
		
	}
	return self;
}


- (void)setShape:(int)shapeId duration:(float)duration color:(UIColor*)color {
	
	_shapeId = shapeId;
	
	{
		CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"path"];
		[anim setFromValue:(__bridge id)_shapeLayer.path];
		[anim setToValue:(__bridge id)((UIBezierPath*)[s_shapeBezierPaths[@(_shapeWidth)] objectAtIndex:shapeId]).CGPath];
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
	
	_shapeLayer.path = ((UIBezierPath*)[s_shapeBezierPaths[@(_shapeWidth)] objectAtIndex:shapeId]).CGPath;
	_currentColor = color;
}


@end
