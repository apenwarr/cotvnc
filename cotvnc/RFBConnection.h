/* Copyright (C) 1998-2000  Helmut Maierhofer <helmut.maierhofer@chello.at>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 */

#import <UIKit/UIKit.h>
#import "ByteReader.h"
#import "FrameBuffer.h"
#import "Profile.h"
#import "rfbproto.h"
#import "RFBProtocol.h"
#import "RFBViewProtocol.h"
#import "ServerFromPrefs.h"

@class EventFilter;

#define	DEFAULT_HOST	@"localhost"

#define NUM_BUTTON_EMU_KEYS	2

/*!
 * @brief Manages the connection with the remote VNC server.
 *
 * To create a connection, follow these steps:
 *	- create an instance of RFBConnection
 *	- pass the -initWithServer:profile:view: method the server and other objects
 *	- if you already have an NSFileHandle connection object, call -setConnectionHandle:
 *	- otherwise, call -openConnectionReturningError:. It will return a boolean
 *		indicating whether a connection was opened
 *	- if a connection was opened, call -startTalking to initiate communications
 *
 * After communications has begun and the basic handshake has been made, the
 * connection object will call -setConnection: on the view passed into the init
 * method. This gives the view a chance to set the connection object's delegate
 * and generally prepare.
 *
 * When the connection terminates, for whatever reason, the delegate is sent the
 * -connection:hasTerminatedWithReason: message. At any time, you can determine
 * if the connection is still alive by sending the -isConnectionOpen message. It
 * will return YES if so.
 */
@interface RFBConnection : ByteReader
{
	NSFileHandle * _handle;
    UIView<RFBViewProtocol> * rfbView;
	id _delegate;
    UIWindow * window;
    FrameBuffer * frameBuffer;
    id socketHandler;
	EventFilter * _eventFilter;
    id currentReader;
    id versionReader;
    id handshaker;
    ServerBase * server_;
    id serverVersion;
    RFBProtocol * rfbProtocol;
    id statisticField;
    BOOL terminating;
    CGPoint	_mouseLocation;
	unsigned int _lastMask;
    CGSize _maxSize;
    Profile * _profile;
    BOOL updateRequested;	//!< Has someone already requested an update?
    NSString * host;
	float _frameBufferUpdateSeconds;
	NSTimer * _frameUpdateTimer;
	BOOL _hasManualFrameBufferUpdates;
	int serverMajorVersion;
	int serverMinorVersion;
	BOOL _isOpen;
	BOOL _cancelConnect;
}

- (id)initWithServer:(ServerBase *)server profile:(Profile*)p view:(UIView<RFBViewProtocol> *)theView;

- (BOOL)openConnectionReturningError:(NSString **)errorMessage;
- (void)startTalking;

- (void)cancelConnect;
- (BOOL)didCancelConnect;

- (id)connectionHandle;
- (void)setConnectionHandle:(id)handle;

//! @brief Returns YES if the connection is alive.
- (BOOL)isConnectionOpen;

- (void)setView:(UIView<RFBViewProtocol> *)theView;

- (id)delegate;
- (void)setDelegate:(id)theDelegate;

- (void)setServerVersion:(NSString*)aVersion;
- (void)terminateConnection:(NSString*)aReason;
- (void)setDisplaySize:(CGSize)aSize andPixelFormat:(rfbPixelFormat*)pixf;
- (CGSize)displaySize;
- (void)ringBell;
- (void)sendCtrlAltDel:(id)sender;

- (void)drawRectFromBuffer:(CGRect)aRect;
- (void)drawRectList:(id)aList;
- (void)pauseDrawing;
- (void)flushDrawing;
- (void)queueUpdateRequest;
- (void)requestFrameBufferUpdate:(id)sender;
- (void)cancelFrameBufferUpdateRequest;

- (void)clearAllEmulationStates;
- (void)mouseAt:(CGPoint)thePoint buttons:(unsigned int)mask;
- (void)sendKey:(unichar)key pressed:(BOOL)pressed;
- (void)sendModifier:(unsigned int)m pressed:(BOOL)pressed;
- (void)writeBytes:(unsigned char*)bytes length:(unsigned int)length;
- (void)writeRFBString:(NSString *)aString;

- (Profile*)profile;
- (ServerBase *)serverSettings;
- (NSString*)serverVersion;
- (int) serverMajorVersion;
- (int) serverMinorVersion;
- (NSString*)password;
- (BOOL)connectShared;
- (BOOL)viewOnly;
- (CGRect)visibleRect;
- (id)frameBuffer;
- (UIWindow *)window;
- (EventFilter *)eventFilter;

- (void)updateStatistics:(id)sender;

- (float)frameBufferUpdateSeconds;
- (void)setFrameBufferUpdateSeconds: (float)seconds;
- (void)manuallyUpdateFrameBuffer: (id)sender;

@end

/*!
 * @brief Delegate methods for RFBConnection.
 */
@interface RFBConnection (DelegateMethods)

- (void)connection:(RFBConnection *)connection hasTerminatedWithReason:(NSString *)reason;

@end



