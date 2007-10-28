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
//	int count = GSEventGetClickCount(theEvent);
//	NSLog(@"mouseDown:%c:%d", isChording ? 'y' : 'n', count);
	
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

- (void)mouseDragged:(GSEventRef)theEvent
{
	// Do nothing if there is no connection.
	if (!_eventFilter)
	{
		return;
	}
	
//	bool isChording = GSEventIsChordingHandEvent(theEvent);	
//	NSLog(@"mouseDragged:%c", isChording ? 'y' : 'n');
	
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
