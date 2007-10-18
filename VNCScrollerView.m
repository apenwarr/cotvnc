//
//  VNCScrollerView.m
//  vnsea
//
//  Created by Chris Reed on 10/16/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "VNCScrollerView.h"

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

- (BOOL)canBecomeFirstResponder
{
	return YES;
}

- (void)handleTapTimer:(NSTimer *)timer
{
	_inRemoteAction = true;
	
	// Send the original event.
	GSEventRef theEvent = (GSEventRef)[timer userInfo];
//	NSLog(@"tapTimer:%@", theEvent);
	[_eventFilter mouseDown:theEvent];
	
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
			[_eventFilter mouseUp:theEvent];
			_inRemoteAction = false;
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
		[_eventFilter mouseUp:theEvent];
		_inRemoteAction = false;
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

- (void)keyDown:(GSEventRef)theEvent
{
	NSLog(@"keyDown:%@", theEvent);
}

- (void)keyUp:(GSEventRef)theEvent
{
	NSLog(@"keyUp:%@", theEvent);
}

@end
