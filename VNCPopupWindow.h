//
//  VNCPopupWindow.h
//  vnsea
//
//  Created by Glenn Kreisel on 10/28/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FrameBuffer.h"
#import "VNCPopupView.h"

@class VNCScrollerView;

/*!
 * @brief Window that hosts a popup message bubble.
 */
@interface VNCPopupWindow : UIWindow
{
	VNCPopupView *_viewPopup;
	CGPoint _ptCenterOld;
	NSTimer *_popupTimer;
	VNCScrollerView *_scroller;
}

- (id)initWithFrame:(CGRect)frame centered:(BOOL)bCenter show:(BOOL)bShow orientation:(float)fOrientaion style:(popup_style_t)wStyle;

- (void)setHidden:(BOOL)bHide;
- (void)setTextPercent:(float)fScale;
- (void)setText:(NSString *)theText;
- (void)setCenterLocation:(CGPoint)ptCenter;
- (void)setStyleWindow:(popup_style_t)wStyle;

- (void)setTimer:(float)fSeconds info:(VNCPopupWindow **)info;

@end
