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

}

- (id)initWithFrame:(CGRect)frame bCenter:(BOOL)bCenter bShow:(BOOL)bShow fOrientation:(float)fOrientaion;
- (void)setHidden:(BOOL)bHide;

- (void)setTextPercent:(float)fScale;
- (void)setText:(id)szText;
- (void)setCenterLocation:(CGPoint)ptCenter;


@end
