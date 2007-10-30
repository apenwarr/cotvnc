//
//  VNCScrollerView.h
//  vnsea
//
//  Created by Chris Reed on 10/16/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventFilter.h"
#import "VNCPopupWindow.h"

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
	bool _viewOnly;			//!< Are we only watching the remote computer?
	float _fDistancePrev;
	float _fDistanceStart;
	id _vncView;
	bool _useRightMouse;	//!< Whether to send a right mouse event.
	bool _inRightMouse;		//!< True if the last mouse down was for the right button.
	bool _bZooming;
	VNCPopupWindow *_windowPopupScalePercent;
}

- (void)setEventFilter:(EventFilter *)filter;

- (void)setViewOnly:(bool)isViewOnly;
- (BOOL)canHandleGestures;
- (void)gestureStarted:(GSEvent *)event;
- (void)gestureChanged:(GSEvent *)event;
- (void)gestureEnded:(GSEvent *)event;
- (void)setVNCView:(id)view;
- (void)pinnedPTViewChange:(CGPoint)ptPinned fScale:(float)fScale wOrientationState:(UIHardwareOrientation)wOrientationState bForce:(BOOL)bForce;

- (bool)useRightMouse;
- (void)setUseRightMouse:(bool)useRight;

- (void)sendMouseDown:(GSEventRef)theEvent;
- (void)sendMouseUp:(GSEventRef)theEvent;

@end
