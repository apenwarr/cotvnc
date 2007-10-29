//
//  VNCScrollerView.m
//  vnsea
//
//  Created by Chris Reed on 10/16/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "VNCScrollerView.h"
#import "VNCView.h"

//! Number of seconds to wait before sending a mouse down, during which we
//! check to see if the user is really wanting to scroll.
#define kSendMouseDownDelay (0.185)

@implementation VNCScrollerView

- (void)setEventFilter:(EventFilter *)filter
{
	_eventFilter = filter;
}

- (BOOL)canHandleGestures
{
  return NO;
}

- (void)doubleTap
{
	NSLog(@"Double Tap");
}

- (void)gestureStarted:(GSEvent *)event
{
	NSLog(@"Gesture Started");
}

- (void)gestureChanged:(GSEvent *)event
{
	CGRect r = GSEventGetLocationInWindow(event);
        CGRect cr = [self convertRect:r fromView:nil];
	NSLog(@"Gesture Changed %f %f,  %f %f", cr.origin.x, cr.origin.y, cr.size.width, cr.size.height);

	CGPoint pt1 = GSEventGetInnerMostPathPosition(event);
	CGPoint pt2 = GSEventGetOuterMostPathPosition(event);
	NSLog(@"PT1 %f %f, PT2 %f %f", pt1.x, pt1.y, pt2.x, pt2.y);
	
}

- (void) setVNCView:(id)view
{
	_vncView = view;
}

- (void)gestureEnded:(GSEvent *)event
{
	NSLog(@"Gesture Ended");
}

- (void)setViewOnly:(bool)isViewOnly
{
	_viewOnly = isViewOnly;
}

- (bool)useRightMouse
{
	return _useRightMouse;
}

- (void)setUseRightMouse:(bool)useRight
{
	_useRightMouse = useRight;
}

- (BOOL)canBecomeFirstResponder
{
	return YES;
}

- (void)sendMouseDown:(GSEventRef)theEvent
{
	if (_useRightMouse)
	{
		[_eventFilter rightMouseDown:theEvent];
		_inRightMouse = YES;
		
		[[self superview] toggleRightMouse:self];
	}
	else
	{
		[_eventFilter mouseDown:theEvent];
	}
}

- (void)sendMouseUp:(GSEventRef)theEvent
{
	// Need to send the corresponding mouse up, regardless the current
	// use right mouse state.
	if (_inRightMouse)
	{
		[_eventFilter rightMouseUp:theEvent];
		_inRightMouse = NO;
	}
	else
	{
		[_eventFilter mouseUp:theEvent];
	}
}

- (void)handleTapTimer:(NSTimer *)timer
{
	_inRemoteAction = true;
	
	// Send the original event.
	GSEventRef theEvent = (GSEventRef)[timer userInfo];
//	NSLog(@"tapTimer:%@", theEvent);
	
	[self sendMouseDown:theEvent];
	
	// The event is no longer needed.
	CFRelease(theEvent);
	
	_tapTimer = nil;
}

- (void)mouseDown:(GSEventRef)theEvent
{
	// Do nothing if there is no connection.
	if (!_eventFilter)
	{
		return;
	}
	
	bool isChording = GSEventIsChordingHandEvent(theEvent);	
	int count = GSEventGetClickCount(theEvent);
	NSLog(@"mouseDown:%c:%d", isChording ? 'y' : 'n', count);

	if (isChording && _viewOnly)
	{	
		CGPoint pt1 = GSEventGetInnerMostPathPosition(theEvent);
		CGPoint pt2 = GSEventGetOuterMostPathPosition(theEvent);

		_fDistanceStart = sqrt((pt2.x-pt1.x)*(pt2.x-pt1.x) + (pt2.y - pt1.y) * (pt2.y - pt2.y));
		_fDistancePrev = _fDistanceStart;

		return;
	}

	
	if (isChording || _viewOnly)
	{
		// If the timer exists, it means we haven't yet sent the single finger mouse
		// down. Kill the timer so that the event is never sent.
		if (_tapTimer)
		{
//			NSLog(@"killed tap timer");
			[_tapTimer invalidate];
			_tapTimer = nil;
		}
		
		// Need to send a mouse up when switching from remote mouse to scrolling.
		// This assumes that _inRemoteAction will only ever be true after a mouse
		// down and before a mouse up.
		if (_inRemoteAction)
		{
			[self sendMouseUp:theEvent];
			_inRemoteAction = NO;
		}
		
		// Let the superclass handle scrolling.
		[super mouseDown:theEvent];
	}
	else
	{
		// Keep this event around for a bit.
		CFRetain(theEvent);
		
		// We don't want to send the mouse down event quite yet, because we
		// need to wait to see if this is really a chording event for scrolling.
		// So create a timer that when it fires will send the original event.
		// If a chording mouse down happens before the timer fires, it will be
		// killed.
		_tapTimer = [NSTimer scheduledTimerWithTimeInterval:kSendMouseDownDelay target:self selector:@selector(handleTapTimer:) userInfo:(id)theEvent repeats:NO];
	}
}

- (void)mouseUp:(GSEventRef)theEvent
{
	// Do nothing if there is no connection.
	if (!_eventFilter)
	{
		return;
	}
	
//	bool isChording = GSEventIsChordingHandEvent(theEvent);
//	NSLog(@"mouseUp:%c", isChording ? 'y' : 'n');
	
	if (_tapTimer)
	{
		[_tapTimer fire];
	}

	if (_inRemoteAction)
	{
		[self sendMouseUp:theEvent];
		_inRemoteAction = NO;
	}
	else
	{
		[super mouseUp:theEvent];
	}
}

- (void)pinnedPTViewChange:(CGPoint)ptPinned fScale:(float)fScale wOrientationState:(UIHardwareOrientation)wOrientationState bForce:(BOOL)bForce
{
	VNCView *vncView = _vncView;

	CGRect r = CGRectMake(ptPinned.x, ptPinned.y, 1,1);
	CGPoint ptVNCBefore = [_eventFilter getVNCScreenPoint: r];
	r.origin = ptVNCBefore;
	CGRect bounds = [self bounds];
	CGPoint ptIPodBefore = [vncView getIPodScreenPoint: r bounds: bounds];
	CGPoint ptLeftTop = bounds.origin;
	
	NSLog(@"iPodScreen Point (160, 240) %f,%f", ptIPodBefore.x, ptIPodBefore.y);

	[vncView setScalePercent: fScale];
	[vncView setOrientation:wOrientationState bForce:bForce];
	r.origin = ptVNCBefore;
	CGPoint ptIPodAfter = [vncView getIPodScreenPoint: r bounds: bounds];
	NSLog(@"IPod After %f,%f", ptIPodAfter.x, ptIPodAfter.y);
	NSLog(@"");
	ptLeftTop.x = ptLeftTop.x + (ptIPodAfter.x - ptIPodBefore.x);
	ptLeftTop.y = ptLeftTop.y + (ptIPodAfter.y - ptIPodBefore.y);
	[self scrollPointVisibleAtTopLeft: ptLeftTop];
}


- (void)mouseDragged:(GSEventRef)theEvent
{
	// Do nothing if there is no connection.
	if (!_eventFilter)
	{
		return;
	}
	
	bool isChording = GSEventIsChordingHandEvent(theEvent);	

	if (isChording && _viewOnly)
	{	
		CGPoint pt1 = GSEventGetInnerMostPathPosition(theEvent), pt2 = GSEventGetOuterMostPathPosition(theEvent);
		float fDistance = sqrt((pt2.x-pt1.x)*(pt2.x-pt1.x) + (pt2.y - pt1.y) * (pt2.y - pt2.y));
		float fHowFar = fDistance - _fDistancePrev;
		CGPoint ptCenter = CGPointMake((pt1.x+pt2.x) / 2, (pt1.y+pt2.y) / 2);

		if (abs(fHowFar) > 3)
		{
			VNCView *vncView = _vncView;
			
			[self pinnedPTViewChange:ptCenter fScale:[vncView getScalePercent]+(.0025 * fHowFar) wOrientationState:[vncView getOrientationState] bForce:true];
			_fDistancePrev = fDistance;
		}

		return;
	}

	
	if (_tapTimer)
	{
		[_tapTimer fire];
	}

	if (_inRemoteAction)
	{
		[_eventFilter mouseDragged:theEvent];
	}
	else
	{
		[super mouseDragged:theEvent];
	}
}

@end
