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
}

- (void)setFrameBuffer:(FrameBuffer *)buffer;

- (void)setRemoteDisplaySize:(CGSize)remoteSize;

- (void)displayFromBuffer:(CGRect)aRect;

@end
