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

//@synthesize web, urlbox, testlabel;



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
#if 1
- (void)loadView {
    CGRect rect = [[UIScreen mainScreen] bounds]; //CGRectMake(0,0,100,100);
    UIView *v = [[VNCView alloc] initWithFrame:rect];
    self.view = v;
    [v setBackgroundColor:[UIColor redColor]];
	#if 0
	UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(100,300,100,50);
    [button setTitle:@"Hello World" forState:UIControlStateNormal];
    [self.view addSubview:button];
	#endif
    
    ServerBase *serv = [ServerBase alloc];
    [serv setName:@"myserver"];
    [serv setHost:@"192.168.1.107"];
    [serv setPassword:@"scsscs"];
    [serv setDisplay:0];
    [serv setPort:5900];
    
    RFBConnection *conn = [[RFBConnection alloc] initWithServer:serv profile:[Profile defaultProfile] view:v];
    NSString *msg = nil;
    [conn openConnectionReturningError:&msg];
    [conn setDelegate:self];
    [conn startTalking];
}
#endif



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

#if 0
    //[self urlChanged:self];
    UIScrollView *sv = (UIScrollView *)self.view;
    [sv setContentSize:CGSizeMake(2048,2048)];
    
    CGRect rect = CGRectMake(0,0,100,100);
    UIView *v = [[VNCView alloc] initWithFrame:rect];
    [sv addSubview:v];
    [v setBackgroundColor:[UIColor redColor]];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(100,300,100,50);
    //[button setTitle:@"Hello World" forState:UIControlStateNormal];
    //[self.view addSubview:button];
    
    ServerBase *serv = [ServerBase alloc];
    [serv setName:@"myserver"];
    [serv setHost:@"192.168.1.107"];
    [serv setPassword:@"scsscs"];
    [serv setDisplay:0];
    [serv setPort:5900];
    
    RFBConnection *conn = [[RFBConnection alloc] initWithServer:serv profile:[Profile defaultProfile] view:v];
    NSString *msg = nil;
    [conn openConnectionReturningError:&msg];
    [conn setDelegate:self];
    [conn startTalking];
#endif
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

- (void)dealloc {
    [super dealloc];
}

@end
