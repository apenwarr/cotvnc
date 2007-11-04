//
//  VNCPrefsView.m
//  vnsea
//
//  Created by Glenn Kreisel on 11/3/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "VNseaApp.h"
#import "VNCPrefsView.h"
#import <UIKit/UIPreferencesTextTableCell.h>
#import <UIKit/UIPreferencesControlTableCell.h>
#import <UIKit/UINavigationItem.h>

#define kServerListButton 1
#define kAboutButton 0

@implementation VNCPrefsView

- (id)initWithFrame:(CGRect)frame
{
	if ([super initWithFrame:frame])
	{
		CGRect subviewFrame;
		
		// Create nav bar
		subviewFrame = CGRectMake(0.0f, 0.0f, frame.size.width, 48);
		_navBar = [[UINavigationBar alloc] initWithFrame:subviewFrame];
		[_navBar showButtonsWithLeftTitle:NSLocalizedString(@"Back", nil) rightTitle:NSLocalizedString(@"About", nil) leftBack: YES];
		[_navBar setBarStyle: 3];
		[_navBar setDelegate: self];
		[self addSubview: _navBar];
		
		UINavigationItem * item = [[UINavigationItem alloc] initWithTitle:NSLocalizedString(@"Preferences", nil)];
		[_navBar pushNavigationItem:item];
		
		// Create preferences table
		subviewFrame = CGRectMake(0, 48, frame.size.width, frame.size.height - 48);
		_table = [[UIPreferencesTable alloc] initWithFrame:subviewFrame];
		[_table setDataSource:self];
		[_table setDelegate:self];
		[self addSubview:_table];
		
		UIPreferencesControlTableCell * mouseTracksCell = [[UIPreferencesControlTableCell alloc] init];
		[mouseTracksCell setTitle:NSLocalizedString(@"Show Mouse Tracks", nil)];
		
		CGPoint controlOrigin = CGPointMake(200, 9);
		_mouseTracksSwitch = [[UISwitchControl alloc] init];
		[_mouseTracksSwitch setOrigin:controlOrigin];
		[mouseTracksCell setControl:_mouseTracksSwitch];

		
		_cells = [[NSArray arrayWithObjects:mouseTracksCell, nil] retain];
		
	}
	
	return self;
}

- (void)dealloc
{
	[_table release];
	[_navBar release];
	[_prefsInfo release];
	[_cells release];
	
	[super dealloc];
}

- (void)setDelegate:(id)newDelegate
{
	_delegate = newDelegate;
}

- (id)delegate
{
	return _delegate;
}

- (void)setKeyboardVisible:(BOOL)visible
{
	[_table setKeyboardVisible:visible animated:NO];
}

- (void)setPrefsInfo:(NSDictionary *)info
{
	if (info == nil)
		{
		_prefsInfo =  [NSMutableDictionary dictionary];
		// Setup Defaults Here
		[_prefsInfo setObject:[NSNumber numberWithBool:YES] forKey:MOUSE_TRACKS];
		}
	else
		{
		[_prefsInfo release];
		_prefsInfo = [[info mutableCopy] retain];
		}
	
	// Update cell values from the prefs info
	[_mouseTracksSwitch setValue:[[_prefsInfo objectForKey:MOUSE_TRACKS] boolValue] ? 1.0f : 0.0f];
	
	if (info == nil)
		_prefsInfo = nil;
	[_table reloadData];
}

- (void)displayAbout
{
	UIAlertSheet * hotSheet = [[UIAlertSheet alloc]
		initWithTitle:NSLocalizedString(@"AboutVersion", nil)
		buttons:[NSArray arrayWithObject:NSLocalizedString(@"OK", nil)]
		defaultButtonIndex:0
		delegate:self
		context:self];

	[hotSheet setBodyText:NSLocalizedString(@"AboutMessage", nil)];
	[hotSheet setDimsBackground:YES];
	[hotSheet setRunsModal:YES];
	[hotSheet setShowsOverSpringBoardAlerts:NO];
	[hotSheet popupAlertAnimated:YES];	
}

- (void)alertSheet:(id)sheet buttonClicked:(int)buttonIndex
{
		// Just close and release any other sheets.
		[sheet dismissAnimated:YES];
		[sheet release];
}

- (BOOL)showMouseTracks
{
		return [[_prefsInfo objectForKey:MOUSE_TRACKS] boolValue];
}

- (void)navigationBar:(id)navBar buttonClicked:(int)buttonIndex
{
	NSDictionary * resultDict;
	
	NSLog(@"Button Index %d", buttonIndex);
	switch (buttonIndex)
	{
		// Save Prefs and go back
		case kServerListButton:
			{
			if (_prefsInfo == nil)
				_prefsInfo = [NSMutableDictionary dictionary];

			[_prefsInfo setObject:[NSNumber numberWithBool:([_mouseTracksSwitch value] > 0.1)] forKey:MOUSE_TRACKS];
			
			resultDict = _prefsInfo;			
			break;
			}
		
		// Display About
		case kAboutButton:
			[self displayAbout];
			return;
			break;
	}
	
	if (_delegate && [_delegate respondsToSelector:@selector(finishedPrefs:)])
		{
		[_delegate finishedPrefs:resultDict];
		}
}

- (int)numberOfGroupsInPreferencesTable:(id)fp8
{
	return 1;
}

- (id)preferencesTable:(id)prefsTable cellForRow:(int)rowIndex inGroup:(int)groupIndex
{
	if (groupIndex == 0)
	{
		return [_cells objectAtIndex:rowIndex];
	}
}

- (int)preferencesTable:(id)prefsTable numberOfRowsInGroup:(int)groupIndex
{
	if (groupIndex == 0)
	{
		return [_cells count];
	}
	else
	{
		return 1;
	}
}

- (BOOL)table:(id)prefsTable showDisclosureForRow:(int)rowIndex
{
	return NO;
}

/*
- (BOOL)respondsToSelector:(SEL)aSelector
{
	NSLog(@"Request for selector: %@", NSStringFromSelector(aSelector));
	return [super respondsToSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
	NSLog(@"Called from UITextView %@", NSStringFromSelector([anInvocation selector]));
	[super forwardInvocation:anInvocation];
}
*/
@end
