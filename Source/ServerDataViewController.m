//
//  ServerFromPrefs.h
//  Chicken of the VNC
//
//  Created by Jared McIntyre on Sun May 1 2004.
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


#import "ServerDataViewController.h"
#import "IServerData.h"

@implementation ServerDataViewController

- (id)init
{
	if (self = [super init])
	{
		[NSBundle loadNibNamed:@"ServerDisplay.nib" owner:self];
		
		[connectIndicatorText setStringValue:@""];
		[box setBorderType:NSNoBorder];
	}
	
	return self;
}

- (id)initWithServer:(id<IServerData>)server
{
	if (self = [self init])
	{
		[self setServer:server];
	}
	
	return self;
}

- (void)setServer:(id<IServerData>)server
{
	[(id)mServer autorelease];
	mServer = [(id)server retain];
	
	// Set default values
    [password setStringValue:@""];
	
	// Set properties in dialog box
    if (mServer != nil)
	{
		[hostName setStringValue:[mServer host]];
		[password setStringValue:[mServer password]];
        [rememberPwd setIntValue:[mServer rememberPassword]];
        [display setIntValue:[mServer display]];
        [shared setIntValue:[mServer shared]];
		[profilePopup selectItemWithTitle:[mServer lastProfile]];
    }
	else
	{
		[hostName setStringValue:@""];
		[rememberPwd setIntValue:0];
		[display setStringValue:@""];
		[shared setIntValue:0];
		[profilePopup selectItemAtIndex:0]; 
	}
}

- (id<IServerData>)server
{
	return mServer;
}

- (void)setConnectionDelegate:(id)delegate
{
	mDelegate = delegate;
}

- (void)controlTextDidEndEditing:(NSNotification*)notification
{
	if( [notification object] == display )
	{
		[self displayChanged:display];
	}
	else if( [notification object] == password )
	{
		[self passwordChanged:password];
	}
	else if( [notification object] == hostName )
	{
		[self hostChanged:hostName];
	}
}

- (void)hostChanged:(id)sender
{
	if( nil != mServer )
	{
		[mServer setHost:[sender stringValue]];
	}
}

- (void)passwordChanged:(id)sender
{
	if( nil != mServer )
	{
		[mServer setPassword:[sender stringValue]];
	}
}

- (IBAction)rememberPwdChanged:(id)sender
{
	if( nil != mServer )
	{
		[mServer setRememberPassword:![mServer rememberPassword]];
	}
}

- (IBAction)displayChanged:(id)sender
{
	if( nil != mServer )
	{
		[mServer setLastDisplay:[mServer display]];
		[mServer setDisplay:[sender intValue]];
	}
}

- (IBAction)profileSelectionChanged:(id)sender
{
	if( nil != mServer )
	{
		[mServer setLastProfile:[sender stringValue]];
	}
}

- (IBAction)sharedChanged:(id)sender
{
	if( nil != mServer )
	{
		[mServer setShared:![mServer shared]];
	}
}

- (NSBox*)box
{
	return box;
}

- (IBAction)connectToServer:(id)sender
{
	[connectIndicator startAnimation:self];
	[connectIndicatorText setStringValue:NSLocalizedString(@"Connecting...", @"Connect in process notification string")];
	[connectIndicatorText display];
	
	[mDelegate connect:mServer];
	
	[connectIndicator stopAnimation:self];
	[connectIndicatorText setStringValue:@""];
	[connectIndicatorText display];
}

@end
