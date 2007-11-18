//
//  VNCBackgroundView.h
//  vnsea
//
//  Created by Glenn Kreisel on 10/28/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FrameBuffer.h"

/*!
 * @brief Simple view that draws a background color or pattern.
 */
@interface VNCBackgroundView : UIView
{
}

- (id)initWithFrame:(CGRect)frame;
- (void)drawRect:(CGRect)destRect;

@end
