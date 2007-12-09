//
//  VNCScrollerView.h
//  vnsea
//
//  Created by Chris Reed on 10/16/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventFilter.h"

@class VNCMouseTracks;
@class VNCPopupWindow;
@class VNCView;

//! Types of Auto Scrollers when draging mouse and reaching edges
//! of screen
typedef enum {
	kAutoScrollerNone = 0,
	kAutoScrollerLeft = 1,
	kAutoScrollerRight = 2,
	kAutoScrollerUp = 4,
	kAutoScrollerDown = 8,
} AutoScrollerTypes;

#define LEFTRIGHT_AUTOSCROLL_BORDER 30
#define TOPBOTTOM_AUTOSCROLL_BORDER 30

/*!
 * @brief Subclass of UIScroller that modifies its behaviour.
 *
 * An instance of this class sits between the VNCView and the VNCContentView
 * that draws the screen content. Its job, aside from the obvious scrolling,
 * is to intercept finger events and either pass them to the EventFilter
 * or let the UIScroller superclass handle them. All single finger events
 * are passed to the superclass, while all chorded events are converted
 * to remote mouse events.
 */
@interface VNCScrollerView : UIScroller
{
	EventFilter * _eventFilter;		//!< Event generation and queue object.
	bool _inRemoteAction;			//!< Are we currently controlling the remote mouse?
	NSTimer * _tapTimer;	//!< Timer used to delay first mouse down.
	NSTimer *_scrollTimer;	//!<
	bool _viewOnly;			//!< Are we only watching the remote computer?
	float _fDistancePrev;
	float _fDistanceStart;
	VNCView *_vncView;
	bool _useRightMouse;	//!< Whether to send a right mouse event.
	bool _inRightMouse;		//!< True if the last mouse down was for the right button.
	bool _isZooming;			//!< True when we're in zooming mode versus panning mode.
	VNCPopupWindow * _windowPopupScalePercent;
	VNCMouseTracks * _windowPopupMouseDown;
	VNCMouseTracks * _windowPopupMouseUp;
	AutoScrollerTypes _currentAutoScrollerType;
	GSEventRef _autoLastDragEvent;
}

-(void)toggleViewOnly;

- (void)setEventFilter:(EventFilter *)filter;
- (void)cleanUpMouseTracks;

- (void)setViewOnly:(bool)isViewOnly;

- (BOOL)canHandleGestures;

- (void)setVNCView:(VNCView *)view;

- (void)changeViewPinnedToPoint:(CGPoint)ptPinned scale:(float)fScale orientation:(UIHardwareOrientation)wOrientationState force:(BOOL)bForce;
- (CGPoint)getIPodScreenPoint:(CGRect)r bounds:(CGRect)bounds;
- (void)checkForAutoscrollEvents:(GSEventRef) theEvent;

- (bool)useRightMouse;
- (void)setUseRightMouse:(bool)useRight;

- (void)sendMouseDown:(GSEventRef)theEvent;
- (void)sendMouseUp:(GSEventRef)theEvent;

// function called when mouse is dragging near any edge
- (void)handleScrollTimer:(NSTimer *)timer;

@end
