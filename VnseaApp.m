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
#import "VNCServerInfoView.h"
#import "VNCPreferences.h"
#import <stdlib.h>
#import <signal.h>

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

extern NSString * UIApplicationOrientationDidChangeNotification;
extern NSString * UIApplicationOrientationUserInfoKey;

//! @brief Signal handler for SIGINT.
//!
//! Simply terminates the application, which will cause any open connection
//! to be gracefully shutdown.
void handle_interrupt_signal(int sig)
{
	NSLog(@"received signal %d, exiting", sig);
	[UIApp terminate];
}

//! @brief Compare function to sort servers.
int compareServers(id obj1, id obj2, void *reverse)
{
	NSDictionary *serverInfo = (NSDictionary *)obj1;
	NSDictionary *serverInfo1 = (NSDictionary *)obj2;
	
	return [[serverInfo objectForKey:RFB_NAME] compare: [serverInfo1 objectForKey:RFB_NAME]];
}

@implementation VnseaApp

- (void)applicationDidFinishLaunching:(NSNotification *)unused
{
	// We ignore SIGPIPE instead of having the default handler terminate us when
	// the other end of a socket disappears.
	signal(SIGPIPE, SIG_IGN);
	
	// Handle signal sent by ^C, mostly for development.
	signal(SIGINT, handle_interrupt_signal);
	
	CGRect screenRect = [UIHardware fullScreenApplicationContentRect];
	CGRect frame = CGRectMake(0.0f, 0.0f, screenRect.size.width, screenRect.size.height);
	
	// Setup main view
    _mainView = [[UIView alloc] initWithFrame: frame];
	
	// Transition view
	_transView = [[UITransitionView alloc] initWithFrame:frame];
	[_mainView addSubview: _transView];

	// vncsea view
	CGRect rcNewFrame = frame;
	
//	rcNewFrame.size.height += [self statusBarRect].size.height;
	_vncView = [[VNCView alloc] initWithFrame: rcNewFrame];
	[_vncView setDelegate:self];

	// Server manager view
	_serversView = [[VNCServerListView alloc] initWithFrame:frame];
	[_serversView setDelegate:self];
	[_serversView setServerList:[self loadServers]];
	
	// Server editor view
	_serverEditorView = [[VNCServerInfoView alloc] initWithFrame:frame];
	[_serverEditorView setDelegate:self];

	// Preferences editing view
	_prefsView = [[VNCPrefsView alloc] initWithFrame:frame];
	[_prefsView setDelegate:self];
	
	// Profile
	_defaultProfile = [[Profile defaultProfile] retain];
	
	// Switch to the list view
	[_transView transition:0 toView:_serversView];

	//Initialize window
	_window = [[UIWindow alloc] initWithContentRect: screenRect];
    [_window setContentView: _mainView];
	[_window orderFront: self];
	[_window makeKey: self];
	[_window _setHidden: NO];
	
	// Tell the system we're ready.
	[self reportAppLaunchFinished];
	
	// Kick off a thread to check for a new version.
	[NSThread detachNewThreadSelector:@selector(checkForUpdate:) toTarget:self withObject:nil];
}

- (void)applicationSuspend:(GSEventRef)event
{
	if ([[VNCPreferences sharedPreferences] disconnectOnSuspend] || !_connection)
	{
		[self applicationWillTerminate];
		[self terminate];
	}
	else
	{
		// We have an active connection and the user wants to keep it,
		// so put up the badge that indicates a background connection.
		[self setApplicationBadge:NSLocalizedString(@"ApplicationBadgeConnected", nil)];
	}
	
	NSLog(@"Process Suspend");
}

- (void)applicationResume:(GSEventRef)event
{
	[self removeApplicationBadge];
	NSLog(@"Process Resume");
}

- (void)applicationExited:(GSEventRef)event
{
	NSLog(@"Process exited");
}

- (void)applicationWillTerminate
{
	[self closeConnection];
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
	
	Shimmer * shimmer = [[[Shimmer alloc] init] autorelease];
	if ([shimmer checkForUpdateHere:kUpdateURL])
	{
		// An update is available, so give the user the option to update.
		// The update is performed on the main thread since it operates
		// with the UI.
		[shimmer setAboveThisView:_transView];
		[shimmer setUseCustomView:YES];
		[shimmer doUpdate];
	}
	
	[pool release];
}

- (NSArray *)loadServers
{
	NSDictionary * dict = [NSDictionary dictionaryWithContentsOfFile:kServersFilePath];
	
	if (dict == nil)
	{
		return [NSArray array];
	}
	
	NSArray *nsArray = [dict objectForKey:kServerArrayKey];	
	return [nsArray sortedArrayUsingFunction: compareServers context:nil];
}

- (void)saveServers:(NSArray *)theServers
{
//	NSLog(@"save");
	NSDictionary * prefs = [NSDictionary dictionaryWithObject:theServers forKey:kServerArrayKey];
	[prefs writeToFile:kServersFilePath atomically:YES];
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

- (void)waitForConnection:(RFBConnection *)connection
{
	// Create a condition lock used to synchronise this thread with the
	// connection thread.
	_connectLock = [[NSConditionLock alloc] initWithCondition:0];
	
	// Spawn a thread to open the connection in. This lets us manage the
	// UI while the connection is being attempted.
	[NSThread detachNewThreadSelector:@selector(connectToServer:) toTarget:self withObject:connection];
	
	// While the connection is being attempted, sit back and wait. If it ends up
	// taking longer than a second or so, put up an alert sheet that says that
	// the connection is in progress.
	_connectAlert = nil;
	NSTimeInterval startTime = [NSDate timeIntervalSinceReferenceDate];
	while (!_closingConnection && ![_connectLock tryLockWhenCondition:1])
	{
		if (_connectAlert == nil)
		{
			NSTimeInterval deltaTime = [NSDate timeIntervalSinceReferenceDate] - startTime;
			if (deltaTime > kConnectionAlertTime)
			{
				_connectAlert = [[UIAlertSheet alloc]
						initWithTitle:nil
						buttons:[NSArray arrayWithObject:@"Cancel"]
						defaultButtonIndex:-1
						delegate:self
						context:self];
				[_connectAlert setBodyText:NSLocalizedString(@"ConnectingToServer", nil)];
				[_connectAlert setAlertSheetStyle:0];
				[_connectAlert setRunsModal:NO];
				[_connectAlert setDimsBackground:NO];
				[_connectAlert _slideSheetOut:YES];
				[_connectAlert presentSheetFromAboveView:_transView];
			}
		}
		
		// Run the run loop for a little bit to give the alert sheet some time
		// to animate and so we don't hog the CPU.
		[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:kConnectWaitRunLoopTime]];
	}
	
	// Get rid of the alert.
	if (_connectAlert)
	{
		[_connectAlert dismissAnimated:YES];
		[_connectAlert release];
		_connectAlert = nil;
	}
	
	// NSConditionLock doesn't like to be dealloc's when still locked.
	if (!_closingConnection)
	{
		[_connectLock unlockWithCondition:0];
		[_connectLock release];
		_connectLock = nil;
	}
}

- (void)_endedEditing;
{
	NSLog(@"Editing Ended");
}

- (BOOL)_shouldEndEditing;
{
	NSLog(@"Should Ended");
	return true;
}

- (void)gotFirstFullScreenTransitionNow
{
	[self setStatusBarShowsProgress:NO];
	[_transView transition:1 fromView:_serversView toView:_vncView];
			
	NSMutableArray * servers = [[self loadServers] mutableCopy];
	NSMutableDictionary * serverInfo = [[servers objectAtIndex:_serverConnectingIndex] mutableCopy];
	
//	[self setStatusBarMode: [self statusBarMode] orientation:90 duration:2];
			
	[serverInfo setObject:[NSNumber numberWithDouble: [[NSDate init] timeIntervalSinceReferenceDate]] forKey:SERVER_LAST_CONNECT];
	[servers replaceObjectAtIndex:_serverConnectingIndex withObject:serverInfo];
	[self saveServers: servers];
}

- (void)serverSelected:(int)serverIndex
{
	// Disable the server list view.
	[_serversView setEnabled:NO];
	
	// Without the retain on serverInfo, we get a crash when theServer is released. Not sure why...
	NSArray * servers = [self loadServers];
	NSMutableDictionary * serverInfo = [[[servers objectAtIndex:serverIndex] mutableCopy] retain];
	
	// Decrypt password before passing to VNC
	NSString *nsPassword = [_serverEditorView decryptPassword:[serverInfo objectForKey:RFB_PASSWORD]];
	if (nsPassword == nil || [nsPassword length] == 0)
	{
		UIAlertSheet * hotSheet = [[UIAlertSheet alloc]
		initWithTitle:NSLocalizedString(@"PasswordRequestTitle", nil)
		buttons:[NSArray arrayWithObject:NSLocalizedString(@"OK", nil)]
		defaultButtonIndex:1
		delegate:self
		context:self];
		
		[hotSheet setBodyText:NSLocalizedString(@"PasswordRequestText", nil)];
		[hotSheet addTextFieldWithValue: @"" label: @"password"];
		UITextField *tf = [hotSheet textFieldAtIndex:0];
		[tf setSecure:true];
		[tf setAutoCapsType: 0];
		[tf setAutoEnablesReturnKey:true];
		[hotSheet setDimsBackground:YES];
		[hotSheet setRunsModal:YES];
		[hotSheet setShowsOverSpringBoardAlerts:NO];
		[hotSheet popupAlertAnimated:YES];
				
		if (_lastAlertButtonIndexClicked == 2)
		{
			// Re-enable the server list view.
			[_serversView setEnabled:YES];
			return;
		}
		nsPassword = [tf text];
		NSLog(@"Input Password = %s", [nsPassword cString]);
	}
	
	[serverInfo setObject:nsPassword forKey:RFB_PASSWORD];
	NSNumber *nsScale = [serverInfo objectForKey:SERVER_SCALE];
	if (nsScale != nil)
	{
		NSLog(@"Setting remembered scale to %f", [nsScale floatValue]);
		[_vncView setScalePercent: [nsScale floatValue]];
	}
	
	// Get last scroll point and setup for when VNC server screen is shown
	CGPoint ptTopLeftVisible = CGPointMake([[serverInfo objectForKey:SERVER_SCROLL_X] intValue], [[serverInfo objectForKey:SERVER_SCROLL_Y] intValue]);
	[_vncView setStartupTopLeftPt:ptTopLeftVisible];
	
	ServerFromPrefs * theServer = [[[ServerFromPrefs alloc] initWithPreferenceDictionary:serverInfo] autorelease];
	
	_serverConnectingIndex = serverIndex;
	
	NSLog(@"opening connection...");
	NSLog(@"  server:  %@", theServer);
	NSLog(@"  profile: %@", _defaultProfile);
	NSLog(@"  view:    %@", _vncView);
	NSLog(@"  index:   %d", serverIndex);
	NSLog(@"  info:    %@", serverInfo);
	
	// Create the connection object.
	_didOpenConnection = NO;
	_closingConnection = NO;
	_connection = [[RFBConnection alloc] initWithServer:theServer profile:_defaultProfile view:_vncView];
	
	// Wait for the connection to complete. Show network activity in the status bar
	// during this time.
	[self setStatusBarShowsProgress:YES];
	[self waitForConnection:_connection];

	// Either switch to the screen view or present an error alert depending on
	// whether the connection succeeded.
	if (_didOpenConnection)
	{
		NSLog(@"connection=%@", _connection);
//		[self statusBarWillAnimateToHeight:0 duration:.2 fence:0];
//		[self setStatusBarMode:kUIStatusBarWhite duration:0];

		[_vncView setConnection:_connection];
		[_vncView showControls:YES];
		[_connection setDelegate:self];
		[_connection startTalking];
	}
	else if (!_closingConnection)
	{
		[self setStatusBarShowsProgress:NO];
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
	else
	{
		// The connection was canceled so set the current connection to nil.
		[_connection setView:nil];
		_connection = nil;
	}

	// Re-enable the server list view.
	[_serversView setEnabled:YES];
}

//! This method is executed as a background thread. The thread doesn't use
//! any globals, making local copies of the object references passed in, until
//! the connection is made and we're sure the user didn't cancel. This
//! lets the main thread code just abandon a connection thread when the user
//! cancels, knowing that it will clean itself up.
- (void)connectToServer:(RFBConnection *)connection
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	NSConditionLock * lock = _connectLock;	// Make a copy in case the connection is canceled.
	
	// Grab the lock.
	[lock lockWhenCondition:0];
	
	// Attempt to open a connection to theServer.
	NSString * message = nil;
	BOOL didOpen = [connection openConnectionReturningError:&message];
	
	// Just bail if the connection was canceled.
	if ([connection didCancelConnect])
	{
		[self setStatusBarShowsProgress:NO];
//		NSLog(@"connectToServer:connection canceled, releasing connection");
		
		// Get rid of the lock and connection. They were passed to our ownership
		// when the user hit cancel.
		[lock unlockWithCondition:0];
		[lock release];
		
		[connection release];
	}
	else
	{
		// Set globals from the connection results now that we know that the
		// user hasn't canceled.
		_didOpenConnection = didOpen;
		
		// Need to keep the error message around.
		if (message)
		{
			_connectError = [message retain];
		}
		
		// Unlock to signal that we're done.
		[lock unlockWithCondition:1];
	}
	
	[pool release];
}

- (void)connection:(RFBConnection *)connection hasTerminatedWithReason:(NSString *)reason
{
	[self setStatusBarShowsProgress:NO];
	// Don't need to display an alert if we intentionally closed the connection.
	if (!_closingConnection)
	{
		UIAlertSheet * hotSheet = [[UIAlertSheet alloc]
					initWithTitle:NSLocalizedString(@"Connection terminated", nil)
					buttons:[NSArray arrayWithObject:NSLocalizedString(@"OK", nil)]
					defaultButtonIndex:0
					delegate:self
					context:self];
		
		if (reason)
		{
			[hotSheet setBodyText:reason];
		}
		
		[hotSheet setDimsBackground:NO];
		[hotSheet _slideSheetOut:YES];
		[hotSheet setRunsModal:YES];
		[hotSheet setShowsOverSpringBoardAlerts:NO];
		
		[hotSheet popupAlertAnimated:YES];
	}
	
	[_connection autorelease];
	_connection = nil;
	
	[_vncView setConnection:nil];
	
	_closingConnection = NO;
	
	CGRect rcFrame = [_window frame];
	rcFrame.origin.y = 20;
	[_window setFrame: rcFrame];
	[self setStatusBarMode:kUIStatusBarWhite duration:1];
	
	// Switch back to the list view only if we got to the VNC Server View
	if ([_vncView isFirstDisplay])
	{
		[_transView transition:2 fromView:_vncView toView:_serversView];
	}
}

//! This method is used to force the connection closed. It is used by the VNCView
//! when the user wants t manually close the connection, as well as at application
//! termination time.
- (void)closeConnection
{
	NSLog(@"Set statusbar white");
		
	if (_connection)
	{
		NSMutableArray * servers = [[self loadServers] mutableCopy];
		NSMutableDictionary * serverInfo = [[servers objectAtIndex:_serverConnectingIndex] mutableCopy];
		
		NSLog(@"Saved Scale %f", [_vncView getScalePercent]);
		[serverInfo setObject:[NSNumber numberWithFloat:[_vncView getScalePercent]] forKey:SERVER_SCALE];
		
		// Saving the last scroll point in VNC Server screen
		CGPoint pt = [_vncView topLeftVisiblePt];
		
		NSLog(@"Saved Scroll %f, %f",pt.x, pt.y);
		[serverInfo setObject:[NSNumber numberWithInt:pt.x] forKey:SERVER_SCROLL_X];
		[serverInfo setObject:[NSNumber numberWithInt:pt.y] forKey:SERVER_SCROLL_Y];		
		
		[servers replaceObjectAtIndex:_serverConnectingIndex withObject:serverInfo];
		[self saveServers: servers];
		
		_closingConnection = YES;
		[_connection terminateConnection:nil];
		[_vncView setConnection: nil];
		_connection = nil;
		[_serversView setServerList:servers];
	}
}

- (void)alertSheet:(id)sheet buttonClicked:(int)buttonIndex
{
	_lastAlertButtonIndexClicked = buttonIndex;
	
	if (sheet == _connectAlert)
	{
		[self setStatusBarShowsProgress:NO];
		// The user hit the Cancel button on the "Connecting to server" alert.
		_closingConnection = YES;
		[_connection cancelConnect];
	}
	else
	{
		// Just close and release any other sheets.
		[sheet dismissAnimated:YES];
		[sheet release];
	}
}

- (void)editServer:(int)serverIndex
{
	NSDictionary * serverInfo = nil;
	NSLog(@"editServer:%d", serverIndex);
	
	_editingIndex = serverIndex;
	if (serverIndex != -1)
		{
		NSArray * servers = [self loadServers];
		serverInfo = [servers objectAtIndex:serverIndex];
		}
	[_serverEditorView setServerInfo:serverInfo];
	
	// Hide keyboard before switching in case it was visible.
	[_serverEditorView setKeyboardVisible:NO];	
	// Switch to the editor view
	[_transView transition:1 fromView:_serversView toView:_serverEditorView];
}

- (void)addNewServer
{
	NSLog(@"add server");
	[self editServer:-1];
}

- (void)serverValidationFailed:(NSString *)pnsBodyText
{
	UIAlertSheet * hotSheet = [[UIAlertSheet alloc]
		initWithTitle:NSLocalizedString(@"ServerInformationTitle", nil)
		buttons:[NSArray arrayWithObject:NSLocalizedString(@"OK", nil)]
		defaultButtonIndex:1
		delegate:self
		context:self];
	[hotSheet setBodyText:pnsBodyText];
	[hotSheet setDimsBackground:YES];
	[hotSheet setRunsModal:YES];
	[hotSheet setShowsOverSpringBoardAlerts:NO];
	[hotSheet popupAlertAnimated:YES];
}

- (void)displayPrefs
{
	NSLog(@"Display Prefs");
	
	[_prefsView updateViewFromPreferences];
	
	// Hide keyboard before switching in case it was visible.
	[_prefsView setKeyboardVisible:NO];
	
	// Switch to the editor view
	[_transView transition:1 fromView:_serversView toView:_prefsView];
}

- (void)finishedEditingPreferences
{
	// Hide keyboard before switching in case it was visible.
	[_prefsView setKeyboardVisible:NO];
	
	// Switch back to the list view
	[_transView transition:2 fromView:_prefsView toView:_serversView];
}

- (void)finishedEditingServer:(NSDictionary *)serverInfo
{
	NSLog(@"finished editing:%@", serverInfo);
	
	[_serverEditorView setKeyboardVisible:NO];	

	NSMutableArray * servers = [[self loadServers] mutableCopy];
	if (serverInfo)
	{
		if (_editingIndex == -1)
		{
			[servers addObject:serverInfo];
		}
		else
		{
			[servers replaceObjectAtIndex:_editingIndex withObject:serverInfo];
		}
		
		[self saveServers: servers];
		servers = [[self loadServers] mutableCopy];
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
	UIAlertSheet * hotSheet = [[UIAlertSheet alloc]
		initWithTitle:NSLocalizedString(@"DeleteServerTitle", nil)
		buttons:[NSArray arrayWithObjects:NSLocalizedString(@"No", nil), NSLocalizedString(@"Yes", nil)]
		defaultButtonIndex:1
		delegate:self
		context:self];

	[hotSheet setBodyText:NSLocalizedString(@"DeleteServerMessage", nil)];
	[hotSheet setDimsBackground:YES];
	[hotSheet setRunsModal:YES];
	[hotSheet setShowsOverSpringBoardAlerts:NO];
	[hotSheet popupAlertAnimated:YES];
	
	NSMutableArray * servers = [[self loadServers] mutableCopy];
	if (_lastAlertButtonIndexClicked == 2)
		{	
		NSLog(@"Trying to Delete ServerInfo %d", _editingIndex);
		if (_editingIndex != -1)
			{
			[servers removeObjectAtIndex:_editingIndex];
			[self saveServers:servers];
			}
		}
	else
		return;
		
	// Reload list
	[_serversView setServerList:servers];
	
	// Switch back to the list view
	[_transView transition:2 fromView:_serverEditorView toView:_serversView];
}

- (NSDictionary *)defaultServerInfo
{
	NSMutableDictionary * info = [NSMutableDictionary dictionary];
	
	[info setObject:@"" forKey:RFB_NAME];
	[info setObject:@"" forKey:RFB_HOSTANDPORT];
	[info setObject:@"" forKey:RFB_PASSWORD];
	[info setObject:[NSNumber numberWithBool:YES] forKey:RFB_REMEMBER];
	[info setObject:[NSNumber numberWithInt:0] forKey:RFB_DISPLAY];
	[info setObject:@"Default" forKey:RFB_LAST_PROFILE];
	[info setObject:[NSNumber numberWithBool:NO] forKey:RFB_SHARED];
	[info setObject:[NSNumber numberWithInt:16] forKey:RFB_PIXEL_DEPTH];
	[info setObject:[NSNumber numberWithBool:NO] forKey:RFB_FULLSCREEN];
	[info setObject:[NSNumber numberWithBool:NO] forKey:RFB_VIEWONLY];
	return info;
}

- (void)deviceOrientationChanged:(GSEvent *)event
{
	// Get the real device center point to rotate around
	CGRect frame = [_vncView scrollerFrame];
	CGPoint ptCenter = CGPointMake(frame.origin.x+(frame.size.width / 2), frame.origin.y+(frame.size.height/2));
	
	[_vncView changeViewPinnedToPoint:ptCenter scale:[_vncView getScalePercent] orientation:[UIHardware deviceOrientation:YES] force:false];		
}

- (void)acceleratedInX:(float)x Y:(float)y Z:(float)z
{
	NSLog(@"accel: x=%f, y=%f, z=%f", x, y, z);
}

- (void)statusBarMouseDown:(GSEventRef)event
{
//	NSLog(@"statusBarMouseDown:%@", event);
}

- (void)statusBarMouseDragged:(GSEventRef)event
{
//	NSLog(@"statusBarMouseDragged:%@", event);
}

- (void)statusBarMouseUp:(GSEventRef)event
{
	if (_connection)
	{
		[_vncView toggleControls];
	}
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



