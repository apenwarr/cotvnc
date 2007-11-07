//
//  VNCPoupView.m
//  vnsea
//
//  Created by Glenn Kreisel on 10/28/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "VNCPopupView.h"

@implementation VNCPopupView

- (id)initWithFrame:(CGRect)frame style:(popupWindowStyles)wStyle;
{
	if ([super initWithFrame:frame])
		{
		_styleWindow = wStyle;
		_szBubbleText = nil;
		}
	return self;
}

- (void)dealloc
{
	if (_szBubbleText != nil)
		free(_szBubbleText);
	[super dealloc];
}

- (void)setStyleWindow:(popupWindowStyles)wStyle
{
	_styleWindow = wStyle;
}

- (void)setText:(NSString *)text
{
//	NSLog(@"Got text: ");
	if (text != nil)
		{
		_szBubbleText = (char *)malloc([text length]+1);
		strcpy(_szBubbleText, [text cString]);
		}
    [self setNeedsDisplayInRect: [self bounds]];
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
		if (_szBubbleText != nil)
			{			
			CGContextSelectFont(context, "MarkerFeltThin", 18.0, kCGEncodingMacRoman);
			CGContextSetTextPosition(context, 0, 0);
			CGPoint ptBefore = CGContextGetTextPosition(context);
			CGContextSetTextDrawingMode(context, kCGTextInvisible);
			CGContextShowText(context, _szBubbleText, strlen(_szBubbleText));
			CGPoint ptAfter = CGContextGetTextPosition(context);
			float dxText = ptAfter.x - ptBefore.x;
			CGContextSetTextDrawingMode(context, kCGTextFill);
			CGContextShowTextAtPoint(context, 0-(dxText / 2), -6, _szBubbleText, strlen(_szBubbleText));
			}
			}
		CGContextRestoreGState(context);
}
@end
