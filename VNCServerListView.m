//
//  VNCServerListView.m
//  vnsea
//
//  Created by Chris Reed on 9/9/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "VNCServerListView.h"
#import <UIKit/UITable.h>
#import <UIKit/UITableCell.h>
#import <UIKit/UISimpleTableCell.h>
#import <UIKit/UITableColumn.h>
#import <UIKit/UIImageAndTextTableCell.h>
#import <UIKit/UINavBarButton.h>
#import <UIKit/UINavigationItem.h>
#import "ServerStandAlone.h"
#import "ServerFromPrefs.h"

#define kNavBarHeight (48)
#define kButtonBarHeight (48)

#define kAddButtonWidth (34)
#define kAddButtonHeight (40)

#define kAboutButtonHeight (32)
#define kAboutButtonWidth (80)

#define kPreferencesButtonHeight (32)
#define kPreferencesButtonWidth (120)

extern id UIImageGetNavigationBarAddButton();

@implementation VNCServerListView

- (id)initWithFrame:(CGRect)frame
{
	if ([super initWithFrame:frame])
	{
		CGRect subframe;
		CGSize navBarSize = [UINavigationBar defaultSize];
		
		subframe = CGRectMake(0.0f, 0.0f, frame.size.width, navBarSize.height);
		
		// Setup navbar
		_navBar = [[UINavigationBar alloc] initWithFrame: subframe];
		[_navBar showLeftButton:nil withStyle:0 rightButton:UIImageGetNavigationBarAddButton() withStyle:0];
		[_navBar setBarStyle: 3];
		[_navBar setDelegate: self];
		[_navBar enableAnimation];	
		
		UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:NSLocalizedString(@"VNC Servers", nil)];
		[_navBar pushNavigationItem:item];

		// Setup button bar at bottom
		subframe = CGRectMake(0, frame.size.height - kButtonBarHeight, frame.size.width, kButtonBarHeight);
		_buttonBar = [[UIGradientBar alloc] initWithFrame:subframe];
		
        const float kTextComponents[] = { .94, .94, .94, .7 };
        const float kTransparentComponents[] = { 0, 0, 1, 0 };
        const float kTextComponentsDateTime[] = { 0.4, 0.4, 0.4, 1 };
		
        CGColorSpaceRef rgbSpace = CGColorSpaceCreateDeviceRGB();
        CGColorRef textColorStatus = CGColorCreate(rgbSpace, kTextComponents);
        CGColorRef rgbTransparent = CGColorCreate(rgbSpace, kTransparentComponents);
		
        _textColorDateTime = CGColorCreate(rgbSpace, kTextComponentsDateTime);
		CGColorSpaceRelease(rgbSpace);
		
		// Go ahead and create font for drawing the last connect column
		_lastConnectFont = GSFontCreateWithName("Helvetica", 0, 12.0f);
		
		// Add about button
		subframe = CGRectMake(10.0f, (kButtonBarHeight - kAboutButtonHeight) / 2.0 + 1, kAboutButtonWidth, kAboutButtonHeight);
		_aboutButton = [[UINavBarButton alloc] initWithFrame:subframe];
		[_aboutButton setAutosizesToFit: NO];
		[_aboutButton addTarget:self action: @selector(showAbout:) forEvents:kGSEventTypeButtonSelected];
		[_aboutButton setNavBarButtonStyle: 0];
		[_aboutButton setTitle: NSLocalizedString(@"About", nil)];
		[_aboutButton setEnabled: YES];

		// Add server button
		subframe = CGRectMake(frame.size.width - 10.0f - kPreferencesButtonWidth, (kButtonBarHeight - kPreferencesButtonHeight) / 2.0 + 1, kPreferencesButtonWidth, kPreferencesButtonHeight);
		_preferencesButton = [[UINavBarButton alloc] initWithFrame:subframe];
		[_preferencesButton setAutosizesToFit: NO];
		[_preferencesButton addTarget:self action: @selector(showPreferences:) forEvents:kGSEventTypeButtonSelected];
		[_preferencesButton setNavBarButtonStyle: 0];
		[_preferencesButton setTitle: NSLocalizedString(@"Preferences", nil)];
		[_preferencesButton setEnabled: YES];

		// Setup server table
		subframe = CGRectMake(0, navBarSize.height, frame.size.width, frame.size.height - navBarSize.height - kButtonBarHeight);
		_serverColumn = [[UITableColumn alloc] initWithTitle:@"Servers" identifier:@"servers" width:frame.size.width - (150)];
		_serverLastConnectColumn = [[UITableColumn alloc] initWithTitle:@"Last Connect" identifier:@"lastConnect" width:150];
		_serverTable = [[UITable alloc] initWithFrame:subframe];
		[_serverTable addTableColumn:_serverColumn];
		[_serverTable addTableColumn:_serverLastConnectColumn];
		[_serverTable setDelegate:self];
		[_serverTable setDataSource:self];
		[_serverTable setReusesTableCells:NO];
		
		// Construct view hierarchy
		[_navBar addSubview:_addButton];
		[_buttonBar addSubview:_aboutButton];
		[_buttonBar addSubview:_preferencesButton];
		[self addSubview:_buttonBar];
		[self addSubview:_navBar];
		[self addSubview:_serverTable];
	}
	
	return self;
}

- (void)dealloc
{
	CFRelease(_textColorDateTime);
	CFRelease(_lastConnectFont);
	[_servers release];
	[super dealloc];
}

- (void)setServerList:(NSArray *)list
{
	[_servers release];
	_servers = [list retain];
	
	[_serverTable reloadData];
	[_serverTable updateDisclosures];
}

- (void)setDelegate:(id)newDelegate
{
	_delegate = newDelegate;
}

- (id)delegate
{
	return _delegate;
}

- (void)handleNotification:(NSNotification *)notification
{
	NSLog(@"notification:%@ userInfo=%@", notification, [notification userInfo]);
}

- (void)addNewServer:(id)sender
{
	if (_delegate && [_delegate respondsToSelector:@selector(addNewServer)])
	{
		[_delegate addNewServer];
	}
}

- (void)showPreferences:(id)sender
{
	if (_delegate && [_delegate respondsToSelector:@selector(displayPrefs)])
	{
		[_delegate displayPrefs];
	}
}

- (void)showAbout:(id)sender
{
	if (_delegate && [_delegate respondsToSelector:@selector(displayAbout)])
	{
		[_delegate displayAbout];
	}
}

- (void)navigationBar:(id)navBar buttonClicked:(int)buttonIndex
{
	NSLog(@"navbar:%@ button:%d", navBar, buttonIndex);
	switch (buttonIndex)
	{
		case kNavBarAddServerButton:
			[self addNewServer:nil];
			break;
	}
}

- (void)alertSheet:(id)sheet buttonClicked:(int)buttonIndex
{  
	[sheet dismissAnimated:YES];
	[sheet release];
}

- (void)tableRowSelected:(id)theTable
{
	int selection = [_serverTable selectedRow];
	
	if (_delegate && [_delegate respondsToSelector:@selector(serverSelected:)])
	{
		[_delegate serverSelected:selection];
	}
}

- (BOOL)table:(id)theTable disclosureClickableForRow:(int)rowIndex
{
	return YES;
}

- (void)table:(UITable *)theTable disclosureClickedForRow:(int)row
{
	if (_delegate && [_delegate respondsToSelector:@selector(editServer:)])
	{
		[_delegate editServer:row];
	}
}

- (int)numberOfRowsInTable:(id)theTable
{
	return [_servers count];
}

- (id)table:(id)theTable cellForRow:(int)rowIndex column:(id)columnIndex
{	
	if (columnIndex == _serverLastConnectColumn )	
	{
		UIImageAndTextTableCell * cell = [[[UIImageAndTextTableCell alloc] init] autorelease];
		NSNumber *nb = [[_servers objectAtIndex:rowIndex] objectForKey:SERVER_LAST_CONNECT];
		if (nb == nil)
		{
			[cell setTitle:@"--- -- --:-- --"];
		}
		else
		{
			NSDate *dtLastConnect = [NSDate dateWithTimeIntervalSinceReferenceDate: [nb doubleValue]];
			[cell setTitle:[dtLastConnect descriptionWithCalendarFormat:@"%b %1d %I:%M %p" timeZone:nil locale:nil]];
		}
		
		[[cell titleTextLabel] setFont:_lastConnectFont];
		[[cell titleTextLabel] setColor:_textColorDateTime];

		[cell setShowDisclosure:YES];
		[cell setDisclosureClickable:YES];
		[cell setDisclosureStyle:1];
		return cell;
	}
	else
	{	
		UISimpleTableCell * cell = [[[UISimpleTableCell alloc] init] autorelease];
		[cell setTitle:[[_servers objectAtIndex:rowIndex] objectForKey:@"Name"]];
		[cell setShowDisclosure:NO];
		[cell setDisclosureClickable:YES];
		[cell setDisclosureStyle:1];
		return cell;
	}
	return nil;
}

- (BOOL)table:(id)theTable canSelectRow:(int)rowIndex;
{
	return YES;
}
/*
//These Methods track delegate calls made to the application
- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector 
{
	NSLog(@"Requested method for selector: %@", NSStringFromSelector(selector));
	return [super methodSignatureForSelector:selector];
}

- (BOOL)respondsToSelector:(SEL)aSelector 
{
	NSLog(@"Request for selector: %@", NSStringFromSelector(aSelector));
	return [super respondsToSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation 
{
	NSLog(@"Called from: %@", NSStringFromSelector([anInvocation selector]));
	[super forwardInvocation:anInvocation];
}
*/
@end
