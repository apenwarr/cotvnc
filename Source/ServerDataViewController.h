/* ServerDataPanel */

#import <Cocoa/Cocoa.h>

@protocol IServerData;

@interface ServerDataViewController : NSWindowController
{
    IBOutlet NSTextField *display;
    IBOutlet NSTextField *hostName;
    IBOutlet NSSecureTextField *passWord;
    IBOutlet NSPopUpButton *profilePopup;
    IBOutlet NSButton *rememberPwd;
    IBOutlet NSButton *shared;
	
	id<IServerData> server_;
}

- (void)setServer:(id<IServerData>)server;
- (id<IServerData>)server;

- (void)hostChanged:(id)sender;
- (void)passwordChanged:(id)sender;
- (IBAction)rememberPwdChanged:(id)sender;
- (IBAction)displayChanged:(id)sender;
- (IBAction)profileSelectionChanged:(id)sender;
- (IBAction)sharedChanged:(id)sender;

- (void)controlTextDidEndEditing:(NSNotification*)notification;

@end
