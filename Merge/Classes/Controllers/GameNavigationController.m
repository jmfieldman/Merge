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
		//self.view.backgroundColor = [UIColor colorWithWhite:248/255.0 alpha:1];
		self.view.backgroundColor = [UIColor colorWithRed:0xF0/255.0 green:0xEF/255.0 blue:0xEC/255.0 alpha:1];
		
		_shapeCells = [NSMutableArray array];
		#if 0
		for (int x = 0; x < 6; x++) for (int y = 0; y < 6; y++) {
			ShapeCellView *shapeCell = [[ShapeCellView alloc] initWithFrame:CGRectMake(30+(x*45), 50+(y*45), 30, 30)];
			[shapeCell setShape:rand()%7 duration:0 color:[UIColor redColor]];
			[self.view addSubview:shapeCell];
			[_shapeCells addObject:shapeCell];
		}
		
		for (int x = 0; x < 4; x++) for (int y = 0; y < 4; y++) {
			ShapeCellView *shapeCell = [[ShapeCellView alloc] initWithFrame:CGRectMake(70+(x*60), 50+(y*60), 50, 50)];
			[shapeCell setShape:rand()%7 duration:0 color:[UIColor redColor]];
			if (rand()%2==0)[self.view addSubview:shapeCell];
			[_shapeCells addObject:shapeCell];
		}
		#endif
		
		
		CAShapeLayer *outline = [CAShapeLayer layer];
		outline.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(-150, -150, 300, 300)	cornerRadius:4].CGPath;
		outline.fillColor = nil;
		outline.strokeColor = [UIColor grayColor].CGColor;
		outline.lineWidth = 1;
		outline.opacity = 0.15;
		outline.shadowRadius = 2;
		outline.shadowOpacity = 0.35;
		outline.shadowOffset = CGSizeMake(0, 0);
		outline.shouldRasterize = YES;
		outline.rasterizationScale = [UIScreen mainScreen].scale;
		[self.view.layer addSublayer:outline];
		
		
		_board = [[BoardView alloc] initWithFrame:CGRectMake(20, 70, 280, 280) sideCount:4 cellSize:60];
		[self.view addSubview:_board];
		
		outline.position = _board.center;
		
		/*
		for (int i = 0; i < 4; i++) {
			UISwipeGestureRecognizer *rec = [[UISwipeGestureRecognizer alloc] initWithTarget:_board action:@selector(handleSwipeGesture:)];
			rec.direction = 1 << i;
			[_board addGestureRecognizer:rec];
		}
		 */
		SwipeCatcher *catcher = [[SwipeCatcher alloc] initWithFrame:self.view.bounds];
		catcher.delegate = _board;
		[self.view addSubview:catcher];
		
		
		for (int i = 0; i <= MAX_POLYGON_ID; i++) {
			//[_board addShape:i at:CGPointMake(i&3, i>>2) delay:0 duration:0];
		}
		//[_board addShape:2 at:CGPointMake(1, 1) delay:0 duration:0];
		//[_board addShape:3 at:CGPointMake(1, 2) delay:0 duration:0];
		
		_board.delegate = self;
		
		UIButton *test = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		test.frame = CGRectMake(50, 320, 100, 100);
		[test setTitle:@"test" forState:UIControlStateNormal];
		[test addTarget:self action:@selector(test:) forControlEvents:UIControlEventTouchUpInside];
		//[self.view addSubview:test];
	}
	return self;
}

- (void) test:(id)sender {
	//for (ShapeCellView *cell in _shapeCells) {
	//	[cell setShape:(cell.shapeId+1)%7 duration:0.2 color:[UIColor colorWithHue:((cell.shapeId+1)%7)/7.0 saturation:0.5 brightness:1 alpha:1]];
	//}
	
	//for (int i = 0; i < 100; i++)
	[_board addShape:rand()%4+3 at:CGPointMake(rand()%4, rand()%4) delay:0 duration:0.25];
}

- (void) boardDidSlide:(BoardView*)boardView {
	if (![boardView isFull]) {
		for (int i = 0; i < 1; i++) {
			CGPoint newp = [boardView randomEmptySpace];
			[boardView addShape:rand()%2 at:newp delay:0 duration:0.25];
		}
	}
}

@end
