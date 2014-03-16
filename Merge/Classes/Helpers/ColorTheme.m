//
//  ColorTheme.m
//  Merge
//
//  Created by Jason Fieldman on 3/15/14.
//  Copyright (c) 2014 Jason Fieldman. All rights reserved.
//

#import "ColorTheme.h"

@implementation ColorTheme

SINGLETON_IMPL(ColorTheme);

- (id) init {
	if ((self = [super init])) {
	
		_shapeThemes = [NSMutableArray array];
		
		{
			NSMutableArray *theme = [NSMutableArray array];
			#if 0
			for (int i = 0; i < 11; i++) {
				[theme addObject:[UIColor colorWithHue:(i*11)/7.0 - (int)((i*11)/7.0) saturation:0.45 brightness:1 alpha:1]];
			}
			#elif 0
			for (int i = 0; i < 11; i++) {
				[theme addObject:[UIColor colorWithHue:(i / 26.0) saturation:(0.2 + i/20.0) brightness:1 alpha:1]];
			}
			#else
			float sat = 0.39;
			[theme addObject:[UIColor colorWithHue:0.00 saturation:sat brightness:1 alpha:1]];
			[theme addObject:[UIColor colorWithHue:0.18 saturation:sat brightness:1 alpha:1]];
			[theme addObject:[UIColor colorWithHue:0.41 saturation:sat brightness:1 alpha:1]];
			[theme addObject:[UIColor colorWithHue:0.55 saturation:sat brightness:1 alpha:1]];
			[theme addObject:[UIColor colorWithHue:0.33 saturation:sat brightness:1 alpha:1]];
			[theme addObject:[UIColor colorWithHue:0.62 saturation:sat brightness:1 alpha:1]];
			[theme addObject:[UIColor colorWithHue:0.90 saturation:sat brightness:1 alpha:1]];
			[theme addObject:[UIColor colorWithHue:0.70 saturation:sat brightness:1 alpha:1]];
			[theme addObject:[UIColor colorWithHue:0.10 saturation:sat brightness:1 alpha:1]];
			#endif
			[_shapeThemes addObject:theme];
		}
		
	}
	return self;
}

- (UIColor*) colorForShapeId:(int)shapeId {
	return (UIColor*)([_shapeThemes[0] objectAtIndex:shapeId]);
}


@end
