//
//  UIButton+BouncyPress.m
//  Merge
//
//  Created by Jason Fieldman on 3/20/14.
//  Copyright (c) 2014 Jason Fieldman. All rights reserved.
//

#import "UIButton+BouncyPress.h"

@implementation UIButton (BouncyPress)

- (void) makeBouncy {
	[self addTarget:self action:@selector(expand:)   forControlEvents:0xF33];
	[self addTarget:self action:@selector(contract:) forControlEvents:0xC0];
}

- (void) expand:(id)sender {
	if (self.highlighted) {
						
		
		SKBounceAnimation *bounceAnimation = [SKBounceAnimation animationWithKeyPath:@"transform"];
		bounceAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
		bounceAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1)];
		bounceAnimation.duration = 0.35f;
		bounceAnimation.removedOnCompletion = NO;
		bounceAnimation.fillMode = kCAFillModeForwards;
		bounceAnimation.numberOfBounces = 3;
		bounceAnimation.stiffness = SKBounceAnimationStiffnessLight;
		
		[self.layer addAnimation:bounceAnimation forKey:nil];
		
		//[PreloadedSFX playSFX:PLSFX_MENUTAP];
	} else {
		[self contract:nil];
	}
}

- (void) contract:(id)sender {
	
	SKBounceAnimation *bounceAnimation = [SKBounceAnimation animationWithKeyPath:@"transform"];
	bounceAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1)];
	bounceAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
	bounceAnimation.duration = 0.35f;
	bounceAnimation.removedOnCompletion = NO;
	bounceAnimation.fillMode = kCAFillModeForwards;
	bounceAnimation.numberOfBounces = 3;
	bounceAnimation.stiffness = SKBounceAnimationStiffnessLight;
	
	[self.layer addAnimation:bounceAnimation forKey:nil];
	
}
@end
