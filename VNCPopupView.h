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

typedef enum 
{
        kPopupStyleScalePercent = 0,
		kPopupStyleViewOnly = 1,
} popupWindowStyles;


/*!
 * @brief Subview of VNCView that draws the screen.
 */
@interface VNCPopupView : UIView
{
	char *_szBubbleText;
	popupWindowStyles _styleWindow;
}

- (id)initWithFrame:(CGRect)frame style:(popupWindowStyles)wStyle;
- (void)setStyleWindow:(popupWindowStyles)wStyle;
- (void)drawRect:(CGRect)destRect;
- (void)setText:(NSString *)szText;

@end
