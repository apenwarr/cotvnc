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

@implementation ServerBase

- (id)init
{
	if( self = [super init] )
	{
		_name =             [[NSString stringWithString:@"new server"] retain];
		_host =             [[NSString stringWithString:@"localhost"] retain];
		_password =         [[NSString alloc] init];
		_rememberPassword = NO;
		_display =          0;
		_lastDisplay =      0;
		_lastProfile =      [[NSString alloc] init];
		_shared =           NO;
		_fullscreen =       NO;
	}
	
	return self;
}

- (void)dealloc
{
	[_name release];
	[_password release];
}

- (NSString*)name
{
	return _name;
}

- (NSString*)host
{
	return _host;
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

- (int)lastDisplay
{
	return _lastDisplay;
}

- (bool)shared
{
	return _shared;
}

- (bool)fullscreen
{
	return _fullscreen;
}

- (NSString*)lastProfile
{
	return _lastProfile;
}

- (void)setName: (NSString*)name
{
	if( nil != name )
	{
		[_name release];
		_name = name;
		[_name retain];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:ServerChangeMsg
															object:self];
	}
}

- (void)setHost: (NSString*)host
{
	if( nil != host )
	{
		[_host release];
		_host = host;
		[_host retain];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:ServerChangeMsg
															object:self];
	}
}

- (void)setPassword: (NSString*)password
{
	if( nil != password )
	{
		[_password release];
		_password = password;
		[_password retain];
	
		[[NSNotificationCenter defaultCenter] postNotificationName:ServerChangeMsg
															object:self];
	}
}

- (void)setRememberPassword: (bool)rememberPassword
{
	_rememberPassword = rememberPassword;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:ServerChangeMsg
														object:self];
}

- (void)setDisplay: (int)display
{
	_display = display;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:ServerChangeMsg
														object:self];
}

- (void)setLastDisplay: (int)lastDisplay
{
	_lastDisplay = lastDisplay;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:ServerChangeMsg
														object:self];
}

- (void)setShared: (bool)shared
{
	_shared = shared;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:ServerChangeMsg
														object:self];
}

- (void)setFullscreen: (bool)fullscreen
{
	_fullscreen =  fullscreen;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:ServerChangeMsg
														object:self];
}

- (void)setLastProfile: (NSString*)lastProfile
{
	if( nil != lastProfile )
	{
		[_lastProfile release];
		_lastProfile = lastProfile;
		[_lastProfile retain];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:ServerChangeMsg
															object:self];
	}
}

- (void)setDelegate: (id<IServerDataDelegate>)delegate
{
	_delegate = delegate;
}

@end
