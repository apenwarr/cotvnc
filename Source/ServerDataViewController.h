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
	IBOutlet NSBox *box;
	
	IBOutlet NSProgressIndicator *connectIndicator;
	IBOutlet NSTextField *connectIndicatorText;
	
	id<IServerData> server_;
	id delegate_;
}

- (void)setServer:(id<IServerData>)server;
- (id<IServerData>)server;

- (void)setConnectionDelegate:(id)delegate;

- (void)hostChanged:(id)sender;
- (void)passwordChanged:(id)sender;
- (IBAction)rememberPwdChanged:(id)sender;
- (IBAction)displayChanged:(id)sender;
- (IBAction)profileSelectionChanged:(id)sender;
- (IBAction)sharedChanged:(id)sender;
- (IBAction)connectToServer:(id)sender;

- (NSBox*)box;

- (void)controlTextDidEndEditing:(NSNotification*)notification;

@end
