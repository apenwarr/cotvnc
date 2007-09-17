//
//  VNCContentView.m
//  vnsea
//
//  Created by Chris Reed on 9/15/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "VNCContentView.h"


@implementation VNCContentView

- (id)initWithFrame:(CGRect)frame
{
	if ([super initWithFrame:frame])
	{
		[self setOpaque:YES];
		[self setAlpha:1.0f];
	}
	
	return self;
}

- (void)dealloc
{
	[_frameBuffer release];
	[super dealloc];
}

- (void)setFrameBuffer:(FrameBuffer *)buffer
{
    [_frameBuffer autorelease];
	if (buffer)
	{
		_frameBuffer = [buffer retain];
		
		CGRect f = [self frame];
		f.size = [buffer size];
		[self setFrame:f];
	}
	else
	{
		_frameBuffer = nil;
	}
}

- (void)setRemoteDisplaySize:(CGSize)remoteSize
{
	CGRect bounds = [self bounds];
	bounds.size = remoteSize;
	[self setBounds:bounds];
		
	// Set our transformation matrix so that we're inverted top to bottom.
	// This accounts for the bitmap being drawn inverted. If we don't set the
	// matrix after setting the bounds, then we'd have to translate in addition
	// to scale.
	// XXX this should be fixed by rendering the bitmap correctly
	CGAffineTransform matrix = CGAffineTransformMakeScale(1.0f, -1.0f);
	[self setTransform:matrix];
	
	bounds = [self bounds];
}

- (void)drawRect:(CGRect)destRect
{
    CGRect b = [self bounds];
    CGRect r = destRect;

    r.origin.y = b.size.height - CGRectGetMaxY(r);
    [_frameBuffer drawRect:r at:destRect.origin];
}

- (void)displayFromBuffer:(CGRect)aRect
{
    CGRect b = [self bounds];
    CGRect r = aRect;

    r.origin.y = b.size.height - CGRectGetMaxY(r);
    [self setNeedsDisplayInRect:r];
}

@end
