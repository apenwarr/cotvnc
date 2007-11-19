//
//  VNCPopupView.h
//  vnsea
//
//  Created by Glenn Kreisel on 10/28/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FrameBuffer.h"
#import "VNCScrollerView.h"

//! The different drawing styles available for the popup view.
typedef enum _popup_style
{
	kPopupStyleScalePercent = 0,
	kPopupStyleViewOnly = 1,
	kPopupStyleDrag = 2,
} popup_style_t;

/*!
 * @brief View class that draws a message bubble.
 */
@interface VNCPopupView : UIView
{
	NSString * _bubbleText;			//!< Text to draw inside the popup bubble.
	popup_style_t _styleWindow;	//!< Selected drawing style.
	UIImage *_imageDrag;
}

- (id)initWithFrame:(CGRect)frame style:(popup_style_t)theStyle;

- (void)setStyleWindow:(popup_style_t)theStyle;

//! @brief Change the view's text.
- (void)setText:(NSString *)theText;

- (void)drawRect:(CGRect)destRect;

@end
