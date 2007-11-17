//
//  VNCBackgroundView.h
//  vnsea
//
//  Created by Glenn Kreisel on 10/28/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FrameBuffer.h"

#import "VNCScrollerView.h"

/*!
 * @brief Subview of VNCView that draws the screen.
 */
@interface VNCBackgroundView : UIView
{
}

- (id)initWithFrame:(CGRect)frame;
- (void)drawRect:(CGRect)destRect;


@end
