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

/*!
 * @brief Subview of VNCView that draws the screen.
 */
@interface VNCPopupWindow : UIWindow
{
	VNCPopupView *_viewPopup;
	CGPoint _ptCenterOld;
	NSTimer *_popupTimer;
}

- (id)initWithFrame:(CGRect)frame bCenter:(BOOL)bCenter bShow:(BOOL)bShow fOrientation:(float)fOrientaion style:(popupWindowStyles)wStyle;
- (void)setHidden:(BOOL)bHide;

- (void)setTextPercent:(float)fScale;
- (void)setText:(NSString *)szText;
- (void)setCenterLocation:(CGPoint)ptCenter;
- (void)setStyleWindow:(popupWindowStyles)wStyle;
- (void)setTimer:(float)fSeconds info:(VNCPopupWindow **)info;

@end
