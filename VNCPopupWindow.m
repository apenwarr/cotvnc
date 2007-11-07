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
//	NSLog(@"Set Hidden");
	[self _setHidden: bHide];
}

- (void)setStyleWindow:(popupWindowStyles)wStyle
{
	[_viewPopup setStyleWindow: wStyle];
}

- (void)setText:(NSString *)text
{
//	NSLog(@"Set Text PopWindow");
	[_viewPopup setText: text];
}

- (void)setTextPercent:(float)fScale
{
//	NSLog(@"Text Percent %f", fScale);
	[_viewPopup setText: [NSString stringWithFormat: @"%d%%", (int)(fScale * 100)]];
}

- (void)setCenterLocation:(CGPoint)ptCenter
{
	CGRect rcFrame = [self frame];
	
	if (ptCenter.x != _ptCenterOld.x || ptCenter.y != _ptCenterOld.y)
			{
			CGRect rcWindow = [UIHardware fullScreenApplicationContentRect];
			
			rcFrame.origin.x = rcWindow.origin.x + (ptCenter.x - [self bounds].size.width / 2);
			rcFrame.origin.y = rcWindow.origin.y + ((ptCenter.y - [self bounds].size.height / 2));
			
			[self setFrame: rcFrame];
			_ptCenterOld = ptCenter;
			}
}

- (void)handlePopupTimer:(NSTimer *)timer
{	
//	NSLog(@"Timer going Away");
	VNCPopupWindow **pw = (VNCPopupWindow **)[timer userInfo];
	[_viewPopup removeFromSuperview];
	if (pw != nil)
		*pw = nil;
}

- (void)setTimer:(float)fSeconds info:(VNCPopupWindow **)info
{
	//NSLog(@"In Setting Timer on Popup");
	_popupTimer = [NSTimer scheduledTimerWithTimeInterval:fSeconds target:self selector:@selector(handlePopupTimer:) userInfo:nil repeats:NO];
//	NSLog(@"Set Timer on Popup");
}

- (id)initWithFrame:(CGRect)frame bCenter:(BOOL)bCenter bShow:(BOOL)bShow fOrientation:(float)fOrientation style:(popupWindowStyles)wStyle
{
	if (bCenter)
		{
		CGRect rcWindow = [UIHardware fullScreenApplicationContentRect];
		
		frame.origin.x = rcWindow.origin.x + ((rcWindow.size.width / 2) - (frame.size.width / 2));
		frame.origin.y = rcWindow.origin.y + ((rcWindow.size.height / 2) - (frame.size.height / 2));
//		NSLog(@"Popup centered at %f %f", frame.origin.x, frame.origin.y);
		}
		
	if ([super initWithFrame:frame])
		{
		_viewPopup = [[VNCPopupView alloc] initWithFrame:[self bounds] style:wStyle];
		[_viewPopup setText: nil];
		[_viewPopup setBackgroundColor:GSColorCreateColorWithDeviceRGBA(0.0, 0.0, 0.0, .0)];
		CGAffineTransform matrix = CGAffineTransformRotate(CGAffineTransformMakeScale(0-1, 1), fOrientation  * M_PI / 180.0f);
		[self setContentView:_viewPopup]; 
		[_viewPopup setTransform: matrix];
		[self orderFront:nil]; 
		[self makeKey:nil];
		[self _setHidden:!bShow];
		
//		NSLog(@"Popup Orientation %f", fOrientation);

		}
	return self;
}

- (void)dealloc
{
    [super dealloc];
}


@end
