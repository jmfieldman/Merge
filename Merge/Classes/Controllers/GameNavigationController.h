//
//  GameNavigationController.h
//  Merge
//
//  Created by Jason Fieldman on 3/13/14.
//  Copyright (c) 2014 Jason Fieldman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShapeCellView.h"

@interface GameNavigationController : UIViewController {
	ShapeCellView *_shapeCell;
}

SINGLETON_INTR(GameNavigationController);

@end
