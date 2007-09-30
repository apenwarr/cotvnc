//
//  VNCView.m
//  vnsea
//
//  Created by Chris Reed on 9/5/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "VNCView.h"
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>
#import <UIKit/UITextView.h>
#import <UIKit/UITouchDiagnosticsLayer.h>
#import <UIKit/UINavBarButton.h>
#import <UIKit/UIView-Gestures.h>
#import <GraphicsServices/GraphicsServices.h>
#import "RectangleList.h"

//! Number of seconds to wait before sending a mouse down, during which we
//! check to see if the user is really wanting to scroll.
#define kSendMouseDownDelay (0.185)

@implementation VNCView

- (id)initWithFrame:(CGRect)frame
{
	if ([super initWithFrame:frame])
	{
		CGRect subframe = frame;
		
		// Create screen view.
		subframe.origin = CGPointMake(0, 0);
		_screenView = [[VNCContentView alloc] initWithFrame:subframe];
		[self addSubview:_screenView];
		
		// Configure this view.
		[self setScrollingEnabled:YES];
		[self setShowScrollerIndicators:YES];
		[self setAdjustForContentSizeChange:YES];// why isn't this working?
		[self setAllowsRubberBanding:NO];
		[self setAllowsFourWayRubberBanding:NO];
		[self setThumbDetectionEnabled:YES];
		[self setDelegate:self];
	}
	
	return self;
}

- (void)dealloc
{
    [super dealloc];
}

/*
- (void)gestureEnded:(GSEventRef)event
{
	NSLog(@"gestureEnded:%@", event);
}

- (void)gestureStarted:(GSEventRef)event
{
	NSLog(@"gestureStarted:%@", event);
}

- (void)gestureChanged:(GSEventRef)event
{
	NSLog(@"gestureChanged:%@", event);
}
*/

- (RFBConnection *)connection;
{
	return _connection;
}

- (void)setFrameBuffer:(id)aBuffer;
{
	[_screenView setFrameBuffer:aBuffer];
}

- (void)setConnection:(RFBConnection *)connection
{
    _connection = connection;
	if (_connection)
	{
		_eventFilter = [_connection eventFilter];
	}
	else
	{
		_eventFilter = nil;
		[_screenView setFrameBuffer:nil];
	}
}

- (void)setRemoteDisplaySize:(CGSize)remoteSize
{
	[_screenView setRemoteDisplaySize:remoteSize];
	
	// Reset our scroller's content size.
	[self setContentSize:remoteSize];
}

- (void)displayFromBuffer:(CGRect)aRect
{
	[_screenView displayFromBuffer:aRect];
}

- (void)drawRectList:(id)aList
{
	NSLog(@"VNCView:drawRectList:%@", aList);
	
	// XXX this may not be cool!
//    [self lockFocus];
//    [aList drawRectsInRect:[self bounds]];
//    [self unlockFocus];
}

- (CGRect)contentRect
{
	return [_screenView bounds];
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
	bool isChording = GSEventIsChordingHandEvent(theEvent);	
//	int count = GSEventGetClickCount(theEvent);
//	NSLog(@"mouseDown:%c:%d", isChording ? 'y' : 'n', count);
	
	if (isChording)
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

/*
- (void)rightMouseDown:(GSEventRef)theEvent
{  [_eventFilter rightMouseDown: theEvent];  }

- (void)otherMouseDown:(GSEventRef)theEvent
{  [_eventFilter otherMouseDown: theEvent];  }


- (void)rightMouseUp:(GSEventRef)theEvent
{  [_eventFilter rightMouseUp: theEvent];  }

- (void)otherMouseUp:(GSEventRef)theEvent
{  [_eventFilter otherMouseUp: theEvent];  }

- (void)mouseMoved:(GSEventRef)theEvent
{  [_eventFilter mouseMoved: theEvent];  }


- (void)rightMouseDragged:(GSEventRef)theEvent
{  [_eventFilter rightMouseDragged: theEvent];  }

- (void)otherMouseDragged:(GSEventRef)theEvent
{  [_eventFilter otherMouseDragged: theEvent];  }

// jason - this doesn't work, I think because the server I'm testing against doesn't support
// rfbButton4Mask and rfbButton5Mask (8 & 16).  They're not a part of rfbProto, so that ain't
// too surprising.
// 
// Later note - works fine now, maybe more servers have added support since I wrote the original
// comment
- (void)scrollWheel:(GSEventRef)theEvent
{  [_eventFilter scrollWheel: theEvent];  }

- (void)keyDown:(GSEventRef)theEvent
{  [_eventFilter keyDown: theEvent];  }

- (void)keyUp:(GSEventRef)theEvent
{  [_eventFilter keyUp: theEvent];  }

- (void)flagsChanged:(GSEventRef)theEvent
{  [_eventFilter flagsChanged: theEvent];  }
*/
/*
//These Methods track delegate calls made to the application
- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector 
{
	NSLog(@"Requested method for selector: %@", NSStringFromSelector(selector));
	return [super methodSignatureForSelector:selector];
}

- (BOOL)respondsToSelector:(SEL)aSelector 
{
	NSLog(@"Request for selector: %@", NSStringFromSelector(aSelector));
	return [super respondsToSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation 
{
	NSLog(@"Called from: %@", NSStringFromSelector([anInvocation selector]));
	[super forwardInvocation:anInvocation];
}
*/
@end
