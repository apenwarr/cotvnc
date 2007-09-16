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

@implementation VNCView

- (id)initWithFrame:(CGRect)frame
{
	if ([super initWithFrame:frame])
	{
		// Set the view's background color
		float whiteComponents[] = { 0.0f, 0.0f, 0.0f, 1.0f };
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		CGColorRef white = CGColorCreate(colorSpace, whiteComponents);
		CFRelease(colorSpace);
		
		[self setOpaque:YES];
		[self setBackgroundColor:white];
		[self setAlpha:1.0f];
		
		// Create screen view.
/*		_screenView = [[VNCContentView alloc] initWithFrame:frame];
		
		// Create scroller.
		_scroller = [[UIScroller alloc] initWithFrame: frame];
		[_scroller setScrollingEnabled:YES];
		[_scroller setShowScrollerIndicators:YES];
		[_scroller setAdjustForContentSizeChange:YES];// why isn't this working?
		[_scroller setAllowsRubberBanding:NO];
		[_scroller setAllowsFourWayRubberBanding:NO];
		[_scroller setThumbDetectionEnabled:YES];
	//	[_scroller setScrollerIndicatorStyle:1];
		[_scroller setDelegate:self];
		
		// Setup view hierarchy.
		[_scroller addSubview:_screenView];
		[self addSubview:_scroller];
		*/
		
		
		
//		[self setEnabledGestures:0xffffffff];
//		[self setGestureDelegate:self];
//		[self setTapDelegate:self];
		
//		NSLog(@"enabled gestures=%d", [self enabledGestures]);
		
		
//		[self startHeartbeat:@selector(heartbeat) inRunLoopMode:(NSString *)kCFRunLoopCommonModes];
	}
	
	return self;
}

- (void)dealloc
{
    [super dealloc];
}

/*
- (BOOL)canHandleGestures
{
	return YES;
}

- (void)gestureEnded:(GSEvent *)event
{
	NSLog(@"gestureEnded:%@", event);
}

- (void)gestureStarted:(GSEvent *)event
{
	NSLog(@"gestureStarted:%@", event);
}

- (void)gestureChanged:(GSEvent *)event
{
	NSLog(@"gestureChanged:%@", event);
}
*/

- (void)setFrameBuffer:(id)aBuffer;
{
//	[_screenView setFrameBuffer:aBuffer];
	NSLog(@"view::setbuf:%@", aBuffer);
    [_fbuf autorelease];
	if (aBuffer)
	{
		_fbuf = [aBuffer retain];
		
		CGRect f = [self frame];
		f.size = [aBuffer size];
		[self setFrame:f];
	}
	else
	{
		_fbuf = nil;
	}
}

- (void)setConnection:(RFBConnection *)connection
{
	NSLog(@"view:setconnect:%@", connection);
    _connection = connection;
	if (_connection)
	{
		_eventFilter = [_connection eventFilter];
		[_connection setDelegate:self];
	}
	else
	{
		_eventFilter = nil;
	}
}

- (RFBConnection *)connection;
{
	return _connection;
}

- (void)connection:(RFBConnection *)connection hasTerminatedWithReason:(NSString *)reason
{
	NSArray * buttons = [NSArray arrayWithObject:@"OK"];
	
	UIAlertSheet * hotSheet = [[UIAlertSheet alloc]
				initWithTitle:@"Connection terminated"
				buttons:buttons
				defaultButtonIndex:0
				delegate:self
				context:self];
	
	[hotSheet setBodyText:reason];
	[hotSheet setDimsBackground:YES];
	[hotSheet _slideSheetOut:YES];
	[hotSheet setRunsModal:YES];
	[hotSheet setShowsOverSpringBoardAlerts:NO];
	
//	[hotSheet presentSheetToAboveView:self];
	[hotSheet popupAlertAnimated:YES];
}

- (void)alertSheet:(id)sheet buttonClicked:(int)buttonIndex
{  
	[sheet dismissAnimated:YES];
	[sheet release];
}

- (void)setRemoteDisplaySize:(CGSize)remoteSize
{
//	[_screenView setRemoteDisplaySize:remoteSize];
	
	// Reset our scroller's content size.
//	[_scroller setContentSize:remoteSize];
	
	NSLog(@"view:setting size");

	CGRect frame = [self bounds];
	frame.size = remoteSize;
	[self setBounds:frame];
	
	// Set our transformation matrix so that we're inverted top to bottom.
	// This accounts for the bitmap being drawn inverted.
	// XXX this should be fixed by rendering the bitmap correctly
	CGAffineTransform matrix;
	matrix = CGAffineTransformMakeScale(1.0f, -1.0f);
	
	[self setTransform:matrix];
	
	// Reset our scroller's content size.
	[[self superview] setContentSize:remoteSize];
	NSLog(@"view:done setting size");
}

- (void)drawRect:(CGRect)destRect
{
//	NSLog(@"drawRect{%f,%f,%f,%f}", destRect.origin.x, destRect.origin.y, destRect.size.width, destRect.size.height);
	
    CGRect b = [self bounds];
    CGRect r = destRect;

    r.origin.y = b.size.height - CGRectGetMaxY(r);
    [_fbuf drawRect:r at:destRect.origin];
    [_connection queueUpdateRequest];
}

- (void)displayFromBuffer:(CGRect)aRect
{
//	[_screenView displayFromBuffer:aRect];
	
    CGRect b = [self bounds];
    CGRect r = aRect;

    r.origin.y = b.size.height - CGRectGetMaxY(r);
    [self setNeedsDisplayInRect:r];
}

- (void)drawRectList:(id)aList
{
	NSLog(@"VNCView:drawRectList:%@", aList);
	// XXX this may not be cool!
//    [self lockFocus];
//    [aList drawRectsInRect:[self bounds]];
//    [self unlockFocus];
}

/*
- (void)mouseDown:(GSEvent *)theEvent
{
	NSLog(@"mouseDown:%@", theEvent);
	NSLog(@"filter=%@", _eventFilter);
	[_eventFilter mouseDown: theEvent];
}

- (void)mouseUp:(GSEvent *)theEvent
{
	NSLog(@"mouseUp:%@", theEvent);
	[_eventFilter mouseUp: theEvent];
}
*/

//- (void)mouseDragged:(GSEvent *)theEvent
//{
//	NSLog(@"mouseDragged:%@", theEvent);
//	[_eventFilter mouseDragged: theEvent];
//}

/*
- (void)rightMouseDown:(GSEvent *)theEvent
{  [_eventFilter rightMouseDown: theEvent];  }

- (void)otherMouseDown:(GSEvent *)theEvent
{  [_eventFilter otherMouseDown: theEvent];  }


- (void)rightMouseUp:(GSEvent *)theEvent
{  [_eventFilter rightMouseUp: theEvent];  }

- (void)otherMouseUp:(GSEvent *)theEvent
{  [_eventFilter otherMouseUp: theEvent];  }

//- (void)mouseEntered:(GSEvent *)theEvent
//{  [[self window] setAcceptsMouseMovedEvents: YES];  }
//
//- (void)mouseExited:(GSEvent *)theEvent
//{  [[self window] setAcceptsMouseMovedEvents: NO];  }

- (void)mouseMoved:(GSEvent *)theEvent
{  [_eventFilter mouseMoved: theEvent];  }


- (void)rightMouseDragged:(GSEvent *)theEvent
{  [_eventFilter rightMouseDragged: theEvent];  }

- (void)otherMouseDragged:(GSEvent *)theEvent
{  [_eventFilter otherMouseDragged: theEvent];  }

// jason - this doesn't work, I think because the server I'm testing against doesn't support
// rfbButton4Mask and rfbButton5Mask (8 & 16).  They're not a part of rfbProto, so that ain't
// too surprising.
// 
// Later note - works fine now, maybe more servers have added support since I wrote the original
// comment
- (void)scrollWheel:(GSEvent *)theEvent
{  [_eventFilter scrollWheel: theEvent];  }

- (void)keyDown:(GSEvent *)theEvent
{  [_eventFilter keyDown: theEvent];  }

- (void)keyUp:(GSEvent *)theEvent
{  [_eventFilter keyUp: theEvent];  }

- (void)flagsChanged:(GSEvent *)theEvent
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
