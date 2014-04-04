//
//  AppDelegate.m
//  Merge
//
//  Created by Jason Fieldman on 3/13/14.
//  Copyright (c) 2014 Jason Fieldman. All rights reserved.
//

#import "AppDelegate.h"
#import "GameNavigationController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	/* Install flurry */
	[Flurry setCrashReportingEnabled:YES];
	[Flurry startSession:FLURRY_KEY];
	
	/* Tool init */
	srand((int)time(0));
	InitializeMathHelper();
	Timing_MarkStartTime();
	
	/* SFX */
	[PreloadedSFX initializePreloadedSFX];
	
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
	self.window.rootViewController = [GameNavigationController sharedInstance];
    [self.window makeKeyAndVisible];
	
	[[GameNavigationController sharedInstance] restoreSavedState];
	
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	[GameNavigationController sharedInstance].bgPause = YES;
	[[GameNavigationController sharedInstance] saveState];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	[GameNavigationController sharedInstance].bgPause = YES;
	[[GameNavigationController sharedInstance] saveState];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	[GameNavigationController sharedInstance].bgPause = NO;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	[GameNavigationController sharedInstance].bgPause = NO;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	[GameNavigationController sharedInstance].bgPause = YES;
	[[GameNavigationController sharedInstance] saveState];
}

@end
