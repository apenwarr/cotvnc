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

@class EventFilter;
@protocol IServerData;

#define RFB_HOST		@"Host"
#define RFB_PASSWORD		@"Password"
#define RFB_REMEMBER		@"RememberPassword"
#define RFB_DISPLAY		@"Display"
#define RFB_SHARED		@"Shared"
#define RFB_FULLSCREEN          @"Fullscreen"
#define RFB_PORT		5900

#define	DEFAULT_HOST	@"localhost"

#define NUM_BUTTON_EMU_KEYS	2

@interface RFBConnection : ByteReader
{
    UIView<RFBViewProtocol> * rfbView;
	id _delegate;
    UIWindow * window;
    FrameBuffer* frameBuffer;
//    id manager;
    id socketHandler;
	EventFilter *_eventFilter;
    id currentReader;
    id versionReader;
    id handshaker;
    id/*<IServerData>*/ server_;
    id serverVersion;
    RFBProtocol *rfbProtocol;
//    id scrollView;
    id newTitleField;
//    NSPanel *newTitlePanel;
    NSString *titleString;
    id statisticField;
    BOOL terminating;
    CGPoint	_mouseLocation;
	unsigned int _lastMask;
    CGSize _maxSize;

    BOOL	horizontalScroll;
    BOOL	verticalScroll;

    id infoField;
    Profile *_profile;
		
    BOOL	updateRequested;	// Has someone already requested an update?
    
    NSString *realDisplayName;
    NSString *host;
	
    NSTimer *_reconnectTimer;
	BOOL _autoReconnect;

	float _frameBufferUpdateSeconds;
	NSTimer *_frameUpdateTimer;
	BOOL _hasManualFrameBufferUpdates;
	
	int serverMajorVersion;
	int serverMinorVersion;
}

// jason added 'owner' for fullscreen display
- (id)initWithServer:(id/*<IServerData>*/)server profile:(Profile*)p view:(UIView<RFBViewProtocol> *)theView;
- (id)initWithFileHandle:(NSFileHandle*)file server:(id/*<IServerData>*/)server profile:(Profile*)p view:(UIView<RFBViewProtocol> *)theView;

- (void)setView:(UIView<RFBViewProtocol> *)theView;
- (void)dealloc;

- (id)delegate;
- (void)setDelegate:(id)theDelegate;

- (void)setServerVersion:(NSString*)aVersion;
- (void)terminateConnection:(NSString*)aReason;
- (void)setDisplaySize:(CGSize)aSize andPixelFormat:(rfbPixelFormat*)pixf;
- (void)ringBell;

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

- (id)connectionHandle;
- (Profile*)profile;
- (id)serverSettings;
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

// For autoReconnect
- (void)resetReconnectTimer;
- (void)startReconnectTimer;
- (void)reconnectTimerTimeout:(id)sender;

@end

/*!
 * @brief Delegate methods for RFBConnection.
 */
@interface RFBConnection (DelegateMethods)

- (void)connection:(RFBConnection *)connection hasTerminatedWithReason:(NSString *)reason;

@end



