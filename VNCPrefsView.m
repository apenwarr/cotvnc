//
//  VNCPrefsView.m
//  vnsea
//
//  Created by Glenn Kreisel on 11/3/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "VnseaApp.h"
#import "VNCPrefsView.h"
#import <UIKit/UIPreferencesTextTableCell.h>
#import <UIKit/UIPreferencesControlTableCell.h>
#import <UIKit/UINavigationItem.h>
#import "VNCPreferences.h"

//! @brief Navigation bar button index for the Back button.
#define kServerListButton 1

//! Converts a boolean value to the floating point on or off value for a UISwitchControl.
#define BOOL_TO_SWITCH_VALUE(b) ((b) ? 1.0f : 0.0f)

//! Takes a UISwitchControl and returns a boolean from its value.
//!
//! We use a greater than comparison here because floats are not always exact.
#define SWITCH_VALUE_TO_BOOL(s) ([(s) value] > 0.1)

@implementation VNCPrefsView

- (id)initWithFrame:(CGRect)frame
{
	if ([super initWithFrame:frame])
	{
		CGRect subviewFrame;
		
		// Create nav bar
		subviewFrame = CGRectMake(0.0f, 0.0f, frame.size.width, 48);
		_navBar = [[UINavigationBar alloc] initWithFrame:subviewFrame];
		[_navBar showButtonsWithLeftTitle:NSLocalizedString(@"Back", nil) rightTitle:nil leftBack: YES];
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
		
		// Show mouse tracks cell.
		UIPreferencesControlTableCell * mouseTracksCell = [[UIPreferencesControlTableCell alloc] init];
		[mouseTracksCell setTitle:NSLocalizedString(@"Show Mouse Tracks", nil)];
		
		CGPoint controlOrigin = CGPointMake(200, 9);
		_mouseTracksSwitch = [[UISwitchControl alloc] init];
		[_mouseTracksSwitch setOrigin:controlOrigin];
		[mouseTracksCell setControl:_mouseTracksSwitch];

		// Disconnect on suspend cell.
		UIPreferencesControlTableCell * disconnectCell = [[UIPreferencesControlTableCell alloc] init];
		[disconnectCell setTitle:NSLocalizedString(@"Exit App on Suspend", nil)];
		
//		controlOrigin = CGPointMake(200, 9);
		_disconnectSwitch = [[UISwitchControl alloc] init];
		[_disconnectSwitch setOrigin:controlOrigin];
		[disconnectCell setControl:_disconnectSwitch];

		// Show scroll icon cell.
		UIPreferencesControlTableCell * showScrollIconCell = [[UIPreferencesControlTableCell alloc] init];
		[showScrollIconCell setTitle:NSLocalizedString(@"Show scrolling icon", nil)];
		
//		controlOrigin = CGPointMake(200, 9);
		_showScrollIconSwitch = [[UISwitchControl alloc] init];
		[_showScrollIconSwitch setOrigin:controlOrigin];
		[showScrollIconCell setControl:_showScrollIconSwitch];

		// Show zoom percent cell.
		UIPreferencesControlTableCell * showZoomPercentCell = [[UIPreferencesControlTableCell alloc] init];
		[showZoomPercentCell setTitle:NSLocalizedString(@"Show zoom scale", nil)];
		
//		controlOrigin = CGPointMake(200, 9);
		_showZoomPercentSwitch = [[UISwitchControl alloc] init];
		[_showZoomPercentSwitch setOrigin:controlOrigin];
		[showZoomPercentCell setControl:_showZoomPercentSwitch];
		
		// Create array of cells.
		_cells = [[NSArray arrayWithObjects:mouseTracksCell, disconnectCell, showScrollIconCell, showZoomPercentCell, nil] retain];
	}
	
	return self;
}

- (void)dealloc
{
	[_table release];
	[_navBar release];
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

- (void)updateViewFromPreferences
{
	// Update cell values from the prefs info
	[_mouseTracksSwitch setValue:BOOL_TO_SWITCH_VALUE([[VNCPreferences sharedPreferences] showMouseTracks])];
	[_disconnectSwitch setValue:BOOL_TO_SWITCH_VALUE([[VNCPreferences sharedPreferences] disconnectOnSuspend])];
	[_showScrollIconSwitch setValue:BOOL_TO_SWITCH_VALUE([[VNCPreferences sharedPreferences] showScrollingIcon])];
	[_showZoomPercentSwitch setValue:BOOL_TO_SWITCH_VALUE([[VNCPreferences sharedPreferences] showZoomPercent])];
	
	[_table reloadData];
}

- (void)navigationBar:(id)navBar buttonClicked:(int)buttonIndex
{
	switch (buttonIndex)
	{
		// Save Prefs and go back
		case kServerListButton:
		{
			[[VNCPreferences sharedPreferences] setShowMouseTracks:SWITCH_VALUE_TO_BOOL(_mouseTracksSwitch)];
			[[VNCPreferences sharedPreferences] setDisconnectOnSuspend:SWITCH_VALUE_TO_BOOL(_disconnectSwitch)];
			[[VNCPreferences sharedPreferences] setShowScrollingIcon:SWITCH_VALUE_TO_BOOL(_showScrollIconSwitch)];
			[[VNCPreferences sharedPreferences] setShowZoomPercent:SWITCH_VALUE_TO_BOOL(_showZoomPercentSwitch)];
			break;
		}
	}
	
	if (_delegate && [_delegate respondsToSelector:@selector(finishedEditingPreferences)])
	{
		[_delegate finishedEditingPreferences];
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

@end
