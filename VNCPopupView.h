//
//  VNCPopupView.h
//  vnsea
//
//  Created by Glenn Kreisel on 10/28/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FrameBuffer.h"

/*!
 * @brief Subview of VNCView that draws the screen.
 */
@interface VNCPopupView : UIView
{
	char _szBubbleText[100];
}

- (void)drawRect:(CGRect)destRect;
- (void)setText:(id)szText;

@end
