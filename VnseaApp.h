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

@class Profile;
@class Shimmer;
@class RFBConnection;

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
	UIWindow * _window;
	UIView * _mainView;
	UITransitionView * _transView;
	UIScroller * _vncScroller;
	VNCView * _vncView;
	Profile * _defaultProfile;
	VNCServerListView * _serversView;
	VNCServerInfoView * _serverEditorView;
	int _editingIndex;	//!< Index of the server currently being edited.
	RFBConnection * _connection;
	NSConditionLock * _connectLock;
	BOOL _didOpenConnection;	//!< YES if the connection was opened successfully.
	NSString * _connectError;	//!< Error message from attempting to open a connection.
	BOOL _closingConnection;	//!< True if the connection is intentionally being closed.
	UIAlertSheet * _connectAlert;	//!< Sheet saying we're connecting to a server.
}

//! @name Server list I/O
//@{
- (NSArray *)loadServers;
- (void)saveServers:(NSArray *)theServers;
//@}

//! @name List and editor delegate messages
//@{
- (void)serverSelected:(int)serverIndex;
- (void)editServer:(int)serverIndex;
- (void)addNewServer;
- (void)finishedEditingServer:(NSDictionary *)serverInfo;
- (void)deleteServer;
//@}

//! @brief Creates a dictionary populated with default server values.
- (NSDictionary *)defaultServerInfo;

//! @name Shimmer auto-update support
//@{
- (void)checkForUpdate:(id)unused;
- (void)doUpdate:(Shimmer *)shimmer;
//@}

//! @brief Show the about alert.
- (void)displayAbout;

//! @name Connection methods
//@{
- (void)waitForConnection:(RFBConnection *)connection;
- (void)connectToServer:(RFBConnection *)connection;
//@}

@end

#endif // _VnseaApp_h_
