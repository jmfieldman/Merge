//
//  GameNavigationController.m
//  Merge
//
//  Created by Jason Fieldman on 3/13/14.
//  Copyright (c) 2014 Jason Fieldman. All rights reserved.
//

#import "GameNavigationController.h"

@interface GameNavigationController ()

@end

@implementation GameNavigationController

SINGLETON_IMPL(GameNavigationController);

- (id)init {
	if ((self = [super init])) {

		self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
		self.view.backgroundColor = [UIColor colorWithWhite:248/255.0 alpha:1];
		
		_shapeCells = [NSMutableArray array];
		#if 0
		for (int x = 0; x < 6; x++) for (int y = 0; y < 6; y++) {
			ShapeCellView *shapeCell = [[ShapeCellView alloc] initWithFrame:CGRectMake(30+(x*45), 50+(y*45), 30, 30)];
			[shapeCell setShape:rand()%7 duration:0 color:[UIColor redColor]];
			[self.view addSubview:shapeCell];
			[_shapeCells addObject:shapeCell];
		}
		#endif
		for (int x = 0; x < 4; x++) for (int y = 0; y < 4; y++) {
			ShapeCellView *shapeCell = [[ShapeCellView alloc] initWithFrame:CGRectMake(70+(x*60), 50+(y*60), 50, 50)];
			[shapeCell setShape:rand()%7 duration:0 color:[UIColor redColor]];
			if (rand()%2==0)[self.view addSubview:shapeCell];
			[_shapeCells addObject:shapeCell];
		}
	
		UIButton *test = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		test.frame = CGRectMake(50, 320, 100, 100);
		[test setTitle:@"test" forState:UIControlStateNormal];
		[test addTarget:self action:@selector(test:) forControlEvents:UIControlEventTouchUpInside];
		[self.view addSubview:test];
	}
	return self;
}

- (void) test:(id)sender {
	for (ShapeCellView *cell in _shapeCells) {
		[cell setShape:(cell.shapeId+1)%7 duration:0.2 color:[UIColor colorWithHue:((cell.shapeId+1)%7)/7.0 saturation:0.5 brightness:1 alpha:1]];
	}
}

@end
