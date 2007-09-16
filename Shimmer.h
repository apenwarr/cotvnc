/*
Shimmer - PXL auto update for iPhone MobileApplications
©2007 RnSK/Kai Cherry for the PXL Project http://pxl.googlecode.com

Shimmer is free to use in any kind of app whatsoever, open or closed sourse, assuming the license you are using allows for the following:

1. Please attribute the project in your documentation. The notice is in the Shimmer.h header. Its not neccessary to do so in your app if you don't want to.

2. Please don't change the Shimmer class. If you need to add functionality, consider a subclass. Your subclass is your own...make a million if you can ;)

3. If you need to fix something in the Shimmer class, just give us the fixes so it sucks less for everyone else too.

4. That none of the above cannot be superseded by any other license you choose to use.

If you require a different license, please contact us.

*/

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIAlertSheet.h>
#import <UIKit/UIWindow.h>
#import <UIKit/UIHardware.h>
#import <UIKit/UIProgressBar.h>

	
@interface Shimmer : NSObject {		
	
	BOOL leon, customView;
	NSDictionary *installedVersion;
	NSDictionary *remoteVersion, *remoteInfo;
	NSString *aURLString;
	NSMutableData *dataIn;
	UIAlertSheet *hotSheet;
	UIProgressBar *theProgress;
	UIView *aboveThisView;
	UIAlertSheet *downloader;
	float progressAmount, downloadSize, currentAmount;
	int	_bytesReceived;
	int	_expectedLength;

}

-(BOOL)checkForUpdateHere:(NSString *)aURL;
-(void)doUpdate;
-(void)setAboveThisView:(UIView *)someView;
-(UIView *)aboveThisView;

-(void)setUseCustomView:(BOOL)meh;
-(BOOL)useCustomView;

- (void)startDownloadingURL:sender;

-(NSString *)aURLString;
-(void)setURLString:(NSString *)thisString;

@end
