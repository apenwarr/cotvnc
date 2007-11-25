//
//  VNCPreferences.m
//  vnsea
//
//  Created by Chris Reed on 11/17/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "VNCPreferences.h"

NSString * kShowMouseTracksPrefKey = @"MouseTracks";
NSString * kDisconnectOnSuspendPrefKey = @"Disconnect";
NSString * kMouseDownDelayPrefKey = @"MouseDownDelay";
NSString * kMouseTracksFadeTimePrefKey = @"MouseTracksFadeTime";

//! Singleton object.
static id s_sharedPreferences = nil;

@implementation VNCPreferences

+ (VNCPreferences *)sharedPreferences
{
	if (!s_sharedPreferences)
	{
		s_sharedPreferences = [[VNCPreferences alloc] init];
	}
	
	return s_sharedPreferences;
}

- (id)init
{
	if ([super init])
	{
		// Set default preference values.
		NSMutableDictionary * defaultsDict = [NSMutableDictionary dictionary];
		[defaultsDict setObject:[NSNumber numberWithBool:YES] forKey:kShowMouseTracksPrefKey];
		[defaultsDict setObject:[NSNumber numberWithBool:NO] forKey:kDisconnectOnSuspendPrefKey];
		[defaultsDict setObject:[NSNumber numberWithFloat:0.285] forKey:kMouseDownDelayPrefKey];
		[defaultsDict setObject:[NSNumber numberWithFloat:1.5] forKey:kMouseTracksFadeTimePrefKey];
		
		[[NSUserDefaults standardUserDefaults] registerDefaults:defaultsDict];
	}
	
	return self;
}

//! Whether the mouse tracks should be shown on mouse down and mouse up events.
//!
- (BOOL)showMouseTracks
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:kShowMouseTracksPrefKey];
}

- (BOOL)disconnectOnSuspend
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:kDisconnectOnSuspendPrefKey];
}

//! Number of seconds to wait before sending a mouse down, during which we
//! check to see if the user is really wanting to scroll.
- (float)mouseDownDelay
{
	return [[NSUserDefaults standardUserDefaults] floatForKey:kMouseDownDelayPrefKey];
}

- (float)mouseTracksFadeTime
{
	return [[NSUserDefaults standardUserDefaults] floatForKey:kShowMouseTracksPrefKey];
}

- (void)setShowMouseTracks:(BOOL)showTracks
{
	[[NSUserDefaults standardUserDefaults] setBool:showTracks forKey:kShowMouseTracksPrefKey];
}

- (void)setDisconnectOnSuspend:(BOOL)disconnect
{
	[[NSUserDefaults standardUserDefaults] setBool:disconnect forKey:kDisconnectOnSuspendPrefKey];
}

@end

