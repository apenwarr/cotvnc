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

@implementation viewtestViewController

@synthesize vncView;



// Implement loadView to create a view hierarchy programmatically,
// without using a nib.
- (void)loadView {
    CGRect rect = [[UIScreen mainScreen] bounds]; //CGRectMake(0,0,100,100);
    UIScrollView *sv = [[UIScrollView alloc] initWithFrame:rect];
    [sv setBackgroundColor:[UIColor blackColor]];
    [sv setDelegate:self];
    [sv setMultipleTouchEnabled:YES];
    [sv setAutoresizingMask:(UIViewAutoresizingFlexibleWidth |
			     UIViewAutoresizingFlexibleHeight)];
    [sv setAutoresizesSubviews:NO];
    self.view = sv;
    
    VNCContentView *v = [[VNCContentView alloc] initWithFrame:[sv bounds]];
    [v setBackgroundColor:[UIColor redColor]];
    [v setDelegate:self];
    [sv addSubview:v];
    self.vncView = v;
    
    ServerBase *serv = [ServerBase alloc];
    [serv setName:@"myserver"];
    [serv setHost:@"192.168.1.107"];
    [serv setPassword:@"scsscs"];
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


- (void)fixScale
{
    UIScrollView *sv = (UIScrollView *)self.view;
    NSLog(@"sv:%@ v:%@",
	 NSStringFromCGRect([sv frame]),
	 NSStringFromCGSize(_contentSize));
    
    CGSize vncsize = _contentSize;
    CGRect bounds = [sv bounds];
    double xmax = bounds.size.width, ymax = bounds.size.height;
    double xscale = xmax/vncsize.width, yscale = ymax/vncsize.height;
    double minscale = (xscale < yscale) ? xscale : yscale;
    [sv setMaximumZoomScale:1.0];
    [sv setMinimumZoomScale:minscale];
    [sv setZoomScale:minscale animated:YES];
}


- (void)connection:(RFBConnection *)conn sizeChanged:(CGSize)vncsize
{
    UIScrollView *sv = (UIScrollView *)self.view;
    _contentSize = vncsize;
    [sv setContentSize:vncsize];
    [self fixScale];
}


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return [self vncView];
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


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)old
{
    [self fixScale];
}


- (void)dealloc {
    [super dealloc];
}

@end
