//
//  VNCView.h
//  Vnsea
//
//  Created by Chris Reed on 9/5/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <UIKit/CDStructures.h>
#import <UIKit/UIWindow.h>
#import <UIKit/UIView-Hierarchy.h>
#import <UIKit/UIHardware.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIApplication.h>
#import <CoreGraphics/CoreGraphics.h>
#import "RFBConnection.h"
#import "EventFilter.h"
#import "FrameBuffer.h"
#import "RFBViewProtocol.h"
#import "VNCContentView.h"

/*!
 * @brief Main view to display and control the remote computer.
 *
 * This view class handles everything related to showing the remote display
 * and interacting with it. It is tightly coupled with the RFBConnection
 * instance and is its delegate.
 */
@interface VNCView : UIScroller <RFBViewProtocol>
{
    RFBConnection * _connection;
	EventFilter * _eventFilter;
	VNCContentView * _screenView;
	bool _inRemoteAction;
}

//! \name Implementation of RFBViewProtocol
//@{
- (void)setRemoteDisplaySize:(CGSize)remoteSize;
- (void)setFrameBuffer:(id)aBuffer;
- (void)setConnection:(RFBConnection *)connection;
- (RFBConnection *)connection;
- (void)displayFromBuffer:(CGRect)aRect;
- (void)drawRectList:(id)aList;
//@}

@end

