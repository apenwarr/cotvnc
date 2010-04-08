//
//  VNCMouseTracks.h
//  vnsea
//
//  Created by Glenn Kreisel on 10/28/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FrameBuffer.h"

#import "VNCScrollerView.h"

typedef enum 
{
        kPopupStyleMouseDown = 1,
		kPopupStyleMouseUp = 2,
} mouseTracksStyles;


/*!
 * @brief Subview of VNCView that draws the screen.
 */
@interface VNCMouseTracks : UIView
{
	NSTimer *_popupTimer;
	char *_szBubbleText;
	mouseTracksStyles _styleWindow;
	CGPoint _ptVNC;
	VNCScrollerView *_scroller;
	float _fAnimateTime;
	int _cyclesLeft;
}

- (void)setCenterLocation:(CGPoint)ptCenter;
- (void)handlePopupTimer:(NSTimer *)timer;
- (void)setTimer:(float)fSeconds info:(id)info;
- (id)initWithFrame:(CGRect)frame style:(mouseTracksStyles)wStyle scroller:(VNCScrollerView *)scroller;
- (void)setStyleWindow:(mouseTracksStyles)wStyle;
- (void)drawRect:(CGRect)destRect;
- (void)zoomOrientationChange;
- (void)hide;
- (BOOL)isOpaque;
- (void)hideAnimate:(float)fTime;


@end
