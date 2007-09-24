//
//  VNCServerInfoView.m
//  vnsea
//
//  Created by Chris Reed on 9/6/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "VNCServerInfoView.h"
#import <UIKit/UIPreferencesTextTableCell.h>
#import <UIKit/UIPreferencesControlTableCell.h>
#import <UIKit/UINavigationItem.h>
#import "ServerFromPrefs.h"

@implementation VNCServerInfoView

- (id)initWithFrame:(CGRect)frame
{
	if ([super initWithFrame:frame])
	{
		CGRect subviewFrame;
		
		// Create nav bar
		subviewFrame = CGRectMake(0.0f, 0.0f, frame.size.width, 48);
		_navBar = [[UINavigationBar alloc] initWithFrame:subviewFrame];
		[_navBar showButtonsWithLeftTitle:NSLocalizedString(@"Cancel", nil) rightTitle:NSLocalizedString(@"Save", nil) leftBack: YES];
		[_navBar setBarStyle: 3];
		[_navBar setDelegate: self];
		[self addSubview: _navBar];
		
		UINavigationItem * item = [[UINavigationItem alloc] initWithTitle:NSLocalizedString(@"Edit Server", nil)];
		[_navBar pushNavigationItem:item];
		
		// Create preferences table
		subviewFrame = CGRectMake(0, 48, frame.size.width, frame.size.height - 48);
		_table = [[UIPreferencesTable alloc] initWithFrame:subviewFrame];
		[_table setDataSource:self];
		[_table setDelegate:self];
		[self addSubview:_table];
		
		// Create edit field cells.
		UIPreferencesTextTableCell * nameCell = [[UIPreferencesTextTableCell alloc] init];
		[nameCell setTitle:NSLocalizedString(@"Name", nil)];
		
		UIPreferencesTextTableCell * addressCell = [[UIPreferencesTextTableCell alloc] init];
		[addressCell setTitle:NSLocalizedString(@"Address", nil)];
		
		UIPreferencesTextTableCell * passwordCell = [[UIPreferencesTextTableCell alloc] init];
		[passwordCell setTitle:NSLocalizedString(@"Password", nil)];
		[passwordCell setPlaceHolderValue:NSLocalizedString(@"enter password", nil)];
		
		UIPreferencesTextTableCell * displayCell = [[UIPreferencesTextTableCell alloc] init];
		[displayCell setTitle:NSLocalizedString(@"Display", nil)];
		
		UIPreferencesControlTableCell * sharedCell = [[UIPreferencesControlTableCell alloc] init];
		[sharedCell setTitle:NSLocalizedString(@"Shared", nil)];
		
		CGPoint controlOrigin = CGPointMake(200, 9);
		_sharedSwitch = [[UISwitchControl alloc] init];
		[_sharedSwitch setOrigin:controlOrigin];
		[sharedCell setControl:_sharedSwitch];
		
		UIPreferencesControlTableCell * viewOnlyCell = [[UIPreferencesControlTableCell alloc] init];
		[viewOnlyCell setTitle:NSLocalizedString(@"View Only", nil)];

		_viewOnlySwitch = [[UISwitchControl alloc] init];
		[_viewOnlySwitch setOrigin:controlOrigin];
		[viewOnlyCell setControl:_viewOnlySwitch];
		
		subviewFrame = [_table frameOfPreferencesCellAtRow:6 inGroup:0];
		UIPreferencesTableCell * pixelDepthCell = [[UIPreferencesTableCell alloc] initWithFrame:subviewFrame];
		[pixelDepthCell setTitle:NSLocalizedString(@"Pixel Depth", nil)];

		subviewFrame.origin = CGPointMake(154, 9);
		subviewFrame.size.height = [UISegmentedControl defaultHeightForStyle:2];
		subviewFrame.size.width = 140;
		NSArray * segmentItems = [NSArray arrayWithObjects:@"8", @"16", @"32", nil];
		_pixelDepthControl = [[UISegmentedControl alloc] initWithFrame:subviewFrame withStyle:2 withItems:segmentItems];
		[pixelDepthCell addSubview:_pixelDepthControl];
		
		_cells = [[NSArray arrayWithObjects:nameCell, addressCell, passwordCell, displayCell, sharedCell, viewOnlyCell, pixelDepthCell, nil] retain];
		
		// Create Delete Server button
		subviewFrame = [_table frameOfPreferencesCellAtRow:0 inGroup:1];
		_deleteCell = [[UIPreferencesDeleteTableCell alloc] initWithFrame:subviewFrame];
		[[_deleteCell button] setTitle:NSLocalizedString(@"Delete Server", nil)];
		[[_deleteCell button] addTarget:self action:@selector(deleteButtonPressed:) forEvents:kGSEventTypeButtonSelected];
	}
	
	return self;
}

- (void)dealloc
{
	[_table release];
	[_navBar release];
	[_serverInfo release];
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

- (void)setServerInfo:(NSDictionary *)info
{
	[_serverInfo release];
	_serverInfo = [[info mutableCopy] retain];
	
	UIPreferencesTextTableCell * cell;
	
	// Update cell values from the server info
	[(UIPreferencesTextTableCell *)[_cells objectAtIndex:kServerNameCellIndex] setValue:[_serverInfo objectForKey:RFB_NAME]];
	[(UIPreferencesTextTableCell *)[_cells objectAtIndex:kServerAddressCellIndex] setValue:[_serverInfo objectForKey:RFB_HOSTANDPORT]];
	[(UIPreferencesTextTableCell *)[_cells objectAtIndex:kServerPasswordCellIndex] setValue:[_serverInfo objectForKey:RFB_PASSWORD]];
	[(UIPreferencesTextTableCell *)[_cells objectAtIndex:kServerDisplayCellIndex] setValue:[NSString stringWithFormat:@"%d", [[_serverInfo objectForKey:RFB_DISPLAY] intValue]]];
	[_sharedSwitch setValue:[[_serverInfo objectForKey:RFB_SHARED] boolValue] ? 1.0f : 0.0f];
	[_viewOnlySwitch setValue:[[_serverInfo objectForKey:RFB_VIEWONLY] boolValue] ? 1.0f : 0.0f];
	
	int depth = [[_serverInfo objectForKey:RFB_PIXEL_DEPTH] intValue];
	int segment = 2;
	switch (depth)
	{
		case 8:
			segment = 0;
			break;
		case 16:
			segment = 1;
			break;
		case 32:
			segment = 2;
			break;
	}
	[_pixelDepthControl setSelectedSegment:segment];
	
	[_table reloadData];
}

- (void)deleteButtonPressed:(id)sender
{
	if (_delegate && [_delegate respondsToSelector:@selector(deleteServer)])
	{
		[_delegate deleteServer];
	}
}

- (void)navigationBar:(id)navBar buttonClicked:(int)buttonIndex
{
	NSDictionary * resultDict;
	
	switch (buttonIndex)
	{
		// Done
		case 0:
			// Update server info dict from the cell values
			[_serverInfo setObject:[[_cells objectAtIndex:kServerNameCellIndex] value] forKey:RFB_NAME];
			[_serverInfo setObject:[[_cells objectAtIndex:kServerAddressCellIndex] value] forKey:RFB_HOSTANDPORT];
			[_serverInfo setObject:[[_cells objectAtIndex:kServerPasswordCellIndex] value] forKey:RFB_PASSWORD];
			[_serverInfo setObject:[NSNumber numberWithInt:[[[_cells objectAtIndex:kServerDisplayCellIndex] value] intValue]] forKey:RFB_DISPLAY];
			[_serverInfo setObject:[NSNumber numberWithBool:([_sharedSwitch value] > 0.1)] forKey:RFB_SHARED];
			[_serverInfo setObject:[NSNumber numberWithBool:([_viewOnlySwitch value] > 0.1)] forKey:RFB_VIEWONLY];
			
			int depth = 32;
			switch ([_pixelDepthControl selectedSegment])
			{
				case 0:
					depth = 8;
					break;
				case 1:
					depth = 16;
					break;
				case 2:
					depth = 32;
					break;
			}
			[_serverInfo setObject:[NSNumber numberWithInt:depth] forKey:RFB_PIXEL_DEPTH];
			
			resultDict = _serverInfo;
			break;
		
		// Back
		case 1:
			resultDict = nil;
			break;
	}
	
	if (_delegate && [_delegate respondsToSelector:@selector(finishedEditingServer:)])
	{
		[_delegate finishedEditingServer:resultDict];
	}
}

- (int)numberOfGroupsInPreferencesTable:(id)fp8
{
	return 2;
}

- (id)preferencesTable:(id)prefsTable cellForRow:(int)rowIndex inGroup:(int)groupIndex
{
	if (groupIndex == 0)
	{
		return [_cells objectAtIndex:rowIndex];
	}
	else
	{
		return _deleteCell;
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
