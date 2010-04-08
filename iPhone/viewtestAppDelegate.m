//
//  viewtestAppDelegate.m
//  viewtest
//
//  Created by Avery Pennarun on 2010-03-28.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "viewtestAppDelegate.h"
#import "viewtestViewController.h"

@implementation viewtestAppDelegate

@synthesize window;
@synthesize viewController;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after app launch    
    [window setMultipleTouchEnabled:YES];
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
	
	return YES;
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
