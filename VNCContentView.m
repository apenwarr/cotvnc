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
		// Set our transformation matrix so that we're inverted top to bottom.
		// This accounts for the bitmap being drawn inverted.
		// XXX this should be fixed by rendering the bitmap correctly
		CGAffineTransform matrix = CGAffineTransformMakeScale(1.0f, -1.0f);
		[self setTransform:matrix];
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
	NSLog(@"content::setbuf:%@", buffer);
    [_frameBuffer autorelease];
	if (buffer)
	{
		_frameBuffer = [buffer retain];
		
//		CGRect f = [self frame];
//		f.size = [buffer size];
//		[self setFrame:f];
	}
	else
	{
		_frameBuffer = nil;
	}
}

- (void)setRemoteDisplaySize:(CGSize)remoteSize
{
/*	NSLog(@"content::setdisplaysize:{%f,%f}", remoteSize.width, remoteSize.height);
	CGRect frame = [self bounds];
	frame.size = remoteSize;
	[self setBounds:frame];*/
}

- (void)drawRect:(CGRect)destRect
{
/*	NSLog(@"content::draw");
//	NSLog(@"drawRect{%f,%f,%f,%f}", destRect.origin.x, destRect.origin.y, destRect.size.width, destRect.size.height);
	
    CGRect b = [self bounds];
    CGRect r = destRect;

    r.origin.y = b.size.height - CGRectGetMaxY(r);
    [_frameBuffer drawRect:r at:destRect.origin];*/
}

- (void)displayFromBuffer:(CGRect)aRect
{
/*	NSLog(@"content::displaybuf");
    CGRect b = [self bounds];
    CGRect r = aRect;

    r.origin.y = b.size.height - CGRectGetMaxY(r);
    [self setNeedsDisplayInRect:r];*/
}

@end
