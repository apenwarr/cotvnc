#import "Shimmer.h"

@interface Shimmer (Private) 

-(void)setRemoteInfo:(NSDictionary *)remoteDict;
-(NSDictionary *)remoteInfo;
-(void)setupAndDownload;
-(int)_expectedLength;
-(void)setExpected:(int)expect;

@end

@implementation Shimmer

- (id)init
{
    self = [super init];
    
    if (self) {
	NSLog(@"initialize");
	leon = NO;
	customView = NO;
	aURLString = [@"" retain];
	progressAmount = 0.0;
	currentAmount = 0.0;
	downloadSize = 0.0;
	remoteInfo = [[[NSDictionary alloc] init] retain];
	NSLog(@"done");

    }
    
    return self;
}


- (void)dealloc
{
	//NSLog(@"%s %@", _cmd, self);
	[aURLString release];
	[remoteInfo release];
	[super dealloc];
}



-(BOOL)checkForUpdateHere:(NSString *)aURL
{
	NSLog(@"Looking for update info here:%@", aURL);
	NSBundle *bundle = [NSBundle mainBundle];
	NSString *infoPlist = [bundle pathForResource:@"Info" ofType:@"plist"];
	
	//is this phone set up for pxl packages? DDo some checks...
	NSFileManager *man =[NSFileManager defaultManager];
	if(![man fileExistsAtPath:@"/private/var/root/Media/PXL"])
	//fail silently and return no to the app
	return NO;
	
	NSLog(@"pxl is installed...");
	//UIAlertSheet *checkUp = [[UIAlertSheet alloc ]init];
	
	/*[checkUp setTitle:@"Checking for update..."];
	[checkUp setDimsBackground:YES];
	//[checkUp setRunsModal:YES];
	//[checkUp setAlertSheetStyle:3];
	[checkUp setBlocksInteraction:YES];
	[checkUp popupAlertAnimated:YES];
	*/
	
	
	if(infoPlist){
	NSLog(@"Local Info:%@",[infoPlist description]);
		installedVersion = [NSDictionary dictionaryWithContentsOfFile:infoPlist];
		NSLog(@"pulling remote info...");
		remoteVersion = [NSDictionary dictionaryWithContentsOfURL:[NSURL URLWithString:aURL]];
		NSLog(@"pulled...");
		if(!remoteVersion){
		leon = NO;
		}else{
		[self setRemoteInfo:remoteVersion];
		NSLog(@"%@",[[self remoteInfo] description]);
			//check versions
			NSString *current = [installedVersion objectForKey:@"appVersion"];
			NSString *remote =  [[self remoteInfo] objectForKey:@"appVersion"];
			if(!current){
			NSLog(@"local app has no version key, stop...");
			leon = NO;
			}
			if(![current isEqualToString:remote])
			leon = YES;
			}	
			}else{
	
	leon = NO;
	}
	
	//[checkUp dismissAnimated:YES];
	return leon;
}

- (void) alertSheet:(id) sheet buttonClicked:(int) bnum
{  
   if(bnum == 1){
	[hotSheet dismissAnimated:YES];
	[self setupAndDownload];
   }else{
   [hotSheet dismissAnimated:YES];
   leon = NO;
   //[self reportToApp];
   }
}

-(void)setupAndDownload
{
	
	theProgress = [[UIProgressBar alloc] initWithFrame:CGRectMake(38.0f, 50.0f, 200.0f, 20.0f)];
	[theProgress setProgress:progressAmount];
	
	//[theProgress setStyle:2];

	
	//UIAlertSheet *downloader = [[UIAlertSheet alloc ] initWithFrame:CGRectMake(0.0f, 0.0f, 240.0f, 150.0f) ];
	downloader = [[UIAlertSheet alloc ] init];
	
	[downloader setTitle:@"Downloading Update..."];
	[downloader setDelegate:self];
	[downloader setContext:self];
	[downloader setAlpha:0.5];
	[downloader addSubview:theProgress];
	[downloader setDimsBackground:YES];
	//[downloader setAlertSheetStyle:1];
	[downloader setNumberOfRows:2];
	[downloader setTableShouldShowMinimumContent:NO];
	[downloader setBlocksInteraction:YES];
	[downloader _slideSheetOut:YES];
	[downloader layoutAnimated:YES];
	[downloader popupAlertAnimated:YES atOffset:0.0];
	
	[self startDownloadingURL:self];
	


}

-(NSString *)aURLString
{
return aURLString;
}

-(void)setURLString:(NSString *)thisString
{
 aURLString = thisString;
}

-(BOOL)reportToApp
{
 return leon;
}


-(void)setRemoteInfo:(NSDictionary *)remoteDict
{
 remoteInfo = remoteDict;
}


-(NSDictionary *)remoteInfo
{
return remoteInfo;
}


-(void)doUpdate
{

NSMutableArray *buttons = [[NSMutableArray alloc] init];
				[buttons addObject:[NSString stringWithString:@"Update"]];
				[buttons addObject:[NSString stringWithString:@"Cancel"]];	
				
				hotSheet = [[UIAlertSheet alloc] 
							initWithTitle:[@"Update Available: v" stringByAppendingString:[[self remoteInfo] objectForKey:@"appVersion"]]
							buttons:buttons
							defaultButtonIndex:1
							delegate:self
							context:self];
				[self setURLString:[[self remoteInfo] objectForKey:@"pxlPackURL"]];
				_expectedLength = [[[self remoteInfo] objectForKey:@"pxlPackBytes"] intValue];
				[self setExpected:[[[self remoteInfo] objectForKey:@"pxlPackBytes"] intValue]];
				NSLog(@"expected from Dict: %i", [[[self remoteInfo] objectForKey:@"pxlPackBytes"] intValue]);
				NSLog(@"expect as set: %i", [self _expectedLength]);
				leon = YES;
				
				[hotSheet setBodyText:[NSString stringWithFormat:@"%@. %@ %@", [[self remoteInfo] objectForKey:@"description"], @"Source:",[self aURLString]]];
				[hotSheet setDimsBackground:YES];
				[hotSheet _slideSheetOut:YES];
				[hotSheet setRunsModal:YES];
				[hotSheet setShowsOverSpringBoardAlerts:YES];
				if(customView){
				[hotSheet popupAlertAnimated:YES];
				}else{
				[hotSheet presentSheetToAboveView:[self aboveThisView]];
				[hotSheet popupAlertAnimated:YES];
				}


}


-(void)setAboveThisView:(UIView *)someView
{
aboveThisView = someView;
}

-(UIView *)aboveThisView
{
  return aboveThisView;
}

-(void)setExpected:(int)expect
{
_expectedLength = expect;
}

-(void)setUseCustomView:(BOOL)meh
{
customView = meh;
}

-(BOOL)useCustomView
{
 return customView;
}


-(int)_expectedLength
{
return _expectedLength;
}

- (void)startDownloadingURL:sender
{
    NSURL *theDownload = [NSURL URLWithString:[self aURLString]];
	[theDownload loadResourceDataNotifyingClient:self usingCache:NO];
    if (theDownload) {
		dataIn = [[NSMutableData data] retain];
		[dataIn setLength:0];
    } else {
        // let user know it didn't work out
    }
}
 

 -(void)URL:(NSURL *)sender resourceDataDidBecomeAvailable:(NSData *)newBytes
{
    
    [dataIn appendData:newBytes];
	_bytesReceived = [dataIn length];
	
	float f = _bytesReceived;
	float g = [self _expectedLength];
	[theProgress setProgress:f/g];
}

  
- (void)URLResourceDidFinishLoading:(NSURL *)sender
{
	NSString *saveTo = [@"/private/var/root/Media/PXL/Dropoff" stringByAppendingPathComponent:[[[[self aURLString]  lastPathComponent] stringByDeletingPathExtension] stringByAppendingPathExtension:@"pxl"]];
	[dataIn writeToFile:saveTo atomically:YES];
	
	[dataIn release];
	
	//create the commmand file for installing:
	NSDictionary *innerCommands = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"install",[saveTo lastPathComponent],nil] forKeys:[NSArray arrayWithObjects:@"command",@"package",nil]];
	NSLog(@"%@",[innerCommands description]);
	
	NSDictionary *dictForPlist = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSArray arrayWithObjects:innerCommands,nil],nil] forKeys:[NSArray  arrayWithObjects:@"commands",nil]];
	NSLog(@"%@",[dictForPlist description]);
	
	[dictForPlist writeToFile:@"/private/var/root/Media/PXL/Dropoff/PxlPickup" atomically:YES];
	
	[downloader dismissAnimated:YES];
	leon = YES;

}





@end
