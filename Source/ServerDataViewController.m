#import "ServerDataViewController.h"
#import "IServerData.h"

@implementation ServerDataViewController

- (void)setServer:(id<IServerData>)server
{
	[(id)server_ release];
	server_ = server;
	[(id)server_ retain];
	
	// Set default values
	// Is this really necessary for anything other than password or should it only happen
	// if currentServer is nil? - Jared
	[hostName setStringValue:@""];
    [passWord setStringValue:@""];
    [rememberPwd setIntValue:0];
    [display setStringValue:@""];
    [shared setIntValue:0];
	
	// Set properties in dialog box
    if (server_ != nil)
	{
        [rememberPwd setIntValue:[server_ rememberPassword]];
        [display setIntValue:[server_ display]];
        [shared setIntValue:[server_ shared]];
		[hostName setStringValue:[server_ host]];
        if ([server_ rememberPassword])
		{
            [passWord setStringValue:[server_ password]];
        }
    }
}

- (id<IServerData>)server
{
	return server_;
}

- (void)controlTextDidEndEditing:(NSNotification*)notification
{
	if( [notification object] == display )
	{
		[self displayChanged:display];
	}
	else if( [notification object] == passWord )
	{
		[self passwordChanged:passWord];
	}
	else if( [notification object] == hostName )
	{
		[self hostChanged:hostName];
	}
}

- (void)hostChanged:(id)sender
{
	if( nil != server_ )
	{
		[server_ setHost:[sender stringValue]];
	}
}

- (void)passwordChanged:(id)sender
{
	if( nil != server_ )
	{
		[server_ setPassword:[sender stringValue]];
	}
}

- (IBAction)rememberPwdChanged:(id)sender
{
	if( nil != server_ )
	{
		[server_ setRememberPassword:![server_ rememberPassword]];
	}
}

- (IBAction)displayChanged:(id)sender
{
	if( nil != server_ )
	{
		[server_ setLastDisplay:[server_ display]];
		[server_ setDisplay:[sender intValue]];
	}
}

- (IBAction)profileSelectionChanged:(id)sender
{
	if( nil != server_ )
	{
		[server_ setLastProfile:[sender stringValue]];
	}
}

- (IBAction)sharedChanged:(id)sender
{
	if( nil != server_ )
	{
		[server_ setShared:![server_ shared]];
	}
}

@end
