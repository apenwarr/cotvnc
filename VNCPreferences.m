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
NSString * kChordingIntervalPrefKey = @"ChordingInterval";

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
		
		[[NSUserDefaults standardUserDefaults] registerDefaults:defaultsDict];
	}
	
	return self;
}

- (BOOL)showMouseTracks
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:kShowMouseTracksPrefKey];
}

- (BOOL)disconnectOnSuspend
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:kDisconnectOnSuspendPrefKey];
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

