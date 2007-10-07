//
//  ServerFromPrefs.m
//  Chicken of the VNC
//
//  Created by Jared McIntyre on Sat Jan 24 2004.
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
//

#import "ServerFromPrefs.h"
#import "IServerData.h"
//#import "ProfileManager.h"
//#import "ProfileDataManager.h"

@implementation ServerBase

- (id)init
{
	if( self = [super init] )
	{
		// The order of remember password setting and password is critical, or we risk loosing
		// saved passwords.
		[self setName:            [NSString stringWithString:@"new server"]];
		[self setHostAndPort:     [NSString stringWithString:@"localhost"]];
		[self setRememberPassword:NO];
		[self setPassword:        [NSString stringWithString:@""]];
		[self setDisplay:         0];
		[self setPort:            5900];
		[self setLastProfile:     @"default"]; //[NSString stringWithString:[[ProfileDataManager sharedInstance] defaultProfileName]]];
		[self setPixelDepth: 32];
		[self setShared:          NO];
		[self setFullscreen:      NO];
		[self setViewOnly:      NO];

	}
	
	return self;
}

- (void)dealloc
{
	[_name release];
	[_host release];
	[_hostAndPort release];
	[_password release];
	[_lastProfile release];
	[super dealloc];
}

- (bool)doYouSupport: (SUPPORT_TYPE)type
{
	// subclasses are fully responsible for implementing this
//	assert(0);
	
	return NO;
}

- (NSString*)name
{
	return _name;
}

- (NSString*)host
{
	return _host;
}

- (NSString *)hostAndPort
{
	return _hostAndPort;
}

- (NSString*)password
{
	return _password;
}

- (bool)rememberPassword
{
	return _rememberPassword;
}

- (int)display
{
	return _display;
}

- (bool)isPortSpecifiedInHost
{
	return ! [_host isEqualToString: _hostAndPort];
}

- (int)port
{
	return _port;
}

- (bool)shared
{
	return _shared;
}

- (bool)fullscreen
{
	return _fullscreen;
}

- (bool)viewOnly
{
	return _viewOnly;
}

- (NSString*)lastProfile
{
	return _lastProfile;
}

- (void)setName: (NSString*)name
{
	[_name autorelease];
	if( nil != name )
	{
		_name = [name retain];
	}
	else
	{
		_name = [[NSString stringWithString:@"localhost"] retain];
	}
	
//	[[NSNotificationCenter defaultCenter] postNotificationName:ServerChangeMsg
//														object:self];
}

- (void)setHost: (NSString*)host
{
	[_host autorelease];
	if( nil != host )
	{
		_host = [host retain];
	}
	else
	{
		_host = [[NSString stringWithString:@"new server"] retain];
	}
	
//	[[NSNotificationCenter defaultCenter] postNotificationName:ServerChangeMsg
//														object:self];
}

- (void)setHostAndPort: (NSString*)hostAndPort
{
	BOOL portWasSpecifiedInHost = [self isPortSpecifiedInHost];
	
	[_hostAndPort autorelease];
	if( nil != hostAndPort )
	{
		_hostAndPort = [hostAndPort retain];
		
		NSArray *items = [hostAndPort componentsSeparatedByString:@":"];
		[self setHost: [items objectAtIndex: 0]];
		if ( [self isPortSpecifiedInHost] )
			[self setPort: [[items objectAtIndex: 1] intValue]];
		else if ( portWasSpecifiedInHost )
			[self setPort: 5900];
	}
	else
	{
		_hostAndPort = [_host copy];
	}
	
//	[[NSNotificationCenter defaultCenter] postNotificationName:ServerChangeMsg
//														object:self];
}

- (void)setPassword: (NSString*)password
{
	[_password autorelease];
	
	if( nil != password )
	{
		_password = [password retain];
	}
	else
	{
		_password = [[NSString stringWithString:@""] retain];
	}
	
//	[[NSNotificationCenter defaultCenter] postNotificationName:ServerChangeMsg
//														object:self];
}

- (void)setRememberPassword: (bool)rememberPassword
{
	_rememberPassword = rememberPassword;
	
//	[[NSNotificationCenter defaultCenter] postNotificationName:ServerChangeMsg
//														object:self];
}

- (void)setDisplay: (int)display
{
	_display = display;
//	[self setPort: _display + 5900];
	
//	[[NSNotificationCenter defaultCenter] postNotificationName:ServerChangeMsg
//														object:self];
}

- (void)setShared: (bool)shared
{
	_shared = shared;
	
//	[[NSNotificationCenter defaultCenter] postNotificationName:ServerChangeMsg
//														object:self];
}

- (void)setPort: (int)port
{
	_port = port;
	
//	[[NSNotificationCenter defaultCenter] postNotificationName:ServerChangeMsg
//														object:self];
}

- (void)setFullscreen: (bool)fullscreen
{
	_fullscreen =  fullscreen;
	
//	[[NSNotificationCenter defaultCenter] postNotificationName:ServerChangeMsg
//														object:self];
}

- (void)setViewOnly: (bool)viewOnly
{
	_viewOnly = viewOnly;
	
//	[[NSNotificationCenter defaultCenter] postNotificationName:ServerChangeMsg
//														object:self];
}

- (void)setLastProfile: (NSString*)lastProfile
{
	[_lastProfile autorelease];
	_lastProfile = lastProfile;
//	[[NSNotificationCenter defaultCenter] postNotificationName:ServerChangeMsg
//														object:self];
}

- (int)pixelDepth
{
	return _pixelDepth;
}

- (void)setPixelDepth:(int)depth
{
	_pixelDepth = depth;
}

- (void)getPixelFormat:(rfbPixelFormat*)format
{
    format->bigEndian = [FrameBuffer bigEndian];
    format->trueColour = YES;
    switch (_pixelDepth)
	{
        case 0:
            break;
			
        case 8:
            format->bitsPerPixel = 8;
            format->depth = 8;
            format->redMax = format->blueMax = 7;
			format->greenMax = 3;
			
			// RGB 3:2:3
            format->redShift = 5;
            format->greenShift = 3;
            format->blueShift = 0;
            break;
			
        case 16:
            format->bitsPerPixel = 16;
            format->depth = 16;
            format->redMax = format->blueMax = 31;
			format->greenMax = 63;
			
            if (format->bigEndian)
			{
				// RGB 5:6:5
                format->redShift = 11;
                format->greenShift = 5;
                format->blueShift = 0;
            }
			else
			{
				// RGB 5:6:5
                format->redShift = 0;
                format->greenShift = 5;
                format->blueShift = 11;
            }
            break;
			
        case 32:
            format->bitsPerPixel = 32;
            format->depth = 24;
            format->redMax = format->greenMax = format->blueMax = 255;
			
            if (format->bigEndian)
			{
				// ARGB 8:8:8:8
                format->redShift = 16;
                format->greenShift = 8;
                format->blueShift = 0;
            }
			else
			{
				// RGBA ?
                format->redShift = 0;
                format->greenShift = 8;
                format->blueShift = 16;
            }
            break;
    }
}

- (void)copyServer: (id)server
{
	
	[self setHostAndPort:[server hostAndPort]];
	// remember password must come before setting the password (in case a root class
	// needs to do appropriate save logic
	[self setRememberPassword:[server rememberPassword]];
	[self setPassword:[server password]];
	[self setDisplay:[(ServerBase *)server display]];
	[self setPort:(int)[server port]];
	[self setShared:[server shared]];
	[self setFullscreen:[server fullscreen]];
	[self setViewOnly:[server viewOnly]];
	[self setLastProfile:[server lastProfile]];
}

- (bool)addToServerListOnConnect
{
	return NO;
}

- (void)setAddToServerListOnConnect: (bool)addToServerListOnConnect
{
	// Do nothing
//	assert(0);
}

@end
