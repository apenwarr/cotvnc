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
#import "VNCBackgroundView.h"

typedef enum
{
	kScaleFitNone = 0,
	kScaleFitWidth = 1,
	kScaleFitHeight = 2, 
	kScaleFitWhole = 3
} scaleSpecialTypes;

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
@interface VNCView : UIView <RFBViewProtocol>
{
	id _delegate;
    RFBConnection * _connection;	//!< The connection object, nil if not currently connected.
	EventFilter * _filter;			//!< Event filter for the current connection.
	VNCScrollerView * _scroller;	//!< Scroller subview.
	VNCContentView * _screenView;	//!< Child content view that draws the framebuffer.
	VNCBackgroundView *_backgroundView;
	UINavBarButton * _keyboardButton;	//
	UINavBarButton * _shiftButton;
	UINavBarButton * _commandButton;
	UINavBarButton * _optionButton;
	UINavBarButton * _controlButton;
	UINavBarButton * _rightMouseButton;
	UINavBarButton * _exitButton;	//
	UINavBarButton *_helperFunctionButton;
	UIThreePartButton * _fitWidthButton;
	UIThreePartButton * _fitHeightButton;
	UIThreePartButton *_fitWholeButton;
	UIThreePartButton *_fitNoneButton;
	UISegmentedControl * _widthHeightFullSegment;
	id _keyboardView;
	id _controlsView;
	bool _areControlsVisible;
	bool _savedControlShowState;
	bool _isKeyboardVisible;
	CGSize _vncScreenSize;
	CGSize _ipodScreenSize;
	scaleSpecialTypes _scaleState;
	bool _isFirstDisplay;	//!< Did we have our first display from VNC protocol?
	CGPoint _ptStartupTopLeft;	//!< When we get our first display scroll to this point.
	NSString *_remoteComputerName;
}

//! @name Delegate
//@{
- (id)delegate;
- (void)setDelegate:(id)theDelegate;
//@}

- (bool)isFirstDisplay;

//! @name Controls and keyboard
//@{
- (bool)areControlsVisible;
- (void)showControls:(bool)show;
- (void)toggleControls;
- (void)toggleKeyboard:(id)sender;
- (void)toggleFitWidthHeight:(id)sender;
- (void)showHelperFunctions:(id)sender;
- (void)closeConnection:(id)sender;
- (void)toggleRightMouse:(id)sender;
- (void)toggleModifierKey:(id)sender;
- (void)enableControlsForViewOnly:(bool)isViewOnly;
//@}

//! @name RFBViewProtocol
//@{
- (void)setRemoteComputerName:(NSString *)name;
- (void)setRemoteDisplaySize:(CGSize)remoteSize;
- (void)setFrameBuffer:(id)aBuffer;
- (void)setConnection:(RFBConnection *)connection;
- (RFBConnection *)connection;
- (void)displayFromBuffer:(CGRect)aRect;
- (void)drawRectList:(id)aList;
//@}

- (id)scroller;

//! @name Orientation
//@{
- (float)orientationDegree;
- (void)setOrientation:(UIHardwareOrientation)wOrientation bForce:(int)bForce;
- (UIHardwareOrientation)getOrientationState;
//@}

//! @name Scaling
//@{
- (void)setScalePercent:(float)x;
- (float)getScalePercent;
- (void)setScaleState: (scaleSpecialTypes)wState;
- (scaleSpecialTypes)getScaleState;
//@}

- (void)changeViewPinnedToPoint:(CGPoint)ptPinned scale:(float)fScale orientation:(UIHardwareOrientation)wOrientationState force:(BOOL)bForce;
- (CGRect)getFrame;
- (CGPoint)getIPodScreenPoint:(CGRect)r bounds:(CGRect)bounds;

- (CGPoint)topLeftVisiblePt;
- (void)sendFunctionKeys:(id)sender;
- (void)sendTabKey:(id)sender;

- (BOOL)showMouseTracks;
- (CGRect)scrollerFrame;
- (void)setStartupTopLeftPt:(CGPoint)pt;

@end

@interface VNCView (DelegateMethods)

- (void)closeConnection;
- (BOOL)showMouseTracks;

@end


