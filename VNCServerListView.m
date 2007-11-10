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

#define kNavBarHeight (48)
#define kButtonBarHeight (48)
#define kAddButtonHeight (48)
#define kAddButtonWidth (120)

@implementation VNCServerListView

- (id)initWithFrame:(CGRect)frame
{
	if ([super initWithFrame:frame])
	{
		CGRect subframe;
		CGSize navBarSize;// = [UINavigationBar defaultSize];
		navBarSize.height = kNavBarHeight;
		
		subframe = CGRectMake(0.0f, 0.0f, frame.size.width, kNavBarHeight);
		
		// Setup navbar
		_navBar = [[UINavigationBar alloc] initWithFrame: subframe];
		[_navBar showButtonsWithLeftTitle:NSLocalizedString(@"+", nil) rightTitle:NSLocalizedString(@"Preferences", nil) leftBack: NO];
		[_navBar setBarStyle: 3];
		[_navBar setDelegate: self];
		[_navBar enableAnimation];	
		
/*			
		UINavBarButton *_fitWidthButton = [[UINavBarButton alloc] initWithImage:[UIImage imageNamed:@"FitWidth.png"]];
		[_fitWidthButton setFrame:CGRectMake(0,0,30,30)];
		[_fitWidthButton setShowPressFeedback:YES];
		[_fitWidthButton setDrawsShadow:NO];
		[_fitWidthButton setNavBarButtonStyle: 5];
//		[_fitWidthButton addTarget:self action:@selector(toggleFitWidthHeight:) forEvents:kUIControlEventMouseUpInside];
		
		[_navBar addSubview:_fitWidthButton];
*/		
		[self addSubview: _navBar];
		
		UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:NSLocalizedString(@"VNC Servers", nil)];
		[_navBar pushNavigationItem:item];
		
		// Setup button bar at bottom
		subframe = CGRectMake(0, frame.size.height - kButtonBarHeight, frame.size.width, kButtonBarHeight);
		_buttonBar = [[UIGradientBar alloc] initWithFrame:subframe];
		[self addSubview:_buttonBar];
		
		subframe = CGRectMake(0, 2, frame.size.width-4, kButtonBarHeight-4);
		UITextLabel *_copyText = [[UITextLabel alloc] initWithFrame: subframe];

        const float kTextComponents[] = { .94, .94, .94, .7 };
        const float kTransparentComponents[] = { 0, 0, 1, 0 };
        const float kTextComponentsDateTime[] = { 0, 0, 1, .8 };
		
        CGColorSpaceRef rgbSpace = CGColorSpaceCreateDeviceRGB();
        CGColorRef textColorStatus = CGColorCreate(rgbSpace, kTextComponents);
        CGColorRef rgbTransparent = CGColorCreate(rgbSpace, kTransparentComponents);
		
        _textColorDateTime = CGColorCreate(rgbSpace, kTextComponentsDateTime);
		CGColorSpaceRelease(rgbSpace);
		
		GSFontRef font = GSFontCreateWithName("Helvetica", 0, 16.0f);
		[_copyText setFont:font];
		CFRelease(font);
		[_copyText setBackgroundColor: rgbTransparent];
		[_copyText setText:@"Copyright 2007 Chris Reed, Glenn Kreisel"];
		[_copyText setColor:textColorStatus];
		[_copyText setCentersHorizontally: true];
		[_buttonBar addSubview: _copyText];
		
		// Add server button
/*		subframe = CGRectMake(frame.size.width - 10.0f - kAddButtonWidth, (kButtonBarHeight - kAddButtonHeight) / 2.0, kAddButtonWidth, kAddButtonHeight);
		_addButton = [[UINavBarButton alloc] initWithFrame:subframe];
		[_addButton setAutosizesToFit: NO];
		[_addButton addTarget:self action: @selector(addNewServer:) forEvents:kGSEventTypeButtonSelected];
		[_addButton setNavBarButtonStyle: 0];
		[_addButton setTitle: kAddButtonName];
		[_addButton setEnabled: YES];
		[_buttonBar addSubview: _addButton];
*/
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
//		[_serverTable reloadData];
//		[_serverTable updateDisclosures];
		[self addSubview: _serverTable];
		
//		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:nil object:_serverTable];
	}
	
	return self;
}

- (void)dealloc
{
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

- (void)navigationBar:(id)navBar buttonClicked:(int)buttonIndex
{
	NSLog(@"navbar:%@ button:%d", navBar, buttonIndex);
	switch (buttonIndex)
	{
		case kNavBarEditButton:
			[self addNewServer:nil];
			break;
			
		case kNavBarPrefsButton:
			if (_delegate && [_delegate respondsToSelector:@selector(displayPrefs)])
			{
				[_delegate displayPrefs];
			}
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
	[theTable _selectRow:row byExtendingSelection:NO withFade:NO scrollingToVisible:YES withSelectionNotifications:NO];
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
		NSNumber *nb = [[_servers objectAtIndex:rowIndex] objectForKey:@"LastConnectTime"];
		if (nb == nil)
			[cell setTitle:@"--- -- --:-- --"];
		else
			{
			NSDate *dtLastConnect = [NSDate dateWithTimeIntervalSinceReferenceDate: [nb doubleValue]];
			[cell setTitle:[dtLastConnect descriptionWithCalendarFormat:@"%b %d %I:%M %p" timeZone:nil locale:nil]];
			}
		GSFontRef font = GSFontCreateWithName("Helvetica", 0, 12.0f);
		[[cell titleTextLabel] setFont:font];
		[[cell titleTextLabel] setColor:_textColorDateTime];
		CFRelease(font);
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
