//
//  viewtestViewController.m
//  viewtest
//
//  Created by Avery Pennarun on 2010-03-28.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "viewtestViewController.h"
#import "VNCView.h"

@implementation viewtestViewController

@synthesize web, urlbox, testlabel;



/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	CGRect rect = CGRectMake(0,0,480,320);
	UIView *v = [[VNCView alloc] initWithFrame:rect];
	self.view = v;
	[v setBackgroundColor:[UIColor redColor]];
	UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	button.frame = CGRectMake(100,300,100,50);
	[button setTitle:@"Hello World" forState:UIControlStateNormal];
	[self.view addSubview:button];
	
	ServerBase *serv = [ServerBase alloc];
	[serv setName:@"myserver"];
	[serv setHost:@"192.168.1.107"];
	[serv setPassword:@"scsscs"];
	[serv setDisplay:0];
	[serv setPort:5900];
#if 1
	RFBConnection *conn = [[RFBConnection alloc] initWithServer:serv profile:[Profile defaultProfile] view:v];
	NSString *msg = nil;
	[conn openConnectionReturningError:&msg];
	[conn setDelegate:self];
	[conn startTalking];
#endif
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	//[self urlChanged:self];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (IBAction)urlChanged: (id)sender {
	NSURL *url = [NSURL URLWithString:[urlbox text]];
	[testlabel setText:[url absoluteString]];
	NSURLRequest *req = [NSURLRequest requestWithURL:url];
	[web loadRequest:req];
	return;
}

- (void)dealloc {
    [super dealloc];
}

@end
