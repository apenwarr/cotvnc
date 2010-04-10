//
//  VNCContentView.h
//  vnsea
//
//  Created by Chris Reed on 9/15/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FrameBuffer.h"
#import "RFBViewProtocol.h"

/*!
 * @brief Subview of VNCView that draws the screen.
 */
@interface VNCContentView : UIView<RFBViewProtocol>
{
    id delegate;
    FrameBuffer * _frameBuffer;
    CGAffineTransform _matrixPreviousTransform;
    CGRect _frame;
}

@property (nonatomic, assign) IBOutlet id delegate;

- (void)setFrameBuffer:(FrameBuffer *)buffer;
- (void)setRemoteDisplaySize:(CGSize)remoteSize animate:(BOOL)bAnimate;
- (void)displayFromBuffer:(CGRect)aRect;

@end
