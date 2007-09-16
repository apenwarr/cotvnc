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

//! @brief Event type flags
//enum _event_types
//{
//	kButtonDown = 1,		//!< Finger presses down on button
//	kButtonUnreleased = 32, //!< User moves finger off the button
//	kButtonUp = 64			//!< Finger releases button with it selected
//};

//! @brief Device orientation constants.
enum _device_orient
{
	kUIDeviceOrientationNormal = 1,
	kUIDeviceOrientationUpsideDown = 2,
	kUIDeviceOrientationTurnedLeft = 3,
	kUIDeviceOrientationTurnedRight = 4
};

/*!
 * @brief Main application class for the VNC viewer program.
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
}

- (NSArray *)loadServers;
- (void)saveServers:(NSArray *)theServers;

- (void)serverSelected:(int)serverIndex;
- (void)editServer:(int)serverIndex;
- (void)addNewServer;
- (void)finishedEditingServer:(NSDictionary *)serverInfo;
- (void)deleteServer;

- (NSDictionary *)defaultServerInfo;

//- (void)checkForUpdate;

- (void)displayAbout;

@end

#endif // _VnseaApp_h_
