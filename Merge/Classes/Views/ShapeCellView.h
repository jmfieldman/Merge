//
//  ShapeCellView.h
//  Merge
//
//  Created by Jason Fieldman on 3/13/14.
//  Copyright (c) 2014 Jason Fieldman. All rights reserved.
//

#import <UIKit/UIKit.h>

#define MAX_POLYGON_ID 8

@interface ShapeCellView : UIView {
	UIView       *_shapeContainer;
	CAShapeLayer *_shapeLayer;
	
	UILabel      *_scoreMult;
	
	/* Shape radius */
	int           _shapeWidth;
	
	/* Color */
	UIColor      *_currentColor;
}

@property (nonatomic, readonly) int shapeId;

- (void)setShape:(int)shapeId duration:(float)duration color:(UIColor*)color;

@end
