#import "ServerDataViewController.h"
#import "IServerData.h"

@implementation ServerDataViewController

- (id)init
{
	if (self = [super init])
	{
		[NSBundle loadNibNamed:@"ServerDisplay.nib" owner:self];
		
		[box setBorderType:NSNoBorder];
		delegate_ = nil;
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
		[passWord setStringValue:[server_ password]];
    }
}

- (id<IServerData>)server
{
	return server_;
}

- (void)setConnectionDelegate:(id)delegate
{
	delegate_ = delegate;
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

- (NSBox*)box
{
	return box;
}

- (IBAction)connectToServer:(id)sender
{
	[connectIndicator startAnimation:self];
	[connectIndicatorText setHidden:NO];
	
	if( nil != delegate_ )
	{
		[delegate_ connect:server_];
	}
	
	[connectIndicator stopAnimation:self];
	[connectIndicatorText setHidden:YES];
}

@end
