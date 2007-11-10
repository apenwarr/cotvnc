//
//  VNCPoupView.m
//  vnsea
//
//  Created by Glenn Kreisel on 10/28/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "VNCPopupView.h"

@implementation VNCPopupView

- (id)initWithFrame:(CGRect)frame style:(popup_style_t)theStyle;
{
	if ([super initWithFrame:frame])
	{
		_styleWindow = theStyle;
		[self setEnabled: NO];
	}
	return self;
}

- (void)dealloc
{
	[_bubbleText release];
	[super dealloc];
}

- (void)setStyleWindow:(popup_style_t)theStyle
{
	_styleWindow = theStyle;
}

//! Setting the text causes the view to redraw itself immediately.
- (void)setText:(NSString *)theText
{
	[_bubbleText release];
	_bubbleText = [theText retain];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)destRect
{
	CGContextRef context = UICurrentContext();
	CGRect rcElipse = [self bounds];
		
	CGContextSaveGState(context);
	
	if (_styleWindow == kPopupStyleScalePercent)
	{
		CGContextSetRGBFillColor(context, 0, 0, 1, .3);
		rcElipse = CGRectInset(rcElipse, 4,4);
	
		CGContextFillEllipseInRect(context, rcElipse);
		CGContextSetRGBFillColor(context, 1, 1, 1, .7);
		CGContextSetRGBStrokeColor(context, 1, 1, 1, .7);
		CGContextSetLineWidth (context, 3);
		CGContextStrokeEllipseInRect(context, rcElipse);
		CGContextSetLineWidth (context, 1);
	
		CGContextTranslateCTM(context, [self bounds].size.width / 2, [self bounds].size.height/2);
		CGContextSetRGBFillColor(context, 1, 1, 1, .7);
		
		CGContextSelectFont(context, "MarkerFeltThin", 18.0, kCGEncodingMacRoman);
	}
	else if (_styleWindow == kPopupStyleViewOnly)
	{
		CGContextSetRGBFillColor(context, 0, 0, 1, .5);
		rcElipse = CGRectInset(rcElipse, 1,1);
		CGContextFillRect(context, rcElipse);
		CGContextSetRGBFillColor(context, 1, 1, 1, .5);
		CGContextSetLineWidth (context, 1);
		CGContextTranslateCTM(context, [self bounds].size.width / 2, [self bounds].size.height/2);
		CGContextSetRGBFillColor(context, 1, 1, 1, .5);
		
		CGContextSelectFont(context, "Helvetica", 12.0, kCGEncodingMacRoman);
	}
	
	if (_bubbleText != nil)
	{
		// Get a C-style string from the NSString.
		const char * utf8String = [_bubbleText UTF8String];
		
		// First draw the string invisibly while recording its positions to figure out the width.
		CGContextSetTextPosition(context, 0, 0);
		CGPoint ptBefore = CGContextGetTextPosition(context);
		CGContextSetTextDrawingMode(context, kCGTextInvisible);
		CGContextShowText(context, utf8String, strlen(utf8String));
		CGPoint ptAfter = CGContextGetTextPosition(context);
		float dxText = ptAfter.x - ptBefore.x;
		
		// Then use the width to draw the string centered in the view.
		CGContextSetTextDrawingMode(context, kCGTextFill);
		CGContextShowTextAtPoint(context, 0 - (dxText / 2), -6, utf8String, strlen(utf8String));
	}
	
	CGContextRestoreGState(context);
}
@end
