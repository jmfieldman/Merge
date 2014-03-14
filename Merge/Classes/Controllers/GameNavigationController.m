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
		self.view.backgroundColor = [UIColor whiteColor];
		
		_shapeCell = [[ShapeCellView alloc] initWithFrame:CGRectMake(50, 50, 100, 100)];
		[_shapeCell setShape:2 duration:0 color:[UIColor redColor]];
		[self.view addSubview:_shapeCell];
	
		UIButton *test = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		test.frame = CGRectMake(50, 320, 100, 100);
		[test setTitle:@"test" forState:UIControlStateNormal];
		[test addTarget:self action:@selector(test:) forControlEvents:UIControlEventTouchUpInside];
		[self.view addSubview:test];
	}
	return self;
}

- (void) test:(id)sender {
	[_shapeCell setShape:(_shapeCell.shapeId+1)%3 duration:0.2 color:[UIColor colorWithHue:(rand()%255)/255.0 saturation:1 brightness:1 alpha:1]];
}

@end
