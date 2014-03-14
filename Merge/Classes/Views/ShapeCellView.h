//
//  ShapeCellView.h
//  Merge
//
//  Created by Jason Fieldman on 3/13/14.
//  Copyright (c) 2014 Jason Fieldman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShapeCellView : UIView {
	UIView       *_shapeContainer;
	CAShapeLayer *_shapeLayer;
	
	/* Shape radius */
	int           _shapeRadius;
	
	/* Color */
	UIColor      *_currentColor;
}

@property (nonatomic, readonly) int shapeId;

- (void)setShape:(int)shapeId duration:(float)duration color:(UIColor*)color;

@end
