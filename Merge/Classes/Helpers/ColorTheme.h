//
//  ColorTheme.h
//  Merge
//
//  Created by Jason Fieldman on 3/15/14.
//  Copyright (c) 2014 Jason Fieldman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ColorTheme : NSObject {
	NSMutableArray *_shapeThemes;
}


SINGLETON_INTR(ColorTheme);

- (UIColor*) colorForShapeId:(int)shapeId;

@end
