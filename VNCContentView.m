//
//  VNCContentView.m
//  vnsea
//
//  Created by Chris Reed on 9/15/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//  Modified by: Glenn Kreisel

#import "VNCContentView.h"


@implementation VNCContentView

- (UIHardwareOrientation)getOrientationState
{
	return _orientationState;
}

- (void)setOrientationState:(UIHardwareOrientation)wState
{
	_orientationState = wState;
	switch (wState)
		{
		case kOrientationHorizontalRight:
			_orientationDeg = -90;
			break;
		case kOrientationHorizontalLeft:
			_orientationDeg = 90;
			break;
		case kOrientationVertical:
			_orientationDeg = 180;
			break;
		case kOrientationVerticalUpsideDown:
			_orientationDeg = 0;
			break;
		}
}

- (void)setOrientationDeg:(float)wDeg
{
	_orientationDeg = wDeg;
}

- (float)getOrientationDeg
{
	return _orientationDeg;
}

- (float)getScalePercent
{
	return _scalePercent;
}

- (CGRect)getFrame
{
	return _frame;
}

- (void)setScalePercent:(float)wScale
{
	_scalePercent = wScale;
}

- (id)initWithFrame:(CGRect)frame
{
	if ([super initWithFrame:frame])
	{
		[self setOpaque:YES];
		[self setAlpha:1.0f];
	}
	_scalePercent = 0.50f;
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

- (CGPoint)getIPodScreenPoint:(CGRect)r bounds:(CGRect)bounds
{
	CGPoint ptIPod = CGPointApplyAffineTransform(r.origin, _matrixPreviousTransform);
	CGRect rcFrame = _frame;

        switch (_orientationState)
               {
				case kOrientationVerticalUpsideDown:
					ptIPod.x = (rcFrame.size.width + ptIPod.x) - bounds.origin.x;
					ptIPod.y = (rcFrame.size.height - ptIPod.y) - bounds.origin.y;
				break;
				case kOrientationVertical:                                        
					ptIPod.x = ptIPod.x - bounds.origin.x;
					ptIPod.y = 0 - (ptIPod.y + bounds.origin.y);
				break;
				case kOrientationHorizontalRight:
					ptIPod.x = 0 - (ptIPod.x + bounds.origin.x);
					ptIPod.y = (rcFrame.size.height + ptIPod.y) - bounds.origin.y ;
				break;
				case kOrientationHorizontalLeft:
					ptIPod.x = (rcFrame.size.width - ptIPod.x) - bounds.origin.x;
					ptIPod.y = (ptIPod.y - bounds.origin.y);
				break;
               }

	return ptIPod;
}

- (void)setRemoteDisplaySize:(CGSize)remoteSize animate:(BOOL)bAnimate
{
	CGRect bounds = [self bounds];
	CGRect frame = CGRectMake(0,0, remoteSize.width, remoteSize.height);

	NSLog(@"Frame = %f %f %f %f", frame.origin.x, frame.origin.y, frame.size.width,frame.size.height);
	NSLog(@"Bounds = %f %f %f %f ", bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height);
	NSLog(@"RemoteSize = %f %f", remoteSize.width, remoteSize.height);

	_frame = frame;
	[self setFrame:frame];
	[self setBounds:bounds];
		
	// Set our transformation matrix so that we're inverted top to bottom.
	// This accounts for the bitmap being drawn inverted. If we don't set the
	// matrix after setting the bounds, then we'd have to translate in addition
	// to scale.
	//! @todo This should be fixed by rendering the bitmap correctly.
	CGAffineTransform matrix = CGAffineTransformRotate(CGAffineTransformMakeScale(0-_scalePercent, _scalePercent), _orientationDeg  * M_PI / 180.0f);
	if (bAnimate)
		{
		UITransformAnimation *scaleAnim = [[UITransformAnimation alloc] initWithTarget: self];
		[scaleAnim setStartTransform: _matrixPreviousTransform];
		[scaleAnim setEndTransform: matrix];
		UIAnimator *anim = [[UIAnimator alloc] init];
		[anim addAnimation:scaleAnim withDuration:0.30f start:YES]; 
		}
	[self setTransform:matrix];
	_matrixPreviousTransform = matrix;
}

- (void)drawRect:(CGRect)destRect
{
	if (_frameBuffer)
	{
		CGRect b = [self bounds];
		CGRect r = destRect;
		
		NSLog(@"Drawing frame buffer");
		CGContextRef context = UICurrentContext();
		CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
		r.origin.y = b.size.height - CGRectGetMaxY(r);
		[_frameBuffer drawRect:r at:destRect.origin];
	}
	else
	{
		// If there is no framebuffer, we just draw a black background.
		CGContextRef context = UICurrentContext();
		CGContextSetRGBFillColor(context, 0, 0, 0, 1);
		CGContextFillRect(context, destRect);
	}
}

- (void)displayFromBuffer:(CGRect)aRect
{
    CGRect b = [self bounds];
    CGRect r = aRect;

    r.origin.y = b.size.height - CGRectGetMaxY(r);
    [self setNeedsDisplayInRect:r];
}

@end
