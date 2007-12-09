#if !defined(_VnseaApp_h_)
#define _VnseaApp_h_

#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <UIKit/CDStructures.h>
#import <UIKit/UIWindow.h>
#import <UIKit/UIView-Hierarchy.h>
#import <UIKit/UIHardware.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIApplication.h>
#import <UIKit/UIScroller.h>
#import <UIKit/UITransitionView.h>
#import "VNCView.h"
#import "VNCServerInfoView.h"
#import "VNCServerListView.h"
#import "VNCPrefsView.h"

@class Profile;
@class Shimmer;
@class RFBConnection;

//! Path to the file that server settings are stored in.
#define kServersFilePath @"/var/root/Library/Preferences/vnsea_servers.plist"

#define kPrefsFilePath @"/var/root/Library/Preferences/vnsea_prefs.plist"

//! The top level dictionary key containing the array of server dictionaries in the
//! server settings file.
#define kServerArrayKey @"servers"
#define kPrefsArrayKey @"prefs"

//! URL for a plist that contains information about the latest version
//! of the application, for use by Shimmer.
#define kUpdateURL @"http://www.manyetas.com/creed/iphone/shimmer/vnsea.plist"

//! If a connection attempt takes longer than this amount of time, then
//! an alert is displayed telling the user what is going on.
#define kConnectionAlertTime (0.6f)

//! Amount of time in seconds to let the run loop run while waiting for
//! a connection to be made.
#define kConnectWaitRunLoopTime (0.1f)

//! Status bar animation modes.
enum
{
	kUIStatusBarFadeAnimation = 0,
	kUIStatusBarBottomToTopAnimation = 1,
	kUIStatusBarTopToBottomAnimation = 2
};

/*!
 * @brief Main application class for the VNC viewer program.
 *
 * This class manages the high level interaction with the user. It
 * switches between the server list, server editor, and connection views
 * as necessary. It also handles reading and writing the saved list
 * of servers to and from media.
 */
@interface VnseaApp : UIApplication
{
	//! @name Views
	//@{
	UIWindow * _window;
	UIView * _mainView;
	UITransitionView * _transView;
	VNCView * _vncView;
	VNCServerListView * _serversView;
	VNCServerInfoView * _serverEditorView;
	VNCPrefsView *_prefsView;
	//@}
	
	Profile * _defaultProfile;	//!< Our single profile object, reused for every connection.
	int _editingIndex, _serverConnectingIndex;	//!< Index of the server currently being edited.
	RFBConnection * _connection;	//!< The active connection object.
	NSConditionLock * _connectLock;	//!< Lock used for thread synchronisation during connect.
	BOOL _didOpenConnection;	//!< YES if the connection was opened successfully.
	NSString * _connectError;	//!< Error message from attempting to open a connection.
	BOOL _closingConnection;	//!< True if the connection is intentionally being closed.
	UIAlertSheet * _connectAlert;	//!< Sheet saying we're connecting to a server.
	int _lastAlertButtonIndexClicked;
	NSTimer *_statusDoubleTapTimer;
}

//! @name Server list I/O
//@{
- (NSArray *)loadServers;
- (void)saveServers:(NSArray *)theServers;
//@}

//! @name Preferences
//@{
- (void)finishedEditingPreferences;
- (void)displayPrefs;
//@}

//! @brief Called when the first frame from RFB protocol arrives.
- (void)gotFirstFullScreenTransitionNow;

- (void)_endedEditing;
- (BOOL)_shouldEndEditing;

//! @name List and editor delegate messages
//@{
- (void)serverSelected:(int)serverIndex;
- (void)editServer:(int)serverIndex;
- (void)addNewServer;
- (void)finishedEditingServer:(NSDictionary *)serverInfo;
- (void)serverValidationFailed:(NSString *)pnsBodyText;
- (void)deleteServer;
//@}

//! @brief Creates a dictionary populated with default server values.
- (NSDictionary *)defaultServerInfo;

//! @name Shimmer auto-update support
//@{
- (void)checkForUpdate:(id)unused;
//@}

//! @brief Show the about alert.
- (void)displayAbout;

//! @name Connection methods
//@{
- (void)waitForConnection:(RFBConnection *)connection;
- (void)connectToServer:(RFBConnection *)connection;
- (void)closeConnection;
//@}

@end

#endif // _VnseaApp_h_
