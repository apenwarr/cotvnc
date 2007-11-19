//
//  VNCScrollerView.m
//  vnsea
//
//  Created by Chris Reed on 10/16/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//  Modified by: Glenn Kreisel

#import "VNCScrollerView.h"
#import "VNCView.h"
#import "VNCMouseTracks.h"

//! Number of seconds to wait before sending a mouse down, during which we
//! check to see if the user is really wanting to scroll.
#define kSendMouseDownDelay (0.285)

#define kMinScale (0.10f)
#define kMaxScale (3.0f)

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

- (void)setVNCView:(VNCView *)view
{
	_vncView = view;
	_windowPopupScalePercent = nil;
	_windowPopupMouseDown = nil;
	_scrollTimer = nil;
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

- (void)cleanUpMouseTracks
{
	if (_windowPopupScalePercent != nil)
		{
		_bZooming = false;
		[_windowPopupScalePercent setHidden:true];
		[_windowPopupScalePercent release];
		_windowPopupScalePercent = nil;
		}
	if (_windowPopupMouseDown != nil)
	{
		[_windowPopupMouseDown hide];
		_windowPopupMouseDown = nil;
	}
	if (_windowPopupMouseUp != nil)
	{
		[_windowPopupMouseUp hide];
		_windowPopupMouseUp = nil;
	}
}


// Auto scroll function called by timer and mouse is on edges of device and dragging
// This also submits the original drag event so that the vnc server updates the mouse to the new location 
// under your finger
- (void)handleScrollTimer:(NSTimer *)timer
{
	int dxAutoScroll = 3, dyAutoScroll = 3;
	CGPoint ptLeftTop = [self bounds].origin;
	
	if (_currentAutoScrollerType & kAutoScrollerRight)
	{
		ptLeftTop.x += dxAutoScroll;
	}
	else if (_currentAutoScrollerType & kAutoScrollerLeft)
	{
		ptLeftTop.x -= dxAutoScroll;
	}
					
	if (_currentAutoScrollerType & kAutoScrollerUp)
	{
		ptLeftTop.y -= dyAutoScroll;
	}
	else if (_currentAutoScrollerType & kAutoScrollerDown)
	{
		ptLeftTop.y += dyAutoScroll;
	}
				
	[self scrollPointVisibleAtTopLeft: ptLeftTop];	
	[_eventFilter mouseDragged:_autoLastDragEvent];
}


- (void)handleTapTimer:(NSTimer *)timer
{
	_inRemoteAction = true;
	
	// Send the original event.
	GSEventRef theEvent = (GSEventRef)[timer userInfo];
//	NSLog(@"tapTimer:%@", theEvent);
	
	[self sendMouseDown:theEvent];
	
	// Do mouse tracks
	if ([_vncView showMouseTracks])
	{
		if (_windowPopupMouseDown != nil)
		{
			[_windowPopupMouseDown hide];
			_windowPopupMouseDown = nil;
		}
		CGPoint ptVNC = [_eventFilter getVNCScreenPoint: GSEventGetLocationInWindow(theEvent)];
	
		_windowPopupMouseDown = [[VNCMouseTracks alloc] initWithFrame: CGRectMake(ptVNC.x, ptVNC.y, 10, 10) style:kPopupStyleMouseDown scroller:self];	
		[_windowPopupMouseDown setTimer: 1.5f info:nil]; 
	}
	
	// The event is no longer needed.
	CFRelease(theEvent);
	
	[_tapTimer release];
	_tapTimer = nil;
}

- (void)mouseDown:(GSEventRef)theEvent
{
	// Do nothing if there is no connection.
	if (!_eventFilter)
	{
		return;
	}
	
	// if mousedown then we must not be in a drag event so reset Autoscroll during drag
	if (_scrollTimer != nil)
	{
		[_scrollTimer invalidate];
		[_scrollTimer release];
		_scrollTimer = nil;
		CFRelease(_autoLastDragEvent);
	}
	_currentAutoScrollerType = kAutoScrollerNone;
	
	bool isChording = GSEventIsChordingHandEvent(theEvent);	
//	int count = GSEventGetClickCount(theEvent);
//	NSLog(@"mouseDown:%c:%d", isChording ? 'y' : 'n', count);

	if (isChording)
	{	
		CGPoint pt1 = GSEventGetInnerMostPathPosition(theEvent);
		CGPoint pt2 = GSEventGetOuterMostPathPosition(theEvent);

		_fDistanceStart = sqrt((pt2.x-pt1.x)*(pt2.x-pt1.x) + (pt2.y - pt1.y) * (pt2.y - pt2.y));
		_fDistancePrev = _fDistanceStart;
		if (_windowPopupScalePercent == nil)
		{
			CGPoint ptCenter = CGPointMake((pt1.x+pt2.x) / 2, (pt1.y+pt2.y) / 2);
			
			_windowPopupScalePercent = [[VNCPopupWindow alloc] initWithFrame: CGRectMake(0, 0, 60, 60) centered:true show:true orientation:[_vncView orientationDegree] style:kPopupStyleDrag];
			[_windowPopupScalePercent setCenterLocation: ptCenter]; 
			[_windowPopupScalePercent setTextPercent: [_vncView getScalePercent]];
			_bZooming = false;
		}
	}
	
	if (isChording || _viewOnly)
	{
		// If the timer exists, it means we haven't yet sent the single finger mouse
		// down. Kill the timer so that the event is never sent.
		if (_tapTimer)
		{
//			NSLog(@"killed tap timer");
			[_tapTimer invalidate];
			[_tapTimer release];
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
		_tapTimer = [[NSTimer scheduledTimerWithTimeInterval:kSendMouseDownDelay target:self selector:@selector(handleTapTimer:) userInfo:(id)theEvent repeats:NO] retain];
	}
}

- (CGPoint)getIPodScreenPoint:(CGRect)r bounds:(CGRect)bounds
{
	return [_vncView getIPodScreenPoint: r bounds: bounds];
}

- (void)mouseUp:(GSEventRef)theEvent
{
	// Do nothing if there is no connection.
	if (_windowPopupScalePercent != nil)
	{
		_bZooming = false;
		[_windowPopupScalePercent setHidden:true];
		[_windowPopupScalePercent release];
		_windowPopupScalePercent = nil;
	}
	
	if (!_eventFilter)
	{
		return;
	}	
	
	// Autoscroll during drag must be over
	if (_scrollTimer != nil)
	{
		[_scrollTimer invalidate];
		_scrollTimer = nil;
		CFRelease(_autoLastDragEvent);
	}
	
	if (_tapTimer)
	{
		[_tapTimer fire];
	}

	if (_inRemoteAction)
	{
		if ([_vncView showMouseTracks])
		{
			if (_windowPopupMouseUp != nil)
			{
				[_windowPopupMouseUp hide];
				_windowPopupMouseUp = nil;
			}
			CGPoint ptVNC = [_eventFilter getVNCScreenPoint: GSEventGetLocationInWindow(theEvent)];

			_windowPopupMouseUp = [[VNCMouseTracks alloc] initWithFrame: CGRectMake(ptVNC.x,ptVNC.y,10,10) style:kPopupStyleMouseUp scroller:self];			
	//		NSLog(@"Setting Timer on Popup");
			[_windowPopupMouseUp setTimer: 1.5f info:nil]; 
		}

		[self sendMouseUp:theEvent];
		_inRemoteAction = NO;
	}
	else
	{
		[super mouseUp:theEvent];
	}
}

- (void)changeViewPinnedToPoint:(CGPoint)ptPinned scale:(float)fScale orientation:(UIHardwareOrientation)wOrientationState force:(BOOL)bForce
{
	CGRect r = CGRectMake(ptPinned.x, ptPinned.y, 1,1);
	CGPoint ptVNCBefore = [_eventFilter getVNCScreenPoint: r];
	r.origin = ptVNCBefore;
	CGRect bounds = [self bounds];
	CGPoint ptIPodBefore = [_vncView getIPodScreenPoint: r bounds: bounds];
	CGPoint ptLeftTop = bounds.origin;
	bool bOrientationChange;
	
//	NSLog(@"iPodScreen Point %f,%f", ptIPodBefore.x, ptIPodBefore.y);

	[_vncView setScalePercent: fScale];
	bOrientationChange = [_vncView getOrientationState] != wOrientationState;
	[_vncView setOrientation:wOrientationState bForce:bForce];
	r.origin = ptVNCBefore;
	CGPoint ptIPodAfter = [_vncView getIPodScreenPoint: r bounds: bounds];
//	NSLog(@"IPod After %f,%f", ptIPodAfter.x, ptIPodAfter.y);
//	NSLog(@"");
	ptLeftTop.x +=(ptIPodAfter.x - ptIPodBefore.x);
	ptLeftTop.y += (ptIPodAfter.y - ptIPodBefore.y);
	
//  Try to prevent orientation change from making the screen scroll too far
	if (bOrientationChange)
	{
		ptLeftTop.x = MAX(0, ptLeftTop.x);
		ptLeftTop.y = MAX(0, ptLeftTop.y);
//		if (ptLeftTop.x + [_scroller frame].size.width > [_scroller bounds].size.width)
//			{
//			NSLog(@"Scroller set too far");
//			}
	}
//	NSLog(@"topleft %f,%f", ptLeftTop.x, ptLeftTop.y);
	[self scrollPointVisibleAtTopLeft: ptLeftTop];
	
// Make sure the MouseTracks get updated to the new Scale / Orientation
	if (_windowPopupMouseDown != nil)
	{
		[_windowPopupMouseDown zoomOrientationChange];
	}
	if (_windowPopupMouseUp != nil)
	{
		[_windowPopupMouseUp zoomOrientationChange];
	}
}


// Determines if we need to autoscroll while drag or not
// starts timer if ready to autoscroll
- (void)checkForAutoscrollEvents:(GSEventRef) theEvent
{
	CGPoint ptDrag = GSEventGetLocationInWindow(theEvent).origin;
	CGRect rcFrame = [self frame];
	AutoScrollerTypes newAutoScroller = kAutoScrollerNone;
	
	if (ptDrag.x > (rcFrame.origin.x+rcFrame.size.width) - LEFTRIGHT_AUTOSCROLL_BORDER && ptDrag.x < (rcFrame.origin.x+rcFrame.size.width))
	{
		newAutoScroller = kAutoScrollerRight;
	}
	else if (ptDrag.x < LEFTRIGHT_AUTOSCROLL_BORDER && ptDrag.x >= 0)
	{
		newAutoScroller = kAutoScrollerLeft;
	}
		
	if (ptDrag.y < TOPBOTTOM_AUTOSCROLL_BORDER && ptDrag.y >= 0)
	{
		newAutoScroller |= kAutoScrollerUp;
	}
	else if (ptDrag.y > rcFrame.size.height - TOPBOTTOM_AUTOSCROLL_BORDER && ptDrag.y < rcFrame.size.height)
	{
		newAutoScroller |= kAutoScrollerDown;
	}
	
	if (newAutoScroller != _currentAutoScrollerType)
	{
		_currentAutoScrollerType = newAutoScroller;
		
		NSLog(@"In border Area %d", newAutoScroller);
		
		if (_scrollTimer != nil)
		{
			[_scrollTimer invalidate];
			[_scrollTimer release];
			_scrollTimer = nil;
			CFRelease(_autoLastDragEvent);
		}
		
		if (newAutoScroller != kAutoScrollerNone)
		{
			NSLog(@"Starting Timer");
			CFRetain(theEvent);
			_autoLastDragEvent = theEvent;
			_scrollTimer = [[NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(handleScrollTimer:) userInfo:nil repeats:YES] retain];
		}
	}
}

- (void)mouseDragged:(GSEventRef)theEvent
{
	// Do nothing if there is no connection.
	if (!_eventFilter)
	{
		return;
	}
	
	bool isChording = GSEventIsChordingHandEvent(theEvent);	

	if (isChording)
	{	
		CGPoint pt1 = GSEventGetInnerMostPathPosition(theEvent), pt2 = GSEventGetOuterMostPathPosition(theEvent);
		float fDistance = sqrt((pt2.x-pt1.x)*(pt2.x-pt1.x) + (pt2.y - pt1.y) * (pt2.y - pt2.y));
		float fHowFar = fDistance - _fDistancePrev;
		CGPoint ptCenter = CGPointMake((pt1.x+pt2.x) / 2, (pt1.y+pt2.y) / 2);

		if (abs(fHowFar) > (_viewOnly || _bZooming ? 3 : 20))
		{
			float fOldScale = [_vncView getScalePercent], fNewScale = fOldScale + (0.0025 * fHowFar);
			
			_bZooming = true;
			[_windowPopupScalePercent setStyleWindow: kPopupStyleScalePercent];
			if ((fNewScale > [_vncView scaleFitCurrentScreen: kScaleFitWhole] || (fNewScale > fOldScale)) && fNewScale < kMaxScale)
			{
				[_windowPopupScalePercent setTextPercent: fNewScale];
				[_windowPopupScalePercent setCenterLocation: ptCenter]; 
				
				[self changeViewPinnedToPoint:ptCenter scale:fNewScale orientation:[_vncView getOrientationState] force:true];
			}
			
			_fDistancePrev = fDistance;
			return;
		}
		else
		{
			[_windowPopupScalePercent setCenterLocation: ptCenter];
		}

			
		if (_viewOnly || _bZooming)
		{
			return;
		}
	}

	
	if (_tapTimer)
	{
		[_tapTimer fire];
	}

	if (_inRemoteAction)
	{
		[self checkForAutoscrollEvents: theEvent];
		[_eventFilter mouseDragged:theEvent];
	}
	else
	{
		[super mouseDragged:theEvent];
	}
}

@end
