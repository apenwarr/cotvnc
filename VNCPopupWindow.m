//
//  VNCPoupWindow.m
//  vnsea
//
//  Created by Glenn Kreisel on 10/28/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "VNCPopupWindow.h"
#import "VNCPopupView.h"

@implementation VNCPopupWindow

- (void)setHidden:(BOOL)bHide
{
	NSLog(@"Set Hidden");
	[self _setHidden: bHide];
}

- (void)setText:(id)szText
{
	NSLog(@"Set Text PopWindow");
	[_viewPopup setText:szText];
}

- (void)setTextPercent:(float)fScale
{
	char szPercent[20];
	
	NSLog(@"Text Percent %f", fScale);
	sprintf(szPercent, "%d%%", (int)(fScale * 100));
	[_viewPopup setText: szPercent];
}

- (void)setCenterLocation:(CGPoint)ptCenter
{
	CGRect rcFrame = [self frame];
		
	rcFrame.origin.x = ptCenter.x - [self bounds].size.width / 2;
	rcFrame.origin.y = ptCenter.y - [self bounds].size.height / 2;
	[self setFrame: rcFrame];
}

- (id)initWithFrame:(CGRect)frame bCenter:(BOOL)bCenter bShow:(BOOL)bShow fOrientation:(float)fOrientation
{
	if (bCenter)
		{
		CGRect rcWindow = [UIHardware fullScreenApplicationContentRect];
		
		frame.origin.x = (rcWindow.size.width / 2) - (frame.size.width / 2);
		frame.origin.y = (rcWindow.size.height / 2) - (frame.size.height / 2);
		NSLog(@"Popup centered at %f %f", frame.origin.x, frame.origin.y);
		}
		
	if ([super initWithFrame:frame])
		{
		_viewPopup = [[VNCPopupView alloc] initWithFrame: [self bounds]];
		[_viewPopup setText: (id)""];
		[_viewPopup setBackgroundColor:GSColorCreateColorWithDeviceRGBA(0.0, 0.0, 0.0, .0)];
		CGAffineTransform matrix = CGAffineTransformRotate(CGAffineTransformMakeScale(0-1, 1), fOrientation  * M_PI / 180.0f);
		[self setContentView:_viewPopup]; 
		[_viewPopup setTransform: matrix];
		[self orderFront:nil]; 
		[self makeKey:nil];
		[self _setHidden:!bShow];
		
		NSLog(@"Popup Orientation %f", fOrientation);

		}
	return self;
}

- (void)dealloc
{
    [super dealloc];
}


@end
