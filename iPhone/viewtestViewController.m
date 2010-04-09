//
//  viewtestViewController.m
//  viewtest
//
//  Created by Avery Pennarun on 2010-03-28.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "viewtestViewController.h"
#import "ServerBase.h"
#import "RFBConnection.h"
#import "VNCContentView.h"

@implementation viewtestViewController

//@synthesize web, urlbox, testlabel;



// Implement loadView to create a view hierarchy programmatically,
// without using a nib.
- (void)loadView {
    CGRect rect = [[UIScreen mainScreen] bounds]; //CGRectMake(0,0,100,100);
    UIView *v = [[VNCContentView alloc] initWithFrame:rect];
    self.view = v;
    [v setBackgroundColor:[UIColor redColor]];
    
    ServerBase *serv = [ServerBase alloc];
    [serv setName:@"myserver"];
    [serv setHost:@"192.168.1.107"];
    [serv setPassword:@"scsscs"];
    [serv setDisplay:0];
    [serv setPort:5900];
    
    RFBConnection *conn = [[RFBConnection alloc] 
			   initWithServer:serv 
			   profile:[Profile defaultProfile]
			   view:v];
    NSString *msg = nil;
    [conn openConnectionReturningError:&msg];
    [conn setDelegate:self];
    [conn startTalking];
}


// Implement viewDidLoad to do additional setup after loading the
// view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)o {
    //return (o == UIInterfaceOrientationPortrait);
    return YES;
}


- (void)dealloc {
    [super dealloc];
}

@end
