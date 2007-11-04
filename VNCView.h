//
//  VNCView.h
//  Vnsea
//
//  Created by Chris Reed on 9/5/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <UIKit/CDStructures.h>
#import <UIKit/UIWindow.h>
#import <UIKit/UIView-Hierarchy.h>
#import <UIKit/UIHardware.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIApplication.h>
#import <UIKit/UINavBarButton.h>
#import <UIKit/UIPushButton.h>
#import <UIKit/UIKeyboard.h>
#import <UIKit/UIKeyboardInput.h>
#import <UIKit/UISegmentedControl.h>
#import <CoreGraphics/CoreGraphics.h>
#import "RFBConnection.h"
#import "EventFilter.h"
#import "FrameBuffer.h"
#import "RFBViewProtocol.h"
#import "VNCContentView.h"
#import "VNCScrollerView.h"
#import "VNCPopupWindow.h"

/*!
 * @brief Main view to display and control the remote computer.
 *
 * This view class handles everything related to showing the remote display
 * and interacting with it. It is tightly coupled with the RFBConnection
 * instance and is its delegate. The actual drawing of the framebuffer
 * is done by the VNCContentView that the child of the scroller view.
 * A number of method invocations are forwarded to the content
 * view rather than be implemented directly by this class.
 *
 * The view hierarchy looks like this:
 * 
 *		VNCView -> VNCScrollerView -> VNCContentView
 *
 * 
 */

typedef enum 
{
        kScaleFitNone = 0,
        kScaleFitWidth = 1,
        kScaleFitHeight = 2, 
        kScaleFitWhole = 3
} scaleSpecialTypes;


@interface VNCView : UIView <RFBViewProtocol>
{
	id _delegate;
    RFBConnection * _connection;	//!< The connection object, nil if not currently connected.
	EventFilter * _filter;			//!< Event filter for the current connection.
	VNCScrollerView * _scroller;	//!< Scroller subview.
	VNCContentView * _screenView;	//!< Child content view that draws the framebuffer.
	UINavBarButton * _keyboardButton;	//
	UINavBarButton * _keyboardButton1;	//
	UINavBarButton * _shiftButton;
	UINavBarButton * _commandButton;
	UINavBarButton * _optionButton;
	UINavBarButton * _controlButton;
	UINavBarButton * _rightMouseButton;
	UINavBarButton * _exitButton;	//
	UINavBarButton * _fitWidthButton, * _fitHeightButton;
	UISegmentedControl * _widthHeightFullSegment;
	id _keyboardView;
	id _controlsView;
	bool _areControlsVisible;
	bool _isKeyboardVisible;
	CGSize _vncScreenSize, _ipodScreenSize;
	scaleSpecialTypes _scaleState;
}

//! @name Delegate
//@{
- (id)delegate;
- (void)setDelegate:(id)theDelegate;
//@}


//! @name Controls and keyboard
//@{
- (bool)areControlsVisible;
- (void)showControls:(bool)show;
- (void)toggleControls;
- (void)toggleKeyboard:(id)sender;
- (void)toggleFitWidthHeight:(id)sender;
- (void)closeConnection:(id)sender;
- (void)toggleRightMouse:(id)sender;
- (void)toggleModifierKey:(id)sender;
//@}

//! @name RFBViewProtocol
//@{
- (void)setRemoteDisplaySize:(CGSize)remoteSize;
- (void)setFrameBuffer:(id)aBuffer;
- (void)setConnection:(RFBConnection *)connection;
- (RFBConnection *)connection;
- (void)displayFromBuffer:(CGRect)aRect;
- (void)drawRectList:(id)aList;
//@}

- (void)mouseUp:(struct __GSEvent *)fp8;

- (float)orientationDegree;
- (void)setOrientation:(UIHardwareOrientation)wOrientation bForce:(int)bForce;
- (void)pinnedPTViewChange:(CGPoint)ptPinned fScale:(float)fScale wOrientationState:(UIHardwareOrientation)wOrientationState bForce:(BOOL)bForce;
- (void)setScalePercent:(float)x;
- (float)getScalePercent;
- (CGRect)getFrame;
- (UIHardwareOrientation)getOrientationState;
- (CGPoint)getIPodScreenPoint:(CGRect)r bounds:(CGRect)bounds;
- (void)setScaleState: (scaleSpecialTypes)wState;
- (scaleSpecialTypes)getScaleState;

- (BOOL)showMouseTracks;

@end

@interface VNCView (DelegateMethods)

- (void)closeConnection;
- (BOOL)showMouseTracks;

@end


