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

#import "RFBConnection.h"
#import "QueuedEvent.h"
#import "EncodingReader.h"
#import "EventFilter.h"
#import "FrameBuffer.h"
#import "FrameBufferUpdateReader.h"
#import "IServerData.h"
#import "ServerBase.h"
#import "NLTStringReader.h"
#import "PrefController.h"
#import "RectangleList.h"
#import "RFBHandshaker.h"
#import "RFBProtocol.h"
#import "RFBServerInitReader.h"
#import "TightEncodingReader.h"
#include <unistd.h>
#include <libc.h>

#define	F0_KEYCODE		0xffbd
#define	F1_KEYCODE		0xffbe
#define F2_KEYCODE		0xffbf
#define	F3_KEYCODE		0xffc0
#define CAPSLOCK		0xffe5
#define kPrintKeyCode	0xff61
#define kExecuteKeyCode	0xff62
#define kPauseKeyCode	0xff13
#define kBreakKeyCode	0xff6b
#define kInsertKeyCode	0xff63
#define kDeleteKeyCode	0xffff
#define kEscapeKeyCode	0xff1b
#define kTabKeyCode	0xff09


NSString * kConnectionTerminatedException = @"ConnectionTerminatedException";

const unsigned int page0[256] = {
    0x0, 0x1, 0x2, 0x3, 0x4, 0x5, 0x6, 0x7, 0x8, 0xff09, 0xa, 0xb, 0xc, 0xff0d, 0xe, 0xf,
    0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0xff09, 0x1a, 0xff1b, 0x1c, 0x1d, 0x1e, 0x1f,
    0x20, 0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 0x2a, 0x2b, 0x2c, 0x2d, 0x2e, 0x2f,
    0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3a, 0x3b, 0x3c, 0x3d, 0x3e, 0x3f,
    0x40, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48, 0x49, 0x4a, 0x4b, 0x4c, 0x4d, 0x4e, 0x4f,
    0x50, 0x51, 0x52, 0x53, 0x54, 0x55, 0x56, 0x57, 0x58, 0x59, 0x5a, 0x5b, 0x5c, 0x5d, 0x5e, 0x5f,
    0x60, 0x61, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 0x69, 0x6a, 0x6b, 0x6c, 0x6d, 0x6e, 0x6f,
    0x70, 0x71, 0x72, 0x73, 0x74, 0x75, 0x76, 0x77, 0x78, 0x79, 0x7a, 0x7b, 0x7c, 0x7d, 0x7e, 0xff08,
    0x80, 0x81, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87, 0x88, 0x89, 0x8a, 0x8b, 0x8c, 0x8d, 0x8e, 0x8f,
    0x90, 0x91, 0x92, 0x93, 0x94, 0x95, 0x96, 0x97, 0x98, 0x99, 0x9a, 0x9b, 0x9c, 0x9d, 0x9e, 0x9f,
    0xa0, 0xa1, 0xa2, 0xa3, 0xa4, 0xa5, 0xa6, 0xa7, 0xa8, 0xa9, 0xaa, 0xab, 0xac, 0xad, 0xae, 0xaf,
    0xb0, 0xb1, 0xb2, 0xb3, 0xb4, 0xb5, 0xb6, 0xb7, 0xb8, 0xb9, 0xba, 0xbb, 0xbc, 0xbd, 0xbe, 0xbf,
    0xc0, 0xc1, 0xc2, 0xc3, 0xc4, 0xc5, 0xc6, 0xc7, 0xc8, 0xc9, 0xca, 0xcb, 0xcc, 0xcd, 0xce, 0xcf,
    0xd0, 0xd1, 0xd2, 0xd3, 0xd4, 0xd5, 0xd6, 0xd7, 0xd8, 0xd9, 0xda, 0xdb, 0xdc, 0xdd, 0xde, 0xdf,
    0xe0, 0xe1, 0xe2, 0xe3, 0xe4, 0xe5, 0xe6, 0xe7, 0xe8, 0xe9, 0xea, 0xeb, 0xec, 0xed, 0xee, 0xef,
    0xf0, 0xf1, 0xf2, 0xf3, 0xf4, 0xf5, 0xf6, 0xf7, 0xf8, 0xf9, 0xfa, 0xfb, 0xfc, 0xfd, 0xfe, 0xff,
};

const unsigned int pagef7[256] = {
    0xff52, 0xff54, 0xff51, 0xff53, 0xffbe, 0xffbf, 0xffc0, 0xffc1, 0xffc2, 0xffc3, 0xffc4, 0xffc5, 0xffc6, 0xffc7, 0xffc8, 0xffc9,
    0xf710, 0xf711, 0xf712, 0xf713, 0xf714, 0xf715, 0xf716, 0xf717, 0xf718, 0xf719, 0xf71a, 0xf71b, 0xf71c, 0xf71d, 0xf71e, 0xf71f,
    0xf720, 0xf721, 0xf722, 0xf723, 0xf724, 0xf725, 0xf726, 0xff63, 0xffff, 0xff50, 0xf72a, 0xff57, 0xff55, 0xff56, 0xf72e, 0xf72f,
    0xf730, 0xf731, 0xf732, 0xf733, 0xf734, 0xf735, 0xf736, 0xf737, 0xf738, 0xf739, 0xf73a, 0xf73b, 0xf73c, 0xf73d, 0xf73e, 0xf73f,
    0xf740, 0xf741, 0xf742, 0xf743, 0xf744, 0xf745, 0xf746, 0xf747, 0xf748, 0xf749, 0xf74a, 0xf74b, 0xf74c, 0xf74d, 0xf74e, 0xf74f,
    0xf750, 0xf751, 0xf752, 0xf753, 0xf754, 0xf755, 0xf756, 0xf757, 0xf758, 0xf759, 0xf75a, 0xf75b, 0xf75c, 0xf75d, 0xf75e, 0xf75f,
    0xf760, 0xf761, 0xf762, 0xf763, 0xf764, 0xf765, 0xf766, 0xf767, 0xf768, 0xf769, 0xf76a, 0xf76b, 0xf76c, 0xf76d, 0xf76e, 0xf76f,
    0xf770, 0xf771, 0xf772, 0xf773, 0xf774, 0xf775, 0xf776, 0xf777, 0xf778, 0xf779, 0xf77a, 0xf77b, 0xf77c, 0xf77d, 0xf77e, 0xf77f,
    0xf780, 0xf781, 0xf782, 0xf783, 0xf784, 0xf785, 0xf786, 0xf787, 0xf788, 0xf789, 0xf78a, 0xf78b, 0xf78c, 0xf78d, 0xf78e, 0xf78f,
    0xf790, 0xf791, 0xf792, 0xf793, 0xf794, 0xf795, 0xf796, 0xf797, 0xf798, 0xf799, 0xf79a, 0xf79b, 0xf79c, 0xf79d, 0xf79e, 0xf79f,
    0xf7a0, 0xf7a1, 0xf7a2, 0xf7a3, 0xf7a4, 0xf7a5, 0xf7a6, 0xf7a7, 0xf7a8, 0xf7a9, 0xf7aa, 0xf7ab, 0xf7ac, 0xf7ad, 0xf7ae, 0xf7af,
    0xf7b0, 0xf7b1, 0xf7b2, 0xf7b3, 0xf7b4, 0xf7b5, 0xf7b6, 0xf7b7, 0xf7b8, 0xf7b9, 0xf7ba, 0xf7bb, 0xf7bc, 0xf7bd, 0xf7be, 0xf7bf,
    0xf7c0, 0xf7c1, 0xf7c2, 0xf7c3, 0xf7c4, 0xf7c5, 0xf7c6, 0xf7c7, 0xf7c8, 0xf7c9, 0xf7ca, 0xf7cb, 0xf7cc, 0xf7cd, 0xf7ce, 0xf7cf,
    0xf7d0, 0xf7d1, 0xf7d2, 0xf7d3, 0xf7d4, 0xf7d5, 0xf7d6, 0xf7d7, 0xf7d8, 0xf7d9, 0xf7da, 0xf7db, 0xf7dc, 0xf7dd, 0xf7de, 0xf7df,
    0xf7e0, 0xf7e1, 0xf7e2, 0xf7e3, 0xf7e4, 0xf7e5, 0xf7e6, 0xf7e7, 0xf7e8, 0xf7e9, 0xf7ea, 0xf7eb, 0xf7ec, 0xf7ed, 0xf7ee, 0xf7ef,
    0xf7f0, 0xf7f1, 0xf7f2, 0xf7f3, 0xf7f4, 0xf7f5, 0xf7f6, 0xf7f7, 0xf7f8, 0xf7f9, 0xf7fa, 0xf7fb, 0xf7fc, 0xf7fd, 0xf7fe, 0xf7ff,
};

static unsigned address_for_name(char *name)
{
    unsigned    address = INADDR_NONE;

    address = (name == NULL || *name == 0) ? INADDR_ANY : inet_addr(name);
    if(address == INADDR_NONE)
	{
        struct hostent *hostinfo = gethostbyname(name);
        if(hostinfo != NULL && (hostinfo->h_addr_list[0] != NULL))
		{
            address = *((unsigned*)hostinfo->h_addr_list[0]);
        }
    }
    return address;
}

static void socket_address(struct sockaddr_in *addr, NSString* host, int port)
{
    addr->sin_family = AF_INET;
    addr->sin_port = htons(port);
    addr->sin_addr.s_addr = address_for_name((char*)[host cString]);
}

@interface RFBConnection (Private)

- (void)connectionHasTerminated;

@end

@implementation RFBConnection

- (NSString *)perror:(NSString*)theAction call:(NSString*)theFunction
{
    NSString* s = [NSString stringWithFormat:@"%s: %@", strerror(errno), theFunction];
	NSLog(@"error: %@", s);
	return s;
}

+ (void)initialize {
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithFloat: 0.0], @"FrameBufferUpdateSeconds", nil];
	
	[standardUserDefaults registerDefaults: dict];
}

- (id)initWithServer:(ServerBase *)server profile:(Profile*)p view:(UIView<RFBViewProtocol> *)theView
{
    if (self = [super init])
	{
		server_ = [server retain];
		_profile = [p retain];
		rfbView = theView;
		
		if ((host = [server host]) == nil)
		{
			host = [DEFAULT_HOST retain];
		}
		else
		{
			[host retain];
		}
		
		// Have to do this after setting the profile, since the event filter gets
		// our profile in its setConnection: method.
		_eventFilter = [[EventFilter alloc] init];
		[_eventFilter setConnection: self];
	}
    return self;
}

- (void)dealloc
{
	[self terminateConnection: nil]; // just in case it didn't already get called somehow
	[self connectionHasTerminated];
    [super dealloc];
}

- (BOOL)openConnectionReturningError:(NSString **)errorMessage
{
	struct sockaddr_in	remote;
	int sock;
	int port;
	NSString * actionStr;
	
	// Start off assuming there will be no error.
	if (errorMessage)
	{
		*errorMessage = nil;
	}
	
	// Create the socket.
	if((sock = socket(PF_INET, SOCK_STREAM, 0)) < 0)
	{
		actionStr = NSLocalizedString( @"OpenConnection", nil );
		if (errorMessage)
		{
			*errorMessage = actionStr;
		}
		return NO;
	}
	
	// Check for a cancel request before doing the name lookup.
	if (_cancelConnect)
	{
		close(sock);
		return NO;
	}

	// Convert the host name to an address.
	port = (int)[server_ port] + [server_ display];
	socket_address(&remote, host, port);
	if (INADDR_NONE == remote.sin_addr.s_addr)
	{
		actionStr = NSLocalizedString( @"NoNamedServer", nil );
		if (errorMessage)
		{
			*errorMessage = [NSString stringWithFormat:actionStr, host, port];
		}
		close(sock);
		return NO;
	}
	
	// Check for a cancel request before connecting.
	if (_cancelConnect)
	{
		close(sock);
		return NO;
	}

	// Attempt to connect.
	if (connect(sock, (struct sockaddr *)&remote, sizeof(remote)) < 0)
	{
//			NSLog([self perror:@"" call:@"connect()"]);
		
		switch (errno)
		{
			case EADDRNOTAVAIL:
				actionStr = NSLocalizedString( @"NoNamedServer", nil );
				break;
			default:
				actionStr = NSLocalizedString( @"NoConnection", nil );
		}
		if (errorMessage)
		{
			*errorMessage = [NSString stringWithFormat:actionStr, host, port];
		}
		close(sock);
		return NO;
	}
	
	// Deal with a cancel.
	if (_cancelConnect)
	{
//		NSLog(@"canceled connect");
		close(sock);
		return NO;
	}
	
	// Create the file handle and return.
	socketHandler = [[NSFileHandle alloc] initWithFileDescriptor:sock closeOnDealloc:YES];
	_isOpen = YES;
	return YES;
}

- (void)startTalking
{
    versionReader = [[NLTStringReader alloc] initTarget:self action:@selector(setServerVersion:)];
    [self setReader:versionReader];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(readData:) 	name:nil /*NSFileHandleReadCompletionNotification*/ object:socketHandler];
    [socketHandler readInBackgroundAndNotify];
}

- (void)cancelConnect
{
//	NSLog(@"requesting cancel connect");
	_cancelConnect = YES;
}

- (BOOL)didCancelConnect
{
	return _cancelConnect;
}

- (void)setView:(UIView<RFBViewProtocol> *)theView
{
	rfbView = theView;
}

- (id)delegate
{
	return _delegate;
}

- (void)setDelegate:(id)theDelegate
{
	_delegate = theDelegate;
}

- (Profile*)profile
{
    return _profile;
}

- (ServerBase *)serverSettings
{
	return server_;
}

- (void)ringBell
{
//    NSBeep();
}

- (NSString*)serverVersion
{
    return serverVersion;
}

- (int) serverMajorVersion
{
	return serverMajorVersion;
}

- (int) serverMinorVersion
{
	return serverMinorVersion;
}

- (void)setReader:(ByteReader*)aReader
{
    currentReader = aReader;
	[frameBuffer setCurrentReaderIsTight: currentReader && [currentReader isKindOfClass: [TightEncodingReader class]]];
    [aReader resetReader];
}

- (void)setReaderWithoutReset:(ByteReader*)aReader
{
    currentReader = aReader;
}

- (void)setServerVersion:(NSString*)aVersion
{
	[serverVersion autorelease];
    serverVersion = [aVersion retain];
	sscanf([serverVersion cString], rfbProtocolVersionFormat, &serverMajorVersion, &serverMinorVersion);
	
    NSLog(@"Server reports Version %@\n", aVersion);
	// ARD sends this bogus 889 version#, at least for ARD 2.2 they actually comply with version 003.007 so we'll force that
	if (serverMinorVersion == 889) {
		NSLog(@"\tBogus RFB Protocol Version Number from AppleRemoteDesktop, switching to protocol 003.007\n");
		serverMinorVersion = 7;
	}
	
	[handshaker autorelease];
    handshaker = [[RFBHandshaker alloc] initTarget:self action:@selector(start:)];
    [self setReader:handshaker];
}

- (BOOL)isConnectionOpen
{
	return _isOpen;
}

- (void)connectionHasTerminated
{
	_isOpen = NO;
	
//	[rfbView setConnection:nil];
	[rfbView setFrameBuffer:nil];

	[socketHandler release];	socketHandler = nil;
	[_eventFilter release];		_eventFilter = nil;
	[versionReader release];	versionReader = nil;
	[handshaker release];		handshaker = nil;
	[(id)server_ release];		server_ = nil;
	[serverVersion release];	serverVersion = nil;
	[rfbProtocol release];		rfbProtocol = nil;
	[frameBuffer release];		frameBuffer = nil;
	[_profile release];			_profile = nil;
	[host release];				host = nil;
}

- (void)terminateConnection:(NSString*)aReason
{
    if (!terminating)
	{
		NSLog(@"terminating connection: %@", aReason);
		
        terminating = YES;

		[[NSNotificationCenter defaultCenter] removeObserver:self];
		[self cancelFrameBufferUpdateRequest];
		[self clearAllEmulationStates];
		[_eventFilter synthesizeRemainingEvents];
		[_eventFilter sendAllPendingQueueEntriesNow];
		
//		[self connectionHasTerminated];

		if (_delegate && [_delegate respondsToSelector:@selector(connection:hasTerminatedWithReason:)])
		{
			[_delegate connection:self hasTerminatedWithReason:aReason];
		}
		
//		[NSException raise:kConnectionTerminatedException format:@"connection terminated: %@", aReason];
    }
}

- (void)sendFullScreenRefresh
{
	[rfbProtocol requestUpdate:[self visibleRect] incremental:NO];
}

- (void)setDisplayName:(NSString *)name
{
	[rfbView setRemoteComputerName: name];
}

- (void)setDisplaySize:(CGSize)aSize andPixelFormat:(rfbPixelFormat*)pixf
{
	NSLog(@"remote display size={%g,%g}", aSize.width, aSize.height);
	
    id frameBufferClass;
    CGRect wf;
	CGRect screenRect;
	NSString *serverName;

    frameBufferClass = [[PrefController sharedController] defaultFrameBufferClass];
	[frameBuffer autorelease];
    frameBuffer = [[frameBufferClass alloc] initWithSize:aSize andFormat:pixf];
	[frameBuffer setServerMajorVersion: serverMajorVersion minorVersion: serverMinorVersion];
	
    [rfbView setFrameBuffer:frameBuffer];
	[rfbView setRemoteDisplaySize:aSize];
	
	[self setFrameBufferUpdateSeconds: [[PrefController sharedController] frontFrameBufferUpdateSeconds]];
	[self queueUpdateRequest];
}

- (CGSize)displaySize
{
    return [frameBuffer size];
}

- (void)start:(ServerInitMessage*)info
{
	[rfbProtocol autorelease];
    rfbProtocol = [[RFBProtocol alloc] initTarget:self serverInfo:info];
    [rfbProtocol setFrameBuffer:frameBuffer];
    [self setReader:rfbProtocol];
}

- (id)connectionHandle
{
    return socketHandler;
}

//! \note This method must be only called once, just after the object is created
//! and before communications has been initiated.
- (void)setConnectionHandle:(id)handle
{
	socketHandler = [handle retain];
	_isOpen = YES;
}

- (NSString*)password
{
    return [server_ password];
}

- (BOOL)connectShared
{
    return [server_ shared];
}

- (BOOL)viewOnly
{
	return [server_ viewOnly];
}

- (CGRect)visibleRect
{
    return [rfbView contentRect];
}

- (void)drawRectFromBuffer:(CGRect)aRect
{
//	NSLog(@"RFBConnection:drawRectFromBuffer:{%f,%f,%f,%f}", aRect.origin.x, aRect.origin.y, aRect.size.width, aRect.size.height);
    [rfbView displayFromBuffer:aRect];
}

- (void)drawRectList:(id)aList
{
	NSLog(@"RFBConnection:drawRectList:%@", aList);
    [rfbView drawRectList:aList];
//    [window flushWindow];
}

- (void)pauseDrawing
{
//    [window disableFlushWindow];
}

- (void)flushDrawing
{
//	if ([window isFlushWindowDisabled])
//		[window enableFlushWindow];
//    [window flushWindow];
    [self queueUpdateRequest];
}

- (void)readData:(NSNotification *)aNotification
{
//	fprintf(stderr, "readData:%s\n", [[aNotification description] cString]);

    NSData * data = [[aNotification userInfo] objectForKey:NSFileHandleNotificationDataItem];
    unsigned consumed;
	unsigned length = [data length];
    unsigned char * bytes = (unsigned char *)[data bytes];
//	NSLog(@"received %d bytes", length);

	// If we process slower than our requests, we don't autorelease until
	// we get a break, which could be never.
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    if (!length)
	{
		// server closed socket obviously
		NSString * reason = NSLocalizedString( @"ServerClosed", nil );
        [self terminateConnection:reason];
		[pool release];
        return;
    }
    
	while (length)
	{
		consumed = [currentReader readBytes:bytes length:length];
		length -= consumed;
		bytes += consumed;
		if (terminating)
		{
			[pool release];
			return;
		}
	}
	
    [socketHandler readInBackgroundAndNotify];
	[pool release];
}

- (void)_queueUpdateRequest
{
    if (!updateRequested)
	{
        updateRequested = TRUE;
		[self cancelFrameBufferUpdateRequest];
		if (_frameBufferUpdateSeconds > 0.0) {
			_frameUpdateTimer = [[NSTimer scheduledTimerWithTimeInterval: _frameBufferUpdateSeconds target: self selector: @selector(requestFrameBufferUpdate:) userInfo: nil repeats: NO] retain];
		} else {
			[self requestFrameBufferUpdate: nil];
		}
    }
}

- (void)queueUpdateRequest {
	if (! _hasManualFrameBufferUpdates)
		[self _queueUpdateRequest];
}

- (void)requestFrameBufferUpdate:(id)sender
{
	if ( terminating) return;
    updateRequested = FALSE;
	[rfbProtocol requestIncrementalFrameBufferUpdateForVisibleRect: nil];
}

- (void)cancelFrameBufferUpdateRequest
{
	[_frameUpdateTimer invalidate];
	[_frameUpdateTimer release];
	_frameUpdateTimer = nil;
    updateRequested = FALSE;
}

- (void)clearAllEmulationStates
{
	[_eventFilter clearAllEmulationStates];
	_lastMask = 0;
}

- (void)mouseAt:(CGPoint)thePoint buttons:(unsigned int)mask
{
    rfbPointerEventMsg msg;
//    CGRect b = [rfbView contentRect];
    CGSize s = [frameBuffer size];
	
    if(thePoint.x < 0) thePoint.x = 0;
    if(thePoint.y < 0) thePoint.y = 0;
    if(thePoint.x >= s.width) thePoint.x = s.width - 1;
    if(thePoint.y >= s.height) thePoint.y = s.height - 1;
    if((_mouseLocation.x != thePoint.x) || (_mouseLocation.y != thePoint.y) || (_lastMask != mask))
	{
//        NSLog(@"here %d:{%g,%g}", mask, thePoint.x, thePoint.y);
        _mouseLocation = thePoint;
		_lastMask = mask;
        msg.type = rfbPointerEvent;
        msg.buttonMask = mask;
        msg.x = htons((uint16_t)thePoint.x);
        msg.y = htons((uint16_t)thePoint.y);
        [self writeBytes:(unsigned char*)&msg length:sz_rfbPointerEventMsg];
    }
    [self queueUpdateRequest];
}

- (void)sendModifier:(unsigned int)m pressed: (BOOL)pressed
{
//	NSString *modifierStr =nil;
//	switch (m)
//	{
//		case NSShiftKeyMask:
//			modifierStr = @"NSShiftKeyMask";		break;
//		case NSControlKeyMask:
//			modifierStr = @"NSControlKeyMask";		break;
//		case NSAlternateKeyMask:
//			modifierStr = @"NSAlternateKeyMask";	break;
//		case NSCommandKeyMask:
//			modifierStr = @"NSCommandKeyMask";		break;
//		case NSAlphaShiftKeyMask:
//			modifierStr = @"NSAlphaShiftKeyMask";	break;
//	}
//	NSLog(@"modifier %@ %s", modifierStr, pressed ? "pressed" : "released");

    rfbKeyEventMsg msg;
	
    memset(&msg, 0, sizeof(msg));
    msg.type = rfbKeyEvent;
	msg.down = pressed;
	
	switch (m)
	{
		case NSShiftKeyMask:
			msg.key = htonl([_profile shiftKeyCode]);
			break;

		case NSControlKeyMask:
			msg.key = htonl([_profile controlKeyCode]);
			break;

		case NSAlternateKeyMask:
			msg.key = htonl([_profile altKeyCode]);
			break;

		case NSCommandKeyMask:
			msg.key = htonl([_profile commandKeyCode]);
			break;

		case NSAlphaShiftKeyMask:
			msg.key = htonl(CAPSLOCK);
			break;

		case NSHelpKeyMask:	// this is F1
			msg.key = htonl(F1_KEYCODE);
			break;

		// don't know how to handle, eat it
		case NSNumericPadKeyMask:
		default:
			return;
	}
	
	[self writeBytes:(unsigned char*)&msg length:sizeof(msg)];
}

- (void)sendKey:(unichar)c pressed:(BOOL)pressed
{
    rfbKeyEventMsg msg;
    int kc;

    memset(&msg, 0, sizeof(msg));
    msg.type = rfbKeyEvent;
    msg.down = pressed;
	if (c < 256)
	{
        kc = page0[c & 0xff];
    }
	else if((c & 0xff00) == 0xf700)
	{
        kc = pagef7[c & 0xff];
    }
	else
	{
		kc = c;
    }

	unichar _kc = (unichar)kc;
	NSString *keyStr = [NSString stringWithCharacters: &_kc length: 1];
	NSLog(@"key '%@' [c:0x%04x] [kc:0x%04x] %s", keyStr, c, kc, pressed ? "pressed" : "released");

	msg.key = htonl(kc);
    [self writeBytes:(unsigned char*)&msg length:sizeof(msg)];
}

- (void)sendCmdOptEsc: (id)sender
{
    rfbKeyEventMsg msg;
	
    memset(&msg, 0, sizeof(msg));
    msg.type = rfbKeyEvent;
    msg.down = YES;
	msg.key = htonl(kAltKeyCode);
    [self writeBytes:(unsigned char*)&msg length:sizeof(msg)];
    memset(&msg, 0, sizeof(msg));
    msg.type = rfbKeyEvent;
    msg.down = YES;
	msg.key = htonl(kMetaKeyCode);
    [self writeBytes:(unsigned char*)&msg length:sizeof(msg)];
    msg.type = rfbKeyEvent;
    msg.down = YES;
	msg.key = htonl(kEscapeKeyCode);
    [self writeBytes:(unsigned char*)&msg length:sizeof(msg)];
	
    memset(&msg, 0, sizeof(msg));
    msg.type = rfbKeyEvent;
    msg.down = NO;
	msg.key = htonl(kEscapeKeyCode);
    [self writeBytes:(unsigned char*)&msg length:sizeof(msg)];
    memset(&msg, 0, sizeof(msg));
    msg.type = rfbKeyEvent;
    msg.down = NO;
	msg.key = htonl(kMetaKeyCode);
    [self writeBytes:(unsigned char*)&msg length:sizeof(msg)];
    msg.type = rfbKeyEvent;
    msg.down = NO;
	msg.key = htonl(kAltKeyCode);
    [self writeBytes:(unsigned char*)&msg length:sizeof(msg)];
}

- (void)sendTabKey
{
	[self sendKey: kTabKeyCode  pressed:YES];
	[self sendKey: kTabKeyCode  pressed:NO];
}

- (void)sendFunctionKey: (unsigned)fkey
{
	[self sendKey: (unsigned)F0_KEYCODE+(unsigned)fkey pressed:YES];
	[self sendKey: (unsigned)F0_KEYCODE+(unsigned)fkey pressed:NO];
}

- (void)sendCtrlAltDel: (id)sender
{
    rfbKeyEventMsg msg;
	NSLog(@"Send CtrlAltDel");
	
    memset(&msg, 0, sizeof(msg));
    msg.type = rfbKeyEvent;
    msg.down = YES;
	msg.key = htonl(kControlKeyCode);
    [self writeBytes:(unsigned char*)&msg length:sizeof(msg)];
    memset(&msg, 0, sizeof(msg));
    msg.type = rfbKeyEvent;
    msg.down = YES;
	msg.key = htonl(kAltKeyCode);
    [self writeBytes:(unsigned char*)&msg length:sizeof(msg)];
    msg.type = rfbKeyEvent;
    msg.down = YES;
	msg.key = htonl(kDeleteKeyCode);
    [self writeBytes:(unsigned char*)&msg length:sizeof(msg)];
	
    memset(&msg, 0, sizeof(msg));
    msg.type = rfbKeyEvent;
    msg.down = NO;
	msg.key = htonl(kDeleteKeyCode);
    [self writeBytes:(unsigned char*)&msg length:sizeof(msg)];
    memset(&msg, 0, sizeof(msg));
    msg.type = rfbKeyEvent;
    msg.down = NO;
	msg.key = htonl(kAltKeyCode);
    [self writeBytes:(unsigned char*)&msg length:sizeof(msg)];
    msg.type = rfbKeyEvent;
    msg.down = NO;
	msg.key = htonl(kControlKeyCode);
    [self writeBytes:(unsigned char*)&msg length:sizeof(msg)];
}

- (void)sendPauseKeyCode: (id)sender
{
    rfbKeyEventMsg msg;
	
    memset(&msg, 0, sizeof(msg));
    msg.type = rfbKeyEvent;
    msg.down = YES;
	msg.key = htonl(kPauseKeyCode);
    [self writeBytes:(unsigned char*)&msg length:sizeof(msg)];
	
    memset(&msg, 0, sizeof(msg));
    msg.type = rfbKeyEvent;
    msg.down = NO;
	msg.key = htonl(kPauseKeyCode);
}

- (void)sendBreakKeyCode: (id)sender
{
    rfbKeyEventMsg msg;
	
    memset(&msg, 0, sizeof(msg));
    msg.type = rfbKeyEvent;
    msg.down = YES;
	msg.key = htonl(kBreakKeyCode);
    [self writeBytes:(unsigned char*)&msg length:sizeof(msg)];
	
    memset(&msg, 0, sizeof(msg));
    msg.type = rfbKeyEvent;
    msg.down = NO;
	msg.key = htonl(kBreakKeyCode);
}

- (void)sendPrintKeyCode: (id)sender
{
    rfbKeyEventMsg msg;
	
    memset(&msg, 0, sizeof(msg));
    msg.type = rfbKeyEvent;
    msg.down = YES;
	msg.key = htonl(kPrintKeyCode);
    [self writeBytes:(unsigned char*)&msg length:sizeof(msg)];
	
    memset(&msg, 0, sizeof(msg));
    msg.type = rfbKeyEvent;
    msg.down = NO;
	msg.key = htonl(kPrintKeyCode);
}

- (void)sendExecuteKeyCode: (id)sender
{
    rfbKeyEventMsg msg;
	
    memset(&msg, 0, sizeof(msg));
    msg.type = rfbKeyEvent;
    msg.down = YES;
	msg.key = htonl(kExecuteKeyCode);
    [self writeBytes:(unsigned char*)&msg length:sizeof(msg)];
	
    memset(&msg, 0, sizeof(msg));
    msg.type = rfbKeyEvent;
    msg.down = NO;
	msg.key = htonl(kExecuteKeyCode);
}

- (void)sendInsertKeyCode: (id)sender
{
    rfbKeyEventMsg msg;
	
    memset(&msg, 0, sizeof(msg));
    msg.type = rfbKeyEvent;
    msg.down = YES;
	msg.key = htonl(kInsertKeyCode);
    [self writeBytes:(unsigned char*)&msg length:sizeof(msg)];
	
    memset(&msg, 0, sizeof(msg));
    msg.type = rfbKeyEvent;
    msg.down = NO;
	msg.key = htonl(kInsertKeyCode);
}

- (void)sendDeleteKeyCode: (id)sender
{
    rfbKeyEventMsg msg;
	
    memset(&msg, 0, sizeof(msg));
    msg.type = rfbKeyEvent;
    msg.down = YES;
	msg.key = htonl(kDeleteKeyCode);
    [self writeBytes:(unsigned char*)&msg length:sizeof(msg)];
	
    memset(&msg, 0, sizeof(msg));
    msg.type = rfbKeyEvent;
    msg.down = NO;
	msg.key = htonl(kDeleteKeyCode);
}

- (id)frameBuffer
{
    return frameBuffer;
}

- (UIWindow *)window;
{
	return window;
}

- (EventFilter *)eventFilter
{
	return _eventFilter;
}

- (void)writeBytes:(unsigned char*)bytes length:(unsigned int)length
{
    int result;
    int written = 0;
	
	if (terminating)
	{
		return;
	}

    do {
//		NSData * d = [NSData dataWithBytesNoCopy:bytes+written length:length freeWhenDone:NO];
//		NSLog(@"writing %@", d);
		
//		NSLog(@"write(%d, %p, l=%d, w=%d)", [socketHandler fileDescriptor], bytes+written, length, written);
        result = write([socketHandler fileDescriptor], bytes + written, length);
//		NSLog(@"wrote %d bytes", result);
        
		if (result >= 0)
		{
            length -= result;
            written += result;
        }
		else
		{
            if (errno == EAGAIN)
			{
                continue;
            }
			NSLog(@"write:errno=%d", errno);
            
			if (errno == EPIPE)
			{
				NSString *reason = NSLocalizedString( @"ServerClosed", nil );
                [self terminateConnection:reason];
                return;
            }
			
			NSString *reason = NSLocalizedString( @"ServerError", nil );
			reason = [NSString stringWithFormat: reason, strerror(errno)];
            [self terminateConnection:reason];
            return;
        }
    } while(length > 0);
}

- (void)writeRFBString:(NSString *)aString
{
	unsigned int stringLength=htonl([aString cStringLength]);
	[self writeBytes:(unsigned char *)&stringLength length:4];
	[self writeBytes:(unsigned char *)[aString cString] length:[aString cStringLength]];
}

static NSString* byteString(double d)
{
    if(d < 10000) {
	return [NSString stringWithFormat:@"%u", (unsigned)d];
    } else if(d < (1024*1024)) {
	return [NSString stringWithFormat:@"%.2fKB", d / 1024];
    } else if(d < (1024*1024*1024)) {
	return [NSString stringWithFormat:@"%.2fMB", d / (1024*1024)];
    } else {
        return [NSString stringWithFormat:@"%.2fGB", d / (1024*1024*1024)];
    }
}

- (void)updateStatistics:(id)sender
{
    FrameBufferUpdateReader* reader = [rfbProtocol frameBufferUpdateReader];

//    [statisticField setStringValue:
//#ifdef COLLECT_STATS
	NSString * stats = [NSString stringWithFormat: @"Bytes Received: %@\nBytes Represented: %@\nCompression: %.2f\nRectangles: %u",
            byteString([reader bytesTransferred]), byteString([reader bytesRepresented]), [reader compressRatio],
            (unsigned)[reader rectanglesTransferred]
    	];
//#else
//	@"Statistic data collection\nnot enabled at compiletime"
//#endif
//    ];
	
	NSLog(@"%@", stats);
}

- (float)frameBufferUpdateSeconds {
	return _frameBufferUpdateSeconds;
}

- (void)setFrameBufferUpdateSeconds: (float)seconds {
	_frameBufferUpdateSeconds = seconds;
	_hasManualFrameBufferUpdates = _frameBufferUpdateSeconds >= [[PrefController sharedController] maxPossibleFrameBufferUpdateSeconds];
		
}

- (void)manuallyUpdateFrameBuffer: (id)sender
{
	[self _queueUpdateRequest];
}

- (void)connection:(RFBConnection *)connection hasTerminatedWithReason:(NSString *)reason
{
}
	
@end
