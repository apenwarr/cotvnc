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

//! URL for a plist that contains information about the latest version
//! of the application, for use by Shimmer.
#define kUpdateURL @"http://www.manyetas.com/creed/iphone/shimmer/vnsea.plist"

//! If a connection attempt takes longer than this amount of time, then
//! an alert is displayed telling the user what is going on.
#define kConnectionAlertTime (0.6f)

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

	// vncsea view
	_vncView = [[VNCView alloc] initWithFrame: frame];

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

//	[self displayAbout];
	
	[NSThread detachNewThreadSelector:@selector(checkForUpdate:) toTarget:self withObject:nil];
}

- (void)dealloc
{
	[_window release];
	[_defaultProfile release];

	[super dealloc];
}

//! Use Shimmer to check for an available update, ask the user if it should be
//! installed, and then download and install it. This method is executed on a
//! separate thread, so attempting the connection will not freeze the UI.
- (void)checkForUpdate:(id)unused
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	Shimmer * shimmer = [[Shimmer alloc] init];
	if ([shimmer checkForUpdateHere:kUpdateURL])
	{
		// An update is available, so give the user the option to update.
		// The update is performed on the main thread since it operates
		// with the UI.
		[self performSelectorOnMainThread:@selector(doUpdate:) withObject:shimmer waitUntilDone:NO];
	}
	
	[pool release];
}

- (void)doUpdate:(Shimmer *)shimmer
{
	[shimmer setAboveThisView:_transView];
	[shimmer setUseCustomView:YES];
	[shimmer doUpdate];
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
	[self setStatusBarShowsProgress:YES];
	
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
	
	// Create the connection object.
	_didOpenConnection = NO;
	_connection = [[RFBConnection alloc] initWithServer:theServer profile:_defaultProfile view:_vncView];

	// Create a condition lock used to synchronise this thread with the
	// connection thread.
	_connectLock = [[NSConditionLock alloc] initWithCondition:0];
	
	// Spawn a thread to open the connection in. This lets us manage the
	// UI while the connection is being attempted.
	[NSThread detachNewThreadSelector:@selector(connectToServer:) toTarget:self withObject:_connection];
	
	// While the connection is being attempted, sit back and wait. If it ends up
	// taking longer than a second or so, put up an alert sheet that says that
	// the connection is in progress.
	UIAlertSheet * connectAlert = nil;
	NSTimeInterval startTime = [NSDate timeIntervalSinceReferenceDate];
	while ([_connectLock tryLockWhenCondition:1] == NO)
	{
		if (connectAlert == nil)
		{
			NSTimeInterval deltaTime = [NSDate timeIntervalSinceReferenceDate] - startTime;
			if (deltaTime > kConnectionAlertTime)
			{
				connectAlert = [[UIAlertSheet alloc]
						initWithTitle:NSLocalizedString(@"ConnectingToServer", nil)
						buttons:nil //[NSArray arrayWithObject:@"Cancel"]
						defaultButtonIndex:0
						delegate:self
						context:self];
				[connectAlert setAlertSheetStyle:1];
				[connectAlert setRunsModal:NO];
				[connectAlert setDimsBackground:NO];
				[connectAlert _slideSheetOut:YES];
				[connectAlert presentSheetFromAboveView:_transView];
			}
		}
		
		// Run the run loop for a little bit to give the alert sheet some time
		// to animate and so we don't hog the CPU.
		[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.25f]];
	}
	
	if (connectAlert)
	{
		[connectAlert dismissAnimated:YES];
		[connectAlert release];
	}
	
	// NSConditionLock doesn't like to be dealloc's when still locked.
	[_connectLock unlockWithCondition:0];
	[_connectLock release];
	_connectLock = nil;
	
	// Stop the status bar progress
	[self setStatusBarShowsProgress:NO];

	// Either switch to the screen view or present an error alert depending on
	// whether the connection succeeded.
	if (_didOpenConnection)
	{
		NSLog(@"connection=%@", _connection);
		[_vncView setConnection:_connection];
		[_connection setDelegate:self];
		[_connection startTalking];
		[_connection manuallyUpdateFrameBuffer:self];
		
		[_transView transition:1 fromView:_serversView toView:_vncView];
	}
	else
	{
		NSLog(@"connection failed");
		[_connection release];
		_connection = nil;
		
		UIAlertSheet * hotSheet = [[UIAlertSheet alloc]
					initWithTitle:NSLocalizedString(@"Connection failed", nil)
					buttons:[NSArray arrayWithObject:NSLocalizedString(@"OK", nil)]
					defaultButtonIndex:0
					delegate:self
					context:self];
		
		[hotSheet setBodyText:_connectError];
		[hotSheet setDimsBackground:NO];
		[hotSheet setRunsModal:YES];
		[hotSheet setShowsOverSpringBoardAlerts:NO];
		[hotSheet popupAlertAnimated:YES];
		
		// We no longer need the error message.
		[_connectError release];
		_connectError = nil;
	}
}

- (void)connectToServer:(RFBConnection *)connection
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	// Grab the lock.
	[_connectLock lockWhenCondition:0];
	
	// Attempt to open a connection to theServer.
	_didOpenConnection = [connection openConnectionReturningError:&_connectError];
	
	// Need to keep the error message around.
	if (_connectError)
	{
		[_connectError retain];
	}
	
	// Unlock to signal that we're done.
	[_connectLock unlockWithCondition:1];
	
	[pool release];
}

- (void)connection:(RFBConnection *)connection hasTerminatedWithReason:(NSString *)reason
{
	NSArray * buttons = [NSArray arrayWithObject:@"OK"];
	
	UIAlertSheet * hotSheet = [[UIAlertSheet alloc]
				initWithTitle:NSLocalizedString(@"Connection terminated", nil)
				buttons:buttons
				defaultButtonIndex:0
				delegate:self
				context:self];
	
	[hotSheet setBodyText:reason];
	[hotSheet setDimsBackground:YES];
	[hotSheet _slideSheetOut:YES];
	[hotSheet setRunsModal:YES];
	[hotSheet setShowsOverSpringBoardAlerts:NO];
	
//	[hotSheet presentSheetToAboveView:self];
	[hotSheet popupAlertAnimated:YES];
	
	// Switch back to the list view
	[_transView transition:2 fromView:_vncView toView:_serversView];
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
		initWithTitle:NSLocalizedString(@"AboutVersion", nil)
		buttons:[NSArray arrayWithObject:NSLocalizedString(@"OK", nil)]
		defaultButtonIndex:0
		delegate:self
		context:self];

	[hotSheet setBodyText:NSLocalizedString(@"AboutMessage", nil)];
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
/*
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


