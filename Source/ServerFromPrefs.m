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

@implementation ServerFromPrefs

- (id)initWithPreferenceDictionary:(NSDictionary*)prefDict
{
    if( self = [super init] )
	{
		[self setName:             [prefDict objectForKey:RFB_NAME]];
		[self setHostAndPort:      [prefDict objectForKey:RFB_HOSTANDPORT]];
		[self setPassword:         [prefDict objectForKey:RFB_PASSWORD]];
		[self setRememberPassword:[[prefDict objectForKey:RFB_REMEMBER] intValue] == 0 ? NO : YES];
		[self setDisplay:         [[prefDict objectForKey:RFB_DISPLAY] intValue]];
		[self setLastProfile:      [prefDict objectForKey:RFB_LAST_PROFILE]];
		[self setPixelDepth:		[[prefDict objectForKey:RFB_PIXEL_DEPTH] intValue]];
		[self setShared:          [[prefDict objectForKey:RFB_SHARED] intValue] == 0 ? NO : YES];
		[self setFullscreen:      [[prefDict objectForKey:RFB_FULLSCREEN] intValue] == 0 ? NO : YES];
		[self setViewOnly:        [[prefDict objectForKey:RFB_VIEWONLY] intValue] == 0 ? NO : YES];
	}
	
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

- (bool)doYouSupport: (SUPPORT_TYPE)type
{
	switch( type )
	{
		case EDIT_ADDRESS:
		case EDIT_PORT:
		case EDIT_NAME:
		case EDIT_PASSWORD:
		case SAVE_PASSWORD:
		case CONNECT:
		case DELETE:
		case SERVER_SAVE:
			return YES;
		case ADD_SERVER_ON_CONNECT:
			return NO;
//		default:
//			// handle all cases
//			assert(0);
	}
	
	return NO;
}

@end
