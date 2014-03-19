//
//  ShapeCellView.m
//  Merge
//
//  Created by Jason Fieldman on 3/13/14.
//  Copyright (c) 2014 Jason Fieldman. All rights reserved.
//

#import "ShapeCellView.h"
#import "ColorTheme.h"

static __strong NSMutableDictionary *s_shapeBezierPaths = nil;

#define MULTIPLIER_FONT @"MuseoSansRounded-700"


@implementation ShapeCellView

+ (UIBezierPath*) polygonWithSides:(int)sides radius:(float)radius yshift:(float)yshift {
	UIBezierPath *shape = [UIBezierPath bezierPath];
	float radPerSide = 2*M_PI / sides;
	float startRad = M_PI/2 - radPerSide/2;
	float shift = yshift * radius;
	[shape moveToPoint:CGPointMake(radius*cos(startRad), radius*sin(startRad) + shift)];
	for (int s = 0; s < sides; s++) {
		startRad += radPerSide;
		[shape addLineToPoint:CGPointMake(radius*cos(startRad), radius*sin(startRad) + shift)];
	}
	return shape;
}

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
	
	#if 0
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
	#else
	[paths addObject:[ShapeCellView polygonWithSides:3  radius:halfwidth*1.15 yshift:0.18]];
	[paths addObject:[ShapeCellView polygonWithSides:4  radius:halfwidth*1.15 yshift:0.0]];
	[paths addObject:[ShapeCellView polygonWithSides:5  radius:halfwidth      yshift:0.0]];
	[paths addObject:[ShapeCellView polygonWithSides:6  radius:halfwidth      yshift:0.0]];
	[paths addObject:[ShapeCellView polygonWithSides:7  radius:halfwidth*0.98 yshift:0.0]];
	[paths addObject:[ShapeCellView polygonWithSides:8  radius:halfwidth*0.98 yshift:0.0]];
	[paths addObject:[ShapeCellView polygonWithSides:9  radius:halfwidth*0.98 yshift:0.0]];
	[paths addObject:[ShapeCellView polygonWithSides:10 radius:halfwidth*0.98 yshift:0.0]];
	[paths addObject:[ShapeCellView polygonWithSides:11 radius:halfwidth*0.98 yshift:0.0]];
	[paths addObject:[ShapeCellView polygonWithSides:12 radius:halfwidth*0.98 yshift:0.0]];
	[paths addObject:[ShapeCellView polygonWithSides:13 radius:halfwidth*0.98 yshift:0.0]];
	
	
	#endif
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
		_shapeLayer.fillColor = [[ColorTheme sharedInstance] colorForShapeId:0].CGColor;
		_currentColor = [[ColorTheme sharedInstance] colorForShapeId:0];
		[_shapeContainer.layer addSublayer:_shapeLayer];
		
		_shapeLayer.strokeColor = [UIColor whiteColor].CGColor;
		_shapeLayer.lineWidth = 1;
		
		_shapeLayer.shadowOpacity = 0.6;
		_shapeLayer.shadowOffset = CGSizeMake(0, 0);
		_shapeLayer.shadowRadius = 3;
		_shapeLayer.shadowColor = [UIColor whiteColor].CGColor;
		
		_shapeLayer.shouldRasterize = YES;
		_shapeLayer.rasterizationScale = [UIScreen mainScreen].scale;
		
	}
	return self;
}


- (void)setShape:(int)shapeId duration:(float)duration color:(UIColor*)color {
	
	_shapeId = shapeId;
	
	if (_shapeId > MAX_POLYGON_ID) {
		if (_shapeLayer) {
			{
				/* Shrink the shape layer out */
				CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
				anim.fromValue = @(1);
				anim.toValue = @(1.3);
				anim.duration = duration;
				//anim.beginTime = CACurrentMediaTime() + duration/5;
				anim.removedOnCompletion = NO;
				anim.fillMode = kCAFillModeForwards;
				anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
				anim.autoreverses = YES;
				[_shapeLayer addAnimation:anim forKey:@"scale"];
			}
			{
				/* Opactiy the shape layer out */
				CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"opacity"];
				anim.fromValue = @(1);
				anim.toValue = @(0);
				anim.duration = duration;
				//anim.beginTime = CACurrentMediaTime() + duration/5;
				anim.removedOnCompletion = NO;
				anim.fillMode = kCAFillModeForwards;
				anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
				[_shapeLayer addAnimation:anim forKey:@"opacity"];
			}
			[_shapeLayer performSelector:@selector(removeFromSuperlayer) withObject:nil afterDelay:duration];
		}
		
		if (!_scoreMult) {
			/* Bring in the multiplier! */
			_scoreMult = [[UILabel alloc] initWithFrame:self.bounds];
			_scoreMult.font = [UIFont fontWithName:MULTIPLIER_FONT size:18];
			//_scoreMult.textColor = [UIColor colorWithRed:1/255.0 green:82/255.0 blue:133/255.0 alpha:0.6];
			_scoreMult.textColor = [UIColor colorWithRed:230/255.0 green:245/255.0 blue:255/255.0 alpha:0.9];
			//_scoreMult.textColor = [UIColor colorWithWhite:1 alpha:0.9];
			_scoreMult.text = @"2x";
			_scoreMult.textAlignment = NSTextAlignmentCenter;
			
			_scoreMult.layer.shadowColor = [UIColor whiteColor].CGColor;
			_scoreMult.layer.shadowOffset = CGSizeMake(0, 0);
			_scoreMult.layer.shadowOpacity = 0.8;
			_scoreMult.layer.shadowRadius = 1.5;
			
			_scoreMult.layer.rasterizationScale = [UIScreen mainScreen].scale;
			_scoreMult.layer.shouldRasterize = YES;
			
			[self addSubview:_scoreMult];
		}
		
		_scoreMult.text = [NSString stringWithFormat:@"%dx", (_shapeId - MAX_POLYGON_ID)+1];
		
		return;
	}
	
	
	if (duration > 0) {
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
		[anim setFromValue:(__bridge id)(_currentColor ? _currentColor.CGColor : color.CGColor)];
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
