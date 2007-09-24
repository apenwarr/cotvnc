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

- (RFBConnection *)connection;
{
	return _connection;
}

- (void)alertSheet:(id)sheet buttonClicked:(int)buttonIndex
{  
	[sheet dismissAnimated:YES];
	[sheet release];
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


- (void)mouseDown:(GSEvent *)theEvent
{
	bool isChording = GSEventIsChordingHandEvent(theEvent);
	
//	NSLog(@"mouseDown:%c", isChording ? 'y' : 'n');
	
	if (isChording)
	{
		_inRemoteAction = false;
		[super mouseDown:theEvent];
	}
	else
	{
		_inRemoteAction = true;
		[_eventFilter mouseDown:theEvent];
	}
}

- (void)mouseUp:(GSEvent *)theEvent
{
//	bool isChording = GSEventIsChordingHandEvent(theEvent);
	
//	NSLog(@"mouseUp:%c", isChording ? 'y' : 'n');
	
	if (!_inRemoteAction)
	{
		[super mouseUp:theEvent];
	}
	else
	{
		[_eventFilter mouseUp:theEvent];
	}
}


- (void)mouseDragged:(GSEvent *)theEvent
{
//	bool isChording = GSEventIsChordingHandEvent(theEvent);
	
//	NSLog(@"mouseDragged:%c", isChording ? 'y' : 'n');
	
	if (!_inRemoteAction)
	{
		[super mouseDragged:theEvent];
	}
	else
	{
		[_eventFilter mouseDragged:theEvent];
	}
}

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
