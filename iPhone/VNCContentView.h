//
//  VNCContentView.h
//  vnsea
//
//  Created by Chris Reed on 9/15/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FrameBuffer.h"

/*!
 * @brief Subview of VNCView that draws the screen.
 */
@interface VNCContentView : UIView
{
    FrameBuffer * _frameBuffer;
    float _orientationDeg;
    float _scalePercent;
    //UIHardwareOrientation _orientationState;
    CGAffineTransform _matrixPreviousTransform;
    CGRect _frame;
	id _delegate;
}
- (void)setDelegate:(id)newDelegate;
- (id)delegate;

- (void)setFrameBuffer:(FrameBuffer *)buffer;

- (void)setRemoteDisplaySize:(CGSize)remoteSize animate:(BOOL)bAnimate;

- (void)displayFromBuffer:(CGRect)aRect;

- (float)getScalePercent;
- (void)setScalePercent:(float)fPercent;
//- (UIHardwareOrientation)getOrientationState;
//- (void)setOrientationState:(UIHardwareOrientation)wState;
- (void)setOrientationDeg:(float)fDeg;
- (float)getOrientationDeg;
- (CGRect)getFrame;
- (CGPoint)getIPodScreenPoint:(CGRect)r bounds:(CGRect)bounds;

@end
