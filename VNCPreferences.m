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
NSString * kShowScrollingIconPrefKey = @"ShowScrollingIcon";
NSString * kShowZoomPercentPrefKey = @"ShowZoomPercent";

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
		[defaultsDict setObject:[NSNumber numberWithBool:NO] forKey:kShowScrollingIconPrefKey];
		[defaultsDict setObject:[NSNumber numberWithBool:YES] forKey:kShowZoomPercentPrefKey];
		
		[[NSUserDefaults standardUserDefaults] registerDefaults:defaultsDict];
	}
	
	return self;
}

#pragma mark *Getters*

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

//! This preference controls whether any icon is displayed between the fingers
//! while scrolling in active mode. No icon is ever displayed in view-only mode.
- (BOOL)showScrollingIcon
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:kShowScrollingIconPrefKey];
}

//! This preference controls whether the popup window that shows the current zoom
//! scale percentage is displayed while the user is zooming.
- (BOOL)showZoomPercent
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:kShowZoomPercentPrefKey];
}

#pragma mark *Setters*

- (void)setShowMouseTracks:(BOOL)showTracks
{
	[[NSUserDefaults standardUserDefaults] setBool:showTracks forKey:kShowMouseTracksPrefKey];
}

- (void)setDisconnectOnSuspend:(BOOL)disconnect
{
	[[NSUserDefaults standardUserDefaults] setBool:disconnect forKey:kDisconnectOnSuspendPrefKey];
}

- (void)setMouseDownDelay:(float)delay
{
	[[NSUserDefaults standardUserDefaults] setFloat:delay forKey:kMouseDownDelayPrefKey];
}

- (void)setMouseTracksFadeTime:(float)fadeTime
{
	[[NSUserDefaults standardUserDefaults] setFloat:fadeTime forKey:kShowMouseTracksPrefKey];
}

- (BOOL)setShowScrollingIcon:(BOOL)showIcon
{
	[[NSUserDefaults standardUserDefaults] setBool:showIcon forKey:kShowScrollingIconPrefKey];
}

- (BOOL)setShowZoomPercent:(BOOL)showPercent
{
	[[NSUserDefaults standardUserDefaults] setBool:showPercent forKey:kShowZoomPercentPrefKey];
}

@end

