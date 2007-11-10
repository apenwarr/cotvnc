//
//  VNCMouseTracks.m
//  vnsea
//
//  Created by Glenn Kreisel on 10/28/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "VNCMouseTracks.h"

@implementation VNCMouseTracks

- (id)initWithFrame:(CGRect)frame style:(mouseTracksStyles)wStyle scroller: (VNCScrollerView *)scroller;
{
	if ([super initWithFrame:frame])
		{
		_styleWindow = wStyle;
		_szBubbleText = nil;
		_ptVNC = frame.origin;
		_scroller = scroller;
//		NSLog(@"Before Setting to %f,%f", [self frame].origin.x, [self frame].origin.y);
		[self zoomOrientationChange];
//		NSLog(@"Setting to %f,%f", [self frame].origin.x, [self frame].origin.y);
//		NSLog(@"");
		[scroller addSubview: self];
		}
	return self;
}

- (void)animateHide:(NSTimer *)timer
{
	if (_cyclesLeft)
		{
		float fAlpha = [self alpha] * ((float)_cyclesLeft / 10.0);
		
		[self setAlpha: fAlpha];
		[self setNeedsDisplay];
		_cyclesLeft--;
		}
	else
		{
		[timer invalidate];
		_popupTimer = nil;
		[self removeFromSuperview];
		[timer release];
		}
}

- (void)hideAnimate:(float)fTime
{
	_fAnimateTime = fTime;
}

- (void)hide
{
	if (_popupTimer != nil)
		{
		[_popupTimer invalidate];
		[_popupTimer release];
		_popupTimer = nil;
		}
	[self removeFromSuperview];
	[self release];
}

- (BOOL)isOpaque
{
//	NSLog(@"Checking for Opaque");
	return NO;
}

- (void)dealloc
{
//	NSLog(@"Dealloc MouseTracks");
	[self removeFromSuperview];
	if (_szBubbleText != nil)
		free(_szBubbleText);
	[super dealloc];
}

- (void)zoomOrientationChange
{
	CGRect frame = [self frame];
	CGRect r, rcBounds = CGRectMake(0,0,0,0);
	
	r.origin = _ptVNC;
	frame.origin = [_scroller getIPodScreenPoint: r bounds: rcBounds];
	frame.origin.x -= [self bounds].size.width / 2;
	frame.origin.y -= [self bounds].size.height / 2;
	[self setFrame: frame];
}

- (void)setCenterLocation:(CGPoint)ptCenter
{
	_ptVNC = ptCenter;
	[self zoomOrientationChange];
	return;
}

- (void)handlePopupTimer:(NSTimer *)timer
{	
//	NSLog(@"Timer going Away");
//	VNCPopupWindow **pw = (VNCPopupWindow **)[timer userInfo];
	
	_popupTimer = [[NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(animateHide:) userInfo:nil repeats:YES] retain];
	[timer release];
}

- (void)setTimer:(float)fSeconds info:(id)info
{
	//NSLog(@"In Setting Timer on Popup");
	_cyclesLeft = 10;
	_popupTimer = [[NSTimer scheduledTimerWithTimeInterval:fSeconds target:self selector:@selector(handlePopupTimer:) userInfo:nil repeats:NO] retain];
//	NSLog(@"Set Timer on Popup");
}


- (void)setStyleWindow:(mouseTracksStyles)wStyle
{
	_styleWindow = wStyle;
}

- (void)drawRect:(CGRect)destRect
{
		CGContextRef context = UICurrentContext();
		CGRect rcElipse = [self bounds];
			
		CGContextClearRect(context, rcElipse);
		rcElipse = CGRectInset(rcElipse, 1, 1);
		
//		CGContextSetRGBStrokeColor(context, 0, 0, 1, 1);
//		CGContextSetLineWidth (context, 2);
//		CGContextStrokeEllipseInRect(context, rcElipse);
		if (_styleWindow == kPopupStyleMouseDown)
			{
			CGContextSetRGBFillColor(context, 1, 0, 0, .7);
			}
		else if (_styleWindow == kPopupStyleMouseUp)
			{
			CGContextSetRGBFillColor(context, 0, 1, 0, .7);
			}
		CGContextFillEllipseInRect(context, rcElipse);
}
@end
