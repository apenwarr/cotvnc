#import "VnseaApp.h"
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>
#import <UIKit/UITextView.h>
#import <UIKit/UITouchDiagnosticsLayer.h>
#import <UIKit/UINavBarButton.h>
#import <GraphicsServices/GraphicsServices.h>
#import "RFBConnection.h"
#import "Profile.h"
#import "ServerStandAlone.h"
#import "ServerFromPrefs.h"
#import "Shimmer.h"

#define kControlsBarHeight (48.0f)

#define kClearButtonName @"Clear"
#define kClearButtonWidth (70.0f)
#define kClearButtonHeight (32.0f)

#define kSaveButtonName @"Save"
#define kSaveButtonWidth (70.0f)
#define kSaveButtonHeight (32.0f)

#define kRevertButtonName @"Revert"
#define kRevertButtonWidth (100.0f)
#define kRevertButtonHeight (32.0f)

#define kServersFilePath @"/var/root/Library/Preferences/vnsea_servers.plist"

#define kServerArrayKey @"servers"

#define kUpdateURL @"http://www.manyetas.com/creed/iphone/pxl/vnsea.plist"

#define kAboutMessage @"\
Copyright 2007 Chris Reed\n\
Licensed under GPLv3\n\
http://code.google.com/p/vnsea"

#define kAppVersion @"VNsea 0.2"

@implementation VnseaApp

- (void)applicationDidFinishLaunching:(NSNotification *)unused
{
//	NSLog(@"Vnsea app launching");
	
	CGRect screenRect = [UIHardware fullScreenApplicationContentRect];
	CGRect frame;
	
	//Initialize window
	_window = [[UIWindow alloc] initWithContentRect: screenRect];
//	[_window _setHidden: YES];
	
	//Setup main view
    screenRect.origin.x = 0.0;
	screenRect.origin.y = 0.0f;
    _mainView = [[UIView alloc] initWithFrame: screenRect];
    [_window setContentView: _mainView];
	
	frame = CGRectMake(0.0f, 0.0f, screenRect.size.width, screenRect.size.height);
	
	// Transition view
	_transView = [[UITransitionView alloc] initWithFrame:frame];
	[_mainView addSubview: _transView];

	// Scroll view
/*	_vncScroller = [[UIScroller alloc] initWithFrame: frame];
	[_vncScroller setScrollingEnabled:YES];
	[_vncScroller setShowScrollerIndicators:YES];
	[_vncScroller setAdjustForContentSizeChange:YES];// why isn't this working?
	[_vncScroller setAllowsRubberBanding:NO];
	[_vncScroller setAllowsFourWayRubberBanding:NO];
	[_vncScroller setThumbDetectionEnabled:YES];
//	[_vncScroller setScrollerIndicatorStyle:1];*/
	
	// vncsea view
	_vncView = [[VNCView alloc] initWithFrame: frame];
//	[_vncScroller addSubview: _vncView];
	
//	NSLog(@"vncView=%@", vncView);

	// Server manager view
	_serversView = [[VNCServerListView alloc] initWithFrame:frame];
	[_serversView setDelegate:self];
	[_serversView setServerList:[self loadServers]];
	
	// Server editor view
	_serverEditorView = [[VNCServerInfoView alloc] initWithFrame:frame];
	[_serverEditorView setDelegate:self];
	
	// Profile
	_defaultProfile = [[Profile defaultProfile] retain];
//	NSLog(@"profile=%@", _defaultProfile);
	
	// Switch to the list view
	[_transView transition:0 toView:_serversView];

	[_window orderFront: self];
	[_window makeKey: self];
	[_window _setHidden: NO];
	
	[self reportAppLaunchFinished];
	
//	NSLog(@"orientN=%d, orientY=%d", [UIHardware deviceOrientation:YES], [UIHardware deviceOrientation:NO]);
//	NSLog(@"orient=%d", [self orientation]);
//	NSLog(@"roleID=%@", [self roleID]);
//	NSLog(@"displayIdentifier=%@", [self displayIdentifier]);
	
//	[self setIgnoresInteractionEvents:NO];
	
	[self checkForUpdate];
}

- (void)dealloc
{
	[_window release];
	[_defaultProfile release];

	[super dealloc];
}

//! Use Shimmer to check for an available update, ask the user if it should be
//! installed, and then download and install it.
- (void)checkForUpdate
{
	Shimmer * shimmer = [[[Shimmer alloc] init] autorelease];
	if ([shimmer checkForUpdateHere:kUpdateURL])
	{
		[shimmer setAboveThisView:_transView];
		[shimmer doUpdate];
	}
}
/*
- (void) applicationResume: (struct __GSEvent *)unknown1 withArguments:(id)unknown2
{
	[_window _setHidden: NO];
}

- (void) applicationSuspend: (id)unknown1 settings: (id)unknown2
{
	[self applicationSuspended: nil];
}

- (void) applicationResume: (struct __GSEvent *)unknown
{
	[self applicationDidResume];
	[_window _setHidden: NO];
}
*/
- (NSArray *)loadServers
{
	NSDictionary * dict = [NSDictionary dictionaryWithContentsOfFile:kServersFilePath];
	NSLog(@"load");
	if (dict == nil)
	{
		return [NSArray array];
	}
	return [dict objectForKey:kServerArrayKey];
}

- (void)saveServers:(NSArray *)theServers
{
	NSLog(@"save");
	NSDictionary * prefs = [NSDictionary dictionaryWithObject:theServers forKey:kServerArrayKey];
	[prefs writeToFile:kServersFilePath atomically:YES];
}

- (void)serverSelected:(int)serverIndex
{
//	[self setStatusBarShowsProgress:YES];
//	[self setStatusBarCustomText:@"Connecting..."];
	
	NSArray * servers = [self loadServers];
	
	// Without the retain on serverInfo, we get a crash when theServer is released. Not sure why...
	NSDictionary * serverInfo = [[servers objectAtIndex:serverIndex] retain];
	
	ServerFromPrefs * theServer = [[[ServerFromPrefs alloc] initWithPreferenceDictionary:serverInfo] autorelease];
	
	NSLog(@"opening connection...");
	NSLog(@"  server:  %@", theServer);
	NSLog(@"  profile: %@", _defaultProfile);
	NSLog(@"  view:    %@", _vncView);
	NSLog(@"  index:   %d", serverIndex);
	NSLog(@"  info:    %@", serverInfo);
	
	// Create connection for this server. The init method won't return until
	// the connection is established.
	RFBConnection * connection = [[RFBConnection alloc] initWithServer:theServer profile:_defaultProfile view:_vncView];
	if (connection)
	{
		NSLog(@"connection=%@", connection);
		[connection manuallyUpdateFrameBuffer:self];
		
		[_transView transition:1 fromView:_serversView toView:_vncView];
	}
	else
	{
		NSLog(@"connection failed");
		
		UIAlertSheet * hotSheet = [[UIAlertSheet alloc]
					initWithTitle:@"Connection failed"
					buttons:[NSArray arrayWithObject:@"OK"]
					defaultButtonIndex:0
					delegate:self
					context:self];
		
//		[hotSheet setBodyText:reason];
		[hotSheet setDimsBackground:YES];
		[hotSheet _slideSheetOut:YES];
		[hotSheet setRunsModal:YES];
		[hotSheet setShowsOverSpringBoardAlerts:NO];
		
		[hotSheet popupAlertAnimated:YES];
	}
	
//	[self setStatusBarShowsProgress:NO];
//	[self setStatusBarCustomText:nil];
}

- (void)alertSheet:(id)sheet buttonClicked:(int)buttonIndex
{  
	[sheet dismissAnimated:YES];
	[sheet release];
}

- (void)editServer:(int)serverIndex
{
	NSLog(@"editServer:%d", serverIndex);
	
	_editingIndex = serverIndex;
	
	NSArray * servers = [self loadServers];
	NSDictionary * serverInfo = [servers objectAtIndex:serverIndex];
	[_serverEditorView setServerInfo:serverInfo];
	
	// Hide keyboard before switching in case it was visible.
	[_serverEditorView setKeyboardVisible:NO];
	
	// Switch to the editor view
	[_transView transition:1 fromView:_serversView toView:_serverEditorView];
}

- (void)addNewServer
{
	NSLog(@"add server");
	
	NSMutableArray * servers = [[self loadServers] mutableCopy];
	NSDictionary * info = [self defaultServerInfo];
	[servers addObject:info];
	[self saveServers:servers];
	
	int newIndex = [servers count] - 1;
	[self editServer:newIndex];
}

- (void)finishedEditingServer:(NSDictionary *)serverInfo
{
	NSLog(@"finished editing:%@", serverInfo);
	
	NSMutableArray * servers = [[self loadServers] mutableCopy];
	if (serverInfo)
	{
		[servers replaceObjectAtIndex:_editingIndex withObject:serverInfo];
		[self saveServers:servers];
	}
	
	// Reload list
	[_serversView setServerList:servers];
	
	// Switch back to the list view
	[_transView transition:2 fromView:_serverEditorView toView:_serversView];
}

//! This message is sent from the server edit view when the user presses the
//! Delete Server button.
- (void)deleteServer
{
	NSMutableArray * servers = [[self loadServers] mutableCopy];
	[servers removeObjectAtIndex:_editingIndex];
	[self saveServers:servers];
	
	// Reload list
	[_serversView setServerList:servers];
	
	// Switch back to the list view
	[_transView transition:2 fromView:_serverEditorView toView:_serversView];
}

- (NSDictionary *)defaultServerInfo
{
	NSMutableDictionary * info = [NSMutableDictionary dictionary];
	[info setObject:@"new server" forKey:RFB_NAME];
	[info setObject:@"localhost" forKey:RFB_HOSTANDPORT];
	[info setObject:@"" forKey:RFB_PASSWORD];
	[info setObject:[NSNumber numberWithBool:YES] forKey:RFB_REMEMBER];
	[info setObject:[NSNumber numberWithInt:0] forKey:RFB_DISPLAY];
	[info setObject:@"Default" forKey:RFB_LAST_PROFILE];
	[info setObject:[NSNumber numberWithBool:NO] forKey:RFB_SHARED];
	[info setObject:[NSNumber numberWithInt:32] forKey:RFB_PIXEL_DEPTH];
	[info setObject:[NSNumber numberWithBool:NO] forKey:RFB_FULLSCREEN];
	[info setObject:[NSNumber numberWithBool:NO] forKey:RFB_VIEWONLY];
	
	return info;
}

- (void)displayAbout
{
	UIAlertSheet * hotSheet = [[UIAlertSheet alloc]
		initWithTitle:kAppVersion
		buttons:[NSArray arrayWithObject:@"OK"]
		defaultButtonIndex:0
		delegate:self
		context:self];

	[hotSheet setBodyText:kAboutMessage];
	[hotSheet setDimsBackground:NO];
	[hotSheet setRunsModal:YES];
	[hotSheet setShowsOverSpringBoardAlerts:NO];
	
	[hotSheet popupAlertAnimated:YES];
}

- (void)deviceOrientationChanged:(GSEvent *)event
{
	NSLog(@"orientation changed: %@ to: %d", event, [UIHardware deviceOrientation:YES]);
}

- (void)acceleratedInX:(float)x Y:(float)y Z:(float)z
{
	NSLog(@"accel: x=%f, y=%f, z=%f", x, y, z);
}
/*
- (void)statusBarMouseDown:(GSEvent *)event
{
	NSLog(@"statusBarMouseDown:%@", event);
}

- (void)statusBarMouseDragged:(GSEvent *)event
{
	NSLog(@"statusBarMouseDragged:%@", event);
}

- (void)statusBarMouseUp:(GSEvent *)event
{
	NSLog(@"statusBarMouseUp:%@", event);
}

- (void)volumeChanged:(GSEvent *)event
{
	NSLog(@"volumeChanged:%@", event);
}

- (void)lockButtonDown:(GSEvent *)event
{
	NSLog(@"lockButtonDown:%@", event);
}

- (void)lockButtonUp:(GSEvent *)event
{
	NSLog(@"lockButtonUp:%@", event);
}

- (void)lockDevice:(GSEvent *)event
{
	NSLog(@"volumeChanged:%@", event);
}

- (void)menuButtonDown:(GSEvent *)event
{
	NSLog(@"menuButtonDown:%@", event);
}

- (void)menuButtonUp:(GSEvent *)event
{
	NSLog(@"menuButtonDown:%@", event);
}

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


