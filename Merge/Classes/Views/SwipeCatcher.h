//
//  SwipeCatcher.h
//  Merge
//
//  Created by Jason Fieldman on 3/16/14.
//  Copyright (c) 2014 Jason Fieldman. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SWIPE_TOLERANCE 10

@protocol SwipeCatcherDelegate <NSObject>
@required
- (void) swipedInDirection:(int)dir;
@end


@interface SwipeCatcher : UIView {
	CGPoint _startPoint;
}

@property (nonatomic, weak) id<SwipeCatcherDelegate> delegate;

@end
