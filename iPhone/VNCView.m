//
//  VNCView.m
//  vnsea
//
//  Created by Chris Reed on 9/5/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
// Modified by: Glenn Kreisel

#import "VNCView.h"
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>
#import <UIKit/UITextView.h>
#import "RectangleList.h"
#import "QueuedEvent.h"

//! Height of the controls bar view.
#define kControlsBarHeight (24.0f)

//! Height of buttons in the controls bar.
#define kControlsBarButtonHeight (32.0f)

#define kKeyboardButtonWidth (40.0f)
#define kExitButtonWidth (28.0f)
#define kRightMouseButtonWidth (28.0f)
#define kModifierKeyButtonWidth (28.0f)

#define kModifierKeyImageWidth (21.0f)
#define kModifierKeyImageHeight (21.0f)

#define kButtonSpacing (5.0f)

@implementation VNCView

- (void)sendFunctionKeys:(id)sender
{
#if 0
	UIPushButton *pb = (UIPushButton *)sender;
	NSString *ns;
	
	ns = [[pb title] substringFromIndex:1];
	NSLog(@"Numbers equal %@", ns);
	NSLog(@"Numbers int equal %d", [ns intValue]);
	
	[_connection sendFunctionKey: (unsigned)[ns intValue]];
#endif
}

- (void)sendESCKey:(id)sender
{	
	[_connection sendEscapeKey];
}

- (void)sendTabKey:(id)sender
{	
	[_connection sendTabKey];
}

- (void)sendCtrlAltDel:(id)sender
{
	[_connection sendCtrlAltDel:nil];
}

- (void)sendFullRefresh:(id)sender
{
	[_connection sendFullScreenRefresh];
}

// I can never remember this relationship for some reason: The frame
// rectangle defines the view's location and size in the superview
// using the superview's coordinate system. The bounds
// rectangle defines the interior coordinate system that is used when
// drawing the contents of the view, including the origin and
// scaling.
- (id)initWithFrame:(CGRect)frame
{
	if ([super initWithFrame:frame])
	{
		CGRect subframe = frame;
		subframe.origin = CGPointMake(0, 0);
		
		// Create scroller view.
		_scroller = [[VNCScrollerView alloc] initWithFrame:subframe];
		[_scroller setVNCView: self];
		[_scroller setBackgroundColor:[UIColor purpleColor]];
#if 0
		[_scroller setScrollingEnabled:YES];
		[_scroller setShowScrollerIndicators:YES];
		[_scroller setAdjustForContentSizeChange:NO];
		[_scroller setAllowsRubberBanding:YES];
		[_scroller setAllowsFourWayRubberBanding:YES];
		[_scroller setRubberBand: 50 forEdges:0];
		[_scroller setRubberBand: 50 forEdges:1];
		[_scroller setRubberBand: 50 forEdges:2];
		[_scroller setRubberBand: 50 forEdges:3];
		[_scroller setDelegate:self];
#endif
		
		// Create controls bar.
		[self layoutControlsBar];
		
		// Create screen view.
		_screenView = [[VNCContentView alloc] initWithFrame:subframe];
		[_screenView setDelegate: [self delegate]];
#if 0	
		// Create keyboard.
		CGSize defaultKeyboardSize = [UIKeyboard defaultSize];
		subframe.origin = CGPointMake(0, frame.size.height - kControlsBarHeight - defaultKeyboardSize.height);
		subframe.size = defaultKeyboardSize;
		_keyboardView = [[UIKeyboard alloc] initWithFrame:subframe];
		[_keyboardView setPreferredKeyboardType:kUIKeyboardLayoutAlphabetTransparent];
#endif
		// Set our background color to black.
//		const float kBlackComponents[] = { 0, 0, 0, 1 };
		CGColorSpaceRef rgbSpace = CGColorSpaceCreateDeviceRGB();
	    //CGColorRef black = CGColorCreate(rgbSpace, kBlackComponents);
		CGColorSpaceRelease(rgbSpace);
		
		[self setOpaque:YES];
//		[self setBackgroundColor:black];
		
		// Build view hierarchy.
		//[self addSubview:_controlsView];
		[_scroller addSubview:_screenView];
		[self addSubview:_scroller];
		
		// Init some instance variables.
		_areControlsVisible = NO;
		_isKeyboardVisible = NO;
		_scaleState = kScaleFitNone;
		_ipodScreenSize = CGSizeMake(frame.size.width, frame.size.height);
	}
	
	return self;
}

//! This method creates the controls bar that appears at the bottom of the display
//! in portrait mode, as well as all of the buttons within it.
- (void)layoutControlsBar
{
#if 0
	CGRect frame = [self frame];
	
	// Create control bar, initially just below the bottom of the screen.
//	CGRect subframe = CGRectMake(0, frame.size.height, frame.size.width, kControlsBarHeight);
//	_controlsView = [[UIGradientBar alloc] initWithFrame:subframe];
	
	// Create keyboard button.
	subframe = CGRectMake(5, (kControlsBarHeight - kControlsBarButtonHeight) / 2.0f + 1.0f, kKeyboardButtonWidth, kControlsBarButtonHeight);
        _keyboardButton = [[UINavBarButton alloc] initWithImage:[UIImage imageNamed:@"keyboard.png"]];
	[_keyboardButton setFrame:subframe];
	[_keyboardButton setNavBarButtonStyle:0];
	[_keyboardButton addTarget:self action:@selector(toggleKeyboard:) forEvents:kUIControlEventMouseUpInside];
	
	// Modifier key buttons.
	subframe = CGRectMake(CGRectGetMaxX(subframe) + kButtonSpacing, (kControlsBarHeight - kControlsBarButtonHeight) / 2.0f + 1.0f, kModifierKeyButtonWidth, kControlsBarButtonHeight);
	_shiftButton = [[UINavBarButton alloc] initWithImage:[UIImage imageNamed:@"shift_key.png"]];
	[_shiftButton setFrame:subframe];
	[_shiftButton setNavBarButtonStyle:0];
	[_shiftButton addTarget:self action:@selector(toggleModifierKey:) forEvents:kUIControlEventMouseUpInside];
	
	subframe.origin.x = CGRectGetMaxX(subframe) + kButtonSpacing;
	_commandButton = [[UINavBarButton alloc] initWithImage:[UIImage imageNamed:@"cmd_key.png"]];
	[_commandButton setFrame:subframe];
	[_commandButton setNavBarButtonStyle:0];
	[_commandButton addTarget:self action:@selector(toggleModifierKey:) forEvents:kUIControlEventMouseUpInside];
	
	subframe.origin.x = CGRectGetMaxX(subframe) + kButtonSpacing;
	_optionButton = [[UINavBarButton alloc] initWithImage:[UIImage imageNamed:@"opt_key.png"]];
	[_optionButton setFrame:subframe];
	[_optionButton setNavBarButtonStyle:0];
	[_optionButton addTarget:self action:@selector(toggleModifierKey:) forEvents:kUIControlEventMouseUpInside];
	
	subframe.origin.x = CGRectGetMaxX(subframe) + kButtonSpacing;
	_controlButton = [[UINavBarButton alloc] initWithImage:[UIImage imageNamed:@"ctrl_key.png"]];
	[_controlButton setFrame:subframe];
	[_controlButton setNavBarButtonStyle:0];
	[_controlButton addTarget:self action:@selector(toggleModifierKey:) forEvents:kUIControlEventMouseUpInside];
	
	// Helper Functions "more" button on the status bar
	subframe = CGRectMake(subframe.origin.x + kModifierKeyButtonWidth + 5 , (kControlsBarHeight - kControlsBarButtonHeight) / 2.0f + 1.0f, 53, kControlsBarButtonHeight);

	_helperFunctionButton = [[UINavBarButton alloc] initWithTitle:@"More"];
	[_helperFunctionButton setFrame:subframe];
	[_helperFunctionButton setNavBarButtonStyle:0];
	[_helperFunctionButton addTarget:self action:@selector(showHelperFunctions:) forEvents:kUIControlEventMouseUpInside];

	// Right mouse button.
	subframe = CGRectMake(frame.size.width - kExitButtonWidth - 5 - kRightMouseButtonWidth - 6, (kControlsBarHeight - kControlsBarButtonHeight) / 2.0f + 1.0f, kRightMouseButtonWidth, kControlsBarButtonHeight);
	_rightMouseButton = [[UINavBarButton alloc] initWithImage:[UIImage imageNamed:@"right_mouse.png"]]; //WithTitle:@"W" autosizesToFit:NO];
	[_rightMouseButton setFrame:subframe];
	[_rightMouseButton setNavBarButtonStyle:0];
	[_rightMouseButton addTarget:self action:@selector(toggleRightMouse:) forEvents:kUIControlEventMouseUpInside];
	
	// Terminate connection button.
	subframe = CGRectMake(frame.size.width - kExitButtonWidth - 5, (kControlsBarHeight - kControlsBarButtonHeight) / 2.0f + 1.0f, kExitButtonWidth, kControlsBarButtonHeight);
	_exitButton = [[UINavBarButton alloc] initWithTitle:@"X" autosizesToFit:NO];
	[_exitButton setFrame:subframe];
	[_exitButton setNavBarButtonStyle:0];
	[_exitButton addTarget:self action:@selector(closeConnection:) forEvents:kUIControlEventMouseUpInside];
    
	// Build controls bar view hierarchy.
	[_controlsView addSubview:_keyboardButton];
	[_controlsView addSubview:_exitButton];
	[_controlsView addSubview:_shiftButton];
	[_controlsView addSubview:_commandButton];
	[_controlsView addSubview:_optionButton];
	[_controlsView addSubview:_controlButton];
	[_controlsView addSubview:_helperFunctionButton];
	[_controlsView addSubview:_rightMouseButton];
#endif
}

- (void)dealloc
{
    [super dealloc];
}

- (id)scroller
{
	return _scroller;
}

- (bool)areControlsVisible
{
	return _areControlsVisible;
}

//! Either hides or shows the controls bar at the bottom of the screen
//! (in portrait orientation). The hiding or showing is animated.
- (void)showControls:(bool)show
{
	if (_areControlsVisible != show)
	{
		CGRect frame;
		
//		[UIView beginAnimations:nil];
		[UIView setAnimationDuration:0.15f];

		if (_areControlsVisible)
		{
			// Hide the keyboard if it was in view.
			if (_isKeyboardVisible)
			{
				[self toggleKeyboard:nil];
			}
			
			// Hide controls
			frame = [_controlsView frame];
			frame.origin.y = [self frame].size.height;
			[_controlsView setFrame:frame];
			
			frame = [_scroller frame];
			frame.size.height += kControlsBarHeight;
			[_scroller setFrame:frame];
			_ipodScreenSize.height += kControlsBarHeight;
			
			// Hide the keyboard if it was in view.
			if (_isKeyboardVisible)
			{
				[self toggleKeyboard:nil];
			}
		}
		else
		{
			// Show controls
			frame = [_controlsView frame];
			frame.origin.y -= kControlsBarHeight;
			[_controlsView setFrame:frame];
			
			frame = [_scroller frame];
			frame.size.height -= kControlsBarHeight;
			[_scroller setFrame:frame];
			_ipodScreenSize.height -= kControlsBarHeight;
		}
		
		// This will start the animation.
//		[UIView endAnimations];
		
		_areControlsVisible = show;
	}
}

- (float)orientationDegree
{
	return [_screenView getOrientationDeg];
}

- (void)toggleControls
{
	[self showControls:!_areControlsVisible];
}

- (CGPoint)topLeftVisiblePt
{
	return [_scroller bounds].origin;
}

#if 0
- (void)changeViewPinnedToPoint:(CGPoint)ptPinned scale:(float)fScale orientation:(UIHardwareOrientation)wOrientationState force:(BOOL)bForce
{
	[_scroller changeViewPinnedToPoint:ptPinned scale:fScale orientation:wOrientationState force:bForce];
}
#endif

- (void)setStartupTopLeftPt:(CGPoint)pt
{
	_ptStartupTopLeft = pt;
}

// Bring up the Helper Functions Popup window using AlertSheet as the basis
- (void)showHelperFunctions:(id)sender
{
#if 0
	UIAlertSheet *downloader = [[UIAlertSheet alloc ] initWithFrame:CGRectMake(0.0f, 0.0f, 200.0f, 370.0f) ];	

	UITextLabel *txtLabel = [[UITextLabel alloc] initWithFrame:CGRectMake(0, 32, 280, 32)];
	
	const float kTextComponents[] = { .94, .94, .94, 1 };
	const float kTransparentComponents[] = { 0, 0, 1, 0 };
		
    CGColorSpaceRef rgbSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef textColorStatus = CGColorCreate(rgbSpace, kTextComponents);
    CGColorRef rgbTransparent = CGColorCreate(rgbSpace, kTransparentComponents);		
	CGColorSpaceRelease(rgbSpace);
		
	GSFontRef font = GSFontCreateWithName("VerdanaBold", 0, 11.0f);
	[txtLabel setFont:font];
	[txtLabel setBackgroundColor: rgbTransparent];
	[txtLabel setColor:textColorStatus];
	[txtLabel setCentersHorizontally: true];
	[txtLabel setText:[NSString stringWithFormat: @"Remote Name: %@", _remoteComputerName]];
	[downloader addSubview:txtLabel];
	
	UIPushButton *aButton = [[UIPushButton alloc] initWithTitle:@"Send Ctrl-Alt-Delete" autosizesToFit:NO];
	[aButton setFrame:CGRectMake(10, 55, 130, 32)];
	[aButton setDrawsShadow:YES];
	[aButton setDrawContentsCentered:YES];
	[aButton setShowPressFeedback:YES];
	[aButton addTarget:self action:@selector(sendCtrlAltDel:) forEvents:kUIControlEventMouseUpInside];
	[downloader addSubview:aButton];

	aButton = [[UIPushButton alloc] initWithTitle:@"Full Screen Refresh" autosizesToFit:NO];
	[aButton setFrame:CGRectMake(140, 55, 130, 32)];
	[aButton setDrawsShadow:YES];
	[aButton setDrawContentsCentered:YES];
	[aButton setShowPressFeedback:YES];
	[aButton addTarget:self action:@selector(sendFullRefresh:) forEvents:kUIControlEventMouseUpInside];
	[downloader addSubview:aButton];

	_fitWidthButton = [[UIPushButton alloc] initWithTitle:@"Fit Screen to Width" autosizesToFit:NO];
	[_fitWidthButton setFrame:CGRectMake(10, 88, 130, 32)];
	[_fitWidthButton setDrawsShadow:YES];
	[_fitWidthButton setDrawContentsCentered:YES];
	[_fitWidthButton setShowPressFeedback:YES];
	[_fitWidthButton addTarget:self action:@selector(toggleFitWidthHeight:) forEvents:kUIControlEventMouseUpInside];
	[downloader addSubview:_fitWidthButton];

	_fitHeightButton = [[UIPushButton alloc] initWithTitle:@"Fit Screen to Height" autosizesToFit:NO];
	[_fitHeightButton setFrame:CGRectMake(140, 88, 130, 32)];
	[_fitHeightButton setDrawsShadow:YES];
	[_fitHeightButton setDrawContentsCentered:YES];
	[_fitHeightButton setShowPressFeedback:YES];
	[_fitHeightButton addTarget:self action:@selector(toggleFitWidthHeight:) forEvents:kUIControlEventMouseUpInside];
	[downloader addSubview:_fitHeightButton];

	_fitWholeButton = [[UIPushButton alloc] initWithTitle:@"Fit Screen to Device" autosizesToFit:NO];
	[_fitWholeButton setFrame:CGRectMake(10, 121, 130, 32)];
	[_fitWholeButton setDrawsShadow:YES];
	[_fitWholeButton setDrawContentsCentered:YES];
	[_fitWholeButton setShowPressFeedback:YES];
	[_fitWholeButton addTarget:self action:@selector(toggleFitWidthHeight:) forEvents:kUIControlEventMouseUpInside];
	[downloader addSubview:_fitWholeButton];

	_fitNoneButton = [[UIPushButton alloc] initWithTitle:@"Allow Dynamic Scaling" autosizesToFit:NO];
	[_fitNoneButton setFrame:CGRectMake(140, 121, 130, 32)];
	[_fitNoneButton setDrawsShadow:YES];
	[_fitNoneButton setDrawContentsCentered:YES];
	[_fitNoneButton setShowPressFeedback:YES];
	[_fitNoneButton addTarget:self action:@selector(toggleFitWidthHeight:) forEvents:kUIControlEventMouseUpInside];
	[downloader addSubview:_fitNoneButton];

	aButton = [[UIPushButton alloc] initWithTitle:@"F1" autosizesToFit:NO];
	[aButton setFrame:CGRectMake(15, 154, 30, 32)];
	[aButton setDrawsShadow:YES];
	[aButton setDrawContentsCentered:YES];
	[aButton setShowPressFeedback:YES];
	[aButton addTarget:self action:@selector(sendFunctionKeys:) forEvents:kUIControlEventMouseUpInside];
	[downloader addSubview:aButton];

	aButton = [[UIPushButton alloc] initWithTitle:@"F2" autosizesToFit:NO];
	[aButton setFrame:CGRectMake(50, 154, 30, 32)];
	[aButton setDrawsShadow:YES];
	[aButton setDrawContentsCentered:YES];
	[aButton setShowPressFeedback:YES];
	[aButton addTarget:self action:@selector(sendFunctionKeys:) forEvents:kUIControlEventMouseUpInside];
	[downloader addSubview:aButton];

	aButton = [[UIPushButton alloc] initWithTitle:@"F3" autosizesToFit:NO];
	[aButton setFrame:CGRectMake(85, 154, 30, 32)];
	[aButton setDrawsShadow:YES];
	[aButton setDrawContentsCentered:YES];
	[aButton setShowPressFeedback:YES];
	[aButton addTarget:self action:@selector(sendFunctionKeys:) forEvents:kUIControlEventMouseUpInside];
	[downloader addSubview:aButton];

	aButton = [[UIPushButton alloc] initWithTitle:@"F4" autosizesToFit:NO];
	[aButton setFrame:CGRectMake(120, 154, 30, 32)];
	[aButton setDrawsShadow:YES];
	[aButton setDrawContentsCentered:YES];
	[aButton setShowPressFeedback:YES];
	[aButton addTarget:self action:@selector(sendFunctionKeys:) forEvents:kUIControlEventMouseUpInside];
	[downloader addSubview:aButton];

	aButton = [[UIPushButton alloc] initWithTitle:@"F5" autosizesToFit:NO];
	[aButton setFrame:CGRectMake(155, 154, 30, 32)];
	[aButton setDrawsShadow:YES];
	[aButton setDrawContentsCentered:YES];
	[aButton setShowPressFeedback:YES];
	[aButton addTarget:self action:@selector(sendFunctionKeys:) forEvents:kUIControlEventMouseUpInside];
	[downloader addSubview:aButton];

	aButton = [[UIPushButton alloc] initWithTitle:@"F6" autosizesToFit:NO];
	[aButton setFrame:CGRectMake(190, 154, 30, 32)];
	[aButton setDrawsShadow:YES];
	[aButton setDrawContentsCentered:YES];
	[aButton setShowPressFeedback:YES];
	[aButton addTarget:self action:@selector(sendFunctionKeys:) forEvents:kUIControlEventMouseUpInside];
	[downloader addSubview:aButton];
	
	aButton = [[UIPushButton alloc] initWithTitle:@"ESC" autosizesToFit:NO];
	[aButton setFrame:CGRectMake(235, 154, 30, 32)];
	[aButton setDrawsShadow:YES];
	[aButton setDrawContentsCentered:YES];
	[aButton setShowPressFeedback:YES];
	[aButton addTarget:self action:@selector(sendESCKey:) forEvents:kUIControlEventMouseUpInside];
	[downloader addSubview:aButton];

	aButton = [[UIPushButton alloc] initWithTitle:@"F7" autosizesToFit:NO];
	[aButton setFrame:CGRectMake(15, 187, 30, 32)];
	[aButton setDrawsShadow:YES];
	[aButton setDrawContentsCentered:YES];
	[aButton setShowPressFeedback:YES];
	[aButton addTarget:self action:@selector(sendFunctionKeys:) forEvents:kUIControlEventMouseUpInside];
	[downloader addSubview:aButton];

	aButton = [[UIPushButton alloc] initWithTitle:@"F8" autosizesToFit:NO];
	[aButton setFrame:CGRectMake(50, 187, 30, 32)];
	[aButton setDrawsShadow:YES];
	[aButton setDrawContentsCentered:YES];
	[aButton setShowPressFeedback:YES];
	[aButton addTarget:self action:@selector(sendFunctionKeys:) forEvents:kUIControlEventMouseUpInside];
	[downloader addSubview:aButton];

	aButton = [[UIPushButton alloc] initWithTitle:@"F9" autosizesToFit:NO];
	[aButton setFrame:CGRectMake(85, 187, 30, 32)];
	[aButton setDrawsShadow:YES];
	[aButton setDrawContentsCentered:YES];
	[aButton setShowPressFeedback:YES];
	[aButton addTarget:self action:@selector(sendFunctionKeys:) forEvents:kUIControlEventMouseUpInside];
	[downloader addSubview:aButton];

	aButton = [[UIPushButton alloc] initWithTitle:@"F10" autosizesToFit:NO];
	[aButton setFrame:CGRectMake(120, 187, 30, 32)];
	[aButton setDrawsShadow:YES];
	[aButton setDrawContentsCentered:YES];
	[aButton setShowPressFeedback:YES];
	[aButton addTarget:self action:@selector(sendFunctionKeys:) forEvents:kUIControlEventMouseUpInside];
	[downloader addSubview:aButton];

	aButton = [[UIPushButton alloc] initWithTitle:@"F11" autosizesToFit:NO];
	[aButton setFrame:CGRectMake(155, 187, 30, 32)];
	[aButton setDrawsShadow:YES];
	[aButton setDrawContentsCentered:YES];
	[aButton setShowPressFeedback:YES];
	[aButton addTarget:self action:@selector(sendFunctionKeys:) forEvents:kUIControlEventMouseUpInside];
	[downloader addSubview:aButton];

	aButton = [[UIPushButton alloc] initWithTitle:@"F12" autosizesToFit:NO];
	[aButton setFrame:CGRectMake(190, 187, 30, 32)];
	[aButton setDrawsShadow:YES];
	[aButton setDrawContentsCentered:YES];
	[aButton setShowPressFeedback:YES];
	[aButton addTarget:self action:@selector(sendFunctionKeys:) forEvents:kUIControlEventMouseUpInside];
	[downloader addSubview:aButton];

	aButton = [[UIPushButton alloc] initWithTitle:@"Tab" autosizesToFit:NO];
	[aButton setFrame:CGRectMake(235, 187, 30, 32)];
	[aButton setDrawsShadow:YES];
	[aButton setDrawContentsCentered:YES];
	[aButton setShowPressFeedback:YES];
	[aButton addTarget:self action:@selector(sendTabKey:) forEvents:kUIControlEventMouseUpInside];
	[downloader addSubview:aButton];
	
	
	aButton = [[UIPushButton alloc] initWithImage:[UIImage imageNamed:@"cmd_key.png"]];
	[aButton setTitleFont:font];
	[aButton setDrawContentsCentered:YES];
	[aButton setTitle:@"= Alt"];
	[aButton setFrame:CGRectMake(10, 222, 70, 32)];
	[downloader addSubview:aButton];
				
	aButton = [[UIPushButton alloc] initWithImage:[UIImage imageNamed:@"ctrl_key.png"]];
	[aButton setTitleFont:font];
	[aButton setDrawContentsCentered:YES];
	[aButton setTitle:@"= Ctrl"];
	[aButton setFrame:CGRectMake(80, 222, 70, 32)];
	[downloader addSubview:aButton];

	aButton = [[UIPushButton alloc] initWithTitle:@"Toggle View Only - Single Tap top statusbar" autosizesToFit:NO];
	[aButton setFrame:CGRectMake(0, 245, 280, 32)];
	[aButton setDrawsShadow:YES];
	[aButton setDrawContentsCentered:YES];
	[aButton setShowPressFeedback:YES];
	[aButton addTarget:self action:@selector(sendTabKey:) forEvents:kUIControlEventMouseUpInside];
	[downloader addSubview:aButton];
	
	CFRelease(font);

	[downloader setTitle:@"Helper Functions"];
	[downloader setDelegate:self];
	[downloader setContext:self];
	[downloader setAlpha:0.6];
	[downloader setDimsBackground:YES];
	UIPushButton *uibutton = [downloader addButtonWithTitle:@"Close"];
	[uibutton setAlpha:1.0];

	[downloader setTableShouldShowMinimumContent:NO];
	[downloader setBlocksInteraction:YES];

	[downloader _slideSheetOut:YES];
	[downloader layoutAnimated:YES];
	[downloader popupAlertAnimated:YES atOffset:0.0];
	[downloader setFrame:CGRectMake(0,60,330,370)];
	CGRect rcFrame = [uibutton frame];
	CGRect rcFrameTop = [downloader frame];	
	[uibutton setFrame:CGRectMake(rcFrame.origin.x, rcFrameTop.size.height - rcFrame.size.height-rcFrame.size.height-3,rcFrame.size.width,rcFrame.size.height)];
#endif
}

- (void)toggleFitWidthHeight:(id)sender
{
#if 0
	UIPushButton *pButton = (UIPushButton *)sender;	
	scaleSpecialTypes wScaleState = [self getScaleState], wScaleThisButton;

	if (sender == _fitWidthButton)
		wScaleThisButton = kScaleFitWidth;
	else if (sender == _fitHeightButton)
		wScaleThisButton = kScaleFitHeight;
	else if (sender == _fitWholeButton)
		wScaleThisButton = kScaleFitWidth | kScaleFitHeight;
	else if (sender == _fitNoneButton)
		wScaleThisButton = 0;
	[self setScaleState: wScaleThisButton];
	[self setOrientation: [self getOrientationState] bForce:true];
	if (sender != _fitNoneButton)
		[_scroller scrollPointVisibleAtTopLeft: CGPointMake(0,0)];
	NSLog(@"Got Event or Scale Change");
#endif
}

- (void)alertSheet:(id)sheet buttonClicked:(int)buttonIndex
{
	NSLog(@"Got alert click");
//	[sheet dismissAnimated:YES];
	[sheet release];
}

- (CGRect)scrollerFrame
{
	return [_scroller frame];
}

//! The toggle keyboard button has been pressed. This method assumes
//! the controls bar is visible.
- (void)toggleKeyboard:(id)sender
{
//	NSLog(@"toggling keyboard: old=%d", (int)_isKeyboardVisible);
#if 0	
	CGRect frame;
	
	if (_isKeyboardVisible)
	{
		// Remove the keyboard view.
		[_keyboardView removeFromSuperview];
		
		// Adjust scroller frame back to normal size (minus the controls bar).
		frame = [self bounds];
		frame.size.height -= kControlsBarHeight;
		[_scroller setFrame:frame];
	}
	else
	{
		// Adjust scroller frame so that its height is from below the system
		// status bar to the top of the keyboard.
		frame = [self bounds];
		frame.size.height = frame.size.height - kControlsBarHeight - [_keyboardView frame].size.height;
		[_scroller setFrame:frame];
		
		// Add in the keyboard view.
//		[self addSubview:_keyboardView];
//		[_keyboardView activate];
		
		// Set the delegate now that we have an active keyboard.
		[[UIKeyboardImpl activeInstance] setDelegate:self];
	}
#endif	
	_isKeyboardVisible = !_isKeyboardVisible;
}

//! This message is received when the user has pressed the close connection
//! button.
- (void)closeConnection:(id)sender
{
	// Hide the keyboard before closing.
	if (_isKeyboardVisible)
	{
		[self toggleKeyboard:nil];
	}
	
	if (_delegate && [_delegate respondsToSelector:@selector(closeConnection)])
	{
		[_delegate closeConnection];
	}
}

//! Handle the right mouse button being pressed.
//!
- (void)toggleRightMouse:(id)sender
{
#if 0
	bool useRight = ![_scroller useRightMouse];
	[_rightMouseButton setNavBarButtonStyle:useRight ? 3 : 0];
	[_scroller setUseRightMouse:useRight];
#endif
}

//! Handle one of the modifier key buttons being pressed.
//!
- (void)toggleModifierKey:(id)sender
{
#if 0
	unsigned int modifier;
	if (sender == _shiftButton)
	{
		modifier = NSShiftKeyMask;
	}
	else if (sender == _commandButton)
	{
		modifier = NSCommandKeyMask;
	}
	else if (sender == _optionButton)
	{
		modifier = NSAlternateKeyMask;
	}
	else if (sender == _controlButton)
	{
		modifier = NSControlKeyMask;
	}
	else
	{
		// Unexpected sender.
		NSLog(@"Unexpected sender = %@", sender);
		return;
	}
	
	// Determine the new modifier mask.
	//! @todo This logic should be in EventFilter, not here.
	unsigned int currentModifiers = [_filter pressedModifiers];
	unsigned int newModifiers = currentModifiers ^ modifier;
	bool isPressed = newModifiers & modifier;
	
	NSLog(@"current=%x, new=%x, is=%d", currentModifiers, newModifiers, (int)isPressed);
	
	// Change the button color.
	[sender setNavBarButtonStyle:isPressed ? 3 : 0];
	
	// Queue the modifier changed event.
	[_filter flagsChanged:newModifiers];
#endif
}

//! Returns whether the first frame update has been received from the server.
//!
- (bool)isFirstDisplay
{
	return _isFirstDisplay;
}

- (id)delegate
{
	return _delegate;
}

- (void)setDelegate:(id)theDelegate
{
	_delegate = theDelegate;
}

- (RFBConnection *)connection;
{
	return _connection;
}

-(void)toggleViewOnly
{
	[_scroller toggleViewOnly];
}
//! This method is invoked before the VNCView is displayed to the user, so
//! that the controls on the controls bar can be properly enabled or disabled
//! based on their relevance if view only mode is enabled. For instance,
//! the keyboard and right mouse buttons should be disabled in view only mode
//! because the user cannot type or click remotely.
- (void)enableControlsForViewOnly:(bool)isViewOnly
{
#if 0
	bool notViewOnly = !isViewOnly;
	if (isViewOnly)
		{
		[_keyboardButton removeFromSuperview];
		[_shiftButton removeFromSuperview];
		[_commandButton removeFromSuperview];
		[_optionButton removeFromSuperview];
		[_controlButton removeFromSuperview];
		[_rightMouseButton removeFromSuperview];
		[_delegate setStatusBarMode: kUIStatusBarBlack duration:0];
		}
	else
		{
		[_controlsView addSubview: _keyboardButton];
		[_controlsView addSubview: _shiftButton];
		[_controlsView addSubview: _commandButton];
		[_controlsView addSubview: _optionButton];
		[_controlsView addSubview: _controlButton];
		[_controlsView addSubview: _rightMouseButton];
		[_delegate setStatusBarMode: kUIStatusBarWhite duration:0];
		}
#endif
/*	
	[_keyboardButton setEnabled:notViewOnly];
	[_shiftButton setEnabled:notViewOnly];
	[_commandButton setEnabled:notViewOnly];
	[_optionButton setEnabled:notViewOnly];
	[_controlButton setEnabled:notViewOnly];
	[_rightMouseButton setEnabled:notViewOnly];
*/
	
}

//! The frame buffer has been created by the connection object and is
//! being passed to us. We pass it along to the underlying content view
//! that does the actual drawing.
- (void)setFrameBuffer:(id)aBuffer;
{
	[_screenView setFrameBuffer:aBuffer];
}

//! Either a new connection is being set or the connection is being cleared
//! because it was closed. When a new connection is being set, we hook up
//! some objects to each other, such as the EventFilter.
- (void)setConnection:(RFBConnection *)connection
{
    _connection = connection;
	if (_connection)
	{
		_isFirstDisplay = false;

		_filter = [_connection eventFilter];
		[_filter setView:_scroller];
		[_scroller setEventFilter:_filter];
		[_scroller setViewOnly:[_connection viewOnly]];
//		[_scroller scrollPointVisibleAtTopLeft:CGPointMake(0, 0)];
		[_screenView setNeedsDisplay];
		
		// Enable or disable controls depending on view only mode.
		[self enableControlsForViewOnly:[_connection viewOnly]];
	}
	else
	{
		// The connection was closed.
		_filter = nil;
		[_scroller setEventFilter:nil];
		[_scroller cleanUpMouseTracks];
		[_screenView setFrameBuffer:nil];
//		[_screenView setOrientationState:0];
		// Get the screen view to redraw itself in black.
		[_screenView setNeedsDisplay];
	}
}

#if 0
- (UIHardwareOrientation)getOrientationState;
{
	return [_screenView getOrientationState];
}
#endif


- (scaleSpecialTypes)getScaleState
{
	return _scaleState;
}

- (void)setScaleState:(scaleSpecialTypes)wScaleState
{
	_scaleState = wScaleState;
}

- (float)scaleFitCurrentScreen: (scaleSpecialTypes) wScaleState
{
    return 1.0;
#if 0
		float dx,dy, wScaleX, wScaleY, wScale = 10;
		
		NSLog(@"In scale fit");
		switch ([self getOrientationState])
		{
			case kOrientationVerticalUpsideDown:
			case kOrientationVertical:
				dx = _ipodScreenSize.width;
				dy = _ipodScreenSize.height;
				break;
				
			default:
			case kOrientationHorizontalLeft:
			case kOrientationHorizontalRight:
				dx = _ipodScreenSize.height;
				dy = _ipodScreenSize.width;
				break;
		}
		
		wScaleX = dx / _vncScreenSize.width;
		wScaleY = dy / _vncScreenSize.height;
		switch (wScaleState)
		{
			case kScaleFitWhole:  // fit Whole Screen on IPod
				wScale = wScaleX < wScaleY ? wScaleX : wScaleY;
				break;

			case kScaleFitWidth:  // fit Width
				wScale = wScaleX;
				break;

			case kScaleFitHeight: // fit Height
				wScale = wScaleY;
                break;
		}
	NSLog(@"Out scale fit");
	return wScale;
#endif
}

- (void)setScalePercent:(float)wScale
{
	if (_scaleState != kScaleFitNone)
    {
		wScale = [self scaleFitCurrentScreen: _scaleState];
	}
//	NSLog(@"New Scale = %f", wScale);
	[_screenView setScalePercent: wScale];
}

- (CGRect)getFrame
{
	return [_screenView getFrame];
}

- (float)getScalePercent
{
	return [_screenView getScalePercent];
}

- (CGPoint)getIPodScreenPoint:(CGRect)r bounds:(CGRect)bounds
{
	return [_screenView getIPodScreenPoint: r bounds:bounds];
}

#if 0
- (void)setOrientation:(UIHardwareOrientation)wOrientation bForce:(int)bForce
{
#if 0
	CGSize vncScreenSize = _vncScreenSize;
	CGSize newRemoteSize;

	if(!(wOrientation == kOrientationVertical || wOrientation == kOrientationVerticalUpsideDown 
		|| wOrientation == kOrientationHorizontalLeft || wOrientation == kOrientationHorizontalRight))
	{
		return;
	}
		
	NSLog(@"VNC Screen Size  = %f %f", vncScreenSize.width, vncScreenSize.height);
	if (bForce || (_connection && wOrientation != [_screenView getOrientationState]))
	{
		UIHardwareOrientation oldOrientation = [_screenView getOrientationState];
//		NSLog(@"Orientation Change %d", wOrientation);

		[_screenView setOrientationState:wOrientation];
	
		if (wOrientation == kOrientationVertical || wOrientation == kOrientationVerticalUpsideDown)
		{
			newRemoteSize = vncScreenSize;
			if (!bForce)
				{
				if (oldOrientation == kOrientationHorizontalLeft || oldOrientation == kOrientationHorizontalRight)
					[self showControls: _savedControlShowState];
				}
		}
		else
		{
			newRemoteSize.width = vncScreenSize.height;
			newRemoteSize.height = vncScreenSize.width;
			if (!bForce)
				{
				_savedControlShowState = _areControlsVisible;
				[self showControls:0];
				}
		}

		if ([self getScaleState] != kScaleFitNone)
		{
			[self setScalePercent: 0];
		}
		float fUnscale = [_screenView getScalePercent];

		CGRect bounds = CGRectMake(0, 0, vncScreenSize.width, vncScreenSize.height);
		[_screenView setBounds: bounds];

		CGAffineTransform matrix = CGAffineTransformRotate(CGAffineTransformMakeScale(0 - fUnscale, fUnscale), 
				([_screenView getOrientationDeg])  * M_PI / 180.0f);
		[_filter setBackToVNCTransform: CGAffineTransformInvert(matrix)];
		[_filter setOrientation: wOrientation];

		newRemoteSize.width = newRemoteSize.width * [_screenView getScalePercent];
		newRemoteSize.height = newRemoteSize.height  * [_screenView getScalePercent];

//		NSLog(@"New Screen View = %f %f", newRemoteSize.width, newRemoteSize.height);
//		Animate if special double click zoom
		[_screenView setRemoteDisplaySize:newRemoteSize animate:bForce == 2 ? YES : !bForce];
	
		// Reset our scroller's content size.
		[_scroller setContentSize:newRemoteSize];
	}
#endif
}
#endif

- (void)setRemoteComputerName:(NSString *)name
{
	_remoteComputerName = name;
}

- (void)setRemoteDisplaySize:(CGSize)remoteSize
{
	//	NSLog(@"Setting VNC screen size %f %f", remoteSize.width, remoteSize.height);

	// ******************************************************************************
	// BAD BAD BAD IPHONE BUG WITH DEVICE CONTEXT ONLY ABLE to reach 1024 then crash 
	// ******************************************************************************
	_vncScreenSize = CGSizeMake(remoteSize.width, MIN(((2*1024*1024) / remoteSize.width), remoteSize.height));
	[self setScaleState: kScaleFitNone];
//	[self setOrientation: kOrientationVertical bForce:false];
}

//! The connection object is telling us that a region of the framebuffer
//! needs to be redrawn.
- (void)displayFromBuffer:(CGRect)aRect
{	
	[_screenView displayFromBuffer:aRect];
	
	// If this is our first display update then Transition to the VNC server screen
	if (!_isFirstDisplay)
	{
		_isFirstDisplay = true;
//		[_scroller scrollPointVisibleAtTopLeft:_ptStartupTopLeft];
//		[_delegate gotFirstFullScreenTransitionNow];
	}
}

//! This method is supposed to draw a list of rectangles. Unfortunately, the UIKit
//! doesn't seem to have an equivalent to lockFocus/unlockFocus, so there's no way
//! to get a drawing context outside of the regular draw methods. But it seems
//! that this method isn't called much (never seen it once), so it's not a big deal.
- (void)drawRectList:(id)aList
{
	NSLog(@"VNCView:drawRectList:%@", aList);
	
	// XXX this may not be cool!
//    [self lockFocus];
//    [aList drawRectsInRect:[self bounds]];
//    [self unlockFocus];
}

- (CGRect)contentRect
{
	return [_screenView bounds];
}

#pragma mark ** UIKeyboardInput **

- (void)deleteBackward
{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
	
	[_filter keyTyped:@"\x007f"];
}

- (void)insertText:(id)text
{
//	NSLog(@"%s:%@", __PRETTY_FUNCTION__, text);
	
	[_filter keyTyped:text];
}

- (void)replaceCurrentWordWithText:(id)fp8
{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)setMarkedText:(id)fp8
{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (id)markedText
{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
	return nil;
}

- (unsigned short)characterInRelationToCaretSelection:(int)fp8
{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
	return 0; //L' ';
}

- (unsigned short)characterBeforeCaretSelection
{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
	return 0; //L' ';
}

- (unsigned short)characterAfterCaretSelection
{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
	return 0; //L' ';
}

#if 0
- (struct __GSFont *)fontForCaretSelection
{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
//	return [UIPushButton defaultFont];
}

- (struct CGColor *)textColorForCaretSelection
{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
//	return [UITextTraits defaultCaretColor];
}
#endif

- (struct CGRect)rectContainingCaretSelection
{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
	return CGRectMake(0,0,0,0);
}

- (id)wordRangeContainingCaretSelection
{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
	return nil;
}

- (id)wordContainingCaretSelection
{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
	return nil;
}

- (id)wordInRange:(id)fp8
{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
	return nil;
}

- (void)expandSelectionToStartOfWordContainingCaretSelection
{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (int)wordOffsetInRange:(id)fp8
{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
	return 0;
}

- (BOOL)spaceFollowsWordInRange:(id)fp8
{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
	return NO;
}

- (id)previousNGrams:(unsigned int)fp8
{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
	return nil;
}

- (struct _NSRange)selectionRange
{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
	return NSMakeRange(0, 0);
}

- (BOOL)hasSelection
{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
	return NO;
}

- (BOOL)selectionAtDocumentStart
{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
	return NO;
}

- (BOOL)selectionAtSentenceStart
{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
	return NO;
}

- (BOOL)selectionAtWordStart
{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
	return NO;
}

- (BOOL)rangeAtSentenceStart:(id)fp8
{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
	return NO;
}

- (void)markCurrentWordForAutoCorrection:(id)fp8 correction:(id)fp12
{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)moveBackward:(unsigned int)fp8
{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)moveForward:(unsigned int)fp8
{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)selectAll
{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)setText:(id)fp8
{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (id)text
{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
	return @"";
}

- (void)updateSelectionWithPoint:(struct CGPoint)fp8
{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)setCaretChangeListener:(id)fp8
{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (struct CGRect)caretRect
{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
	return CGRectMake(0,0,0,0);
}

- (struct CGRect)convertCaretRect:(struct CGRect)fp8
{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
	return CGRectMake(0,0,0,0);
}

- (id)keyboardInputView
{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
	return self;
}

#if 0
- (id)textTraits
{
	UITextTraits * traits = [UITextTraits defaultTraits];
	[traits setAutoCapsType:0];	//?
	[traits setAutoCorrectionType:0];	//?
	[traits setAutoEnablesReturnKey:NO];
	return traits;
}
#endif

- (BOOL)isShowingPlaceholder
{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
	return NO;
}

- (void)setupPlaceholderTextIfNeeded
{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (BOOL)isProxyFor:(id)fp8
{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
	return NO;
}

#if 0
- (BOOL)interceptKeyEvent:(GSEventRef)theEvent
{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
	
//	unsigned eventType = GSEventGetType(theEvent);
//	unsigned subType = GSEventGetSubType(theEvent);
//	
//	NSLog(@"  type=%d; subtype=%d", eventType, subType);
//	
//	switch (eventType)
//	{
//		// key down
//		case 10:
//			[_filter keyDown:theEvent];
//			break;
//		
//		// key up
//		case 11:
//			[_filter keyUp:theEvent];
//			break;
//	}
	
	return NO;
}
#endif

/*
//These Methods track delegate calls made to the application
- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector 
{
	NSLog(@"Requested method for selector: %@", NSStringFromSelector(selector));
	return [super methodSignatureForSelector:selector];
}

- (BOOL)respondsToSelector:(SEL)aSelector 
{
	NSLog(@"Request for selector: %@", NSStringFromSelector(aSelector));
	return [super respondsToSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation 
{
	NSLog(@"Called from: %@", NSStringFromSelector([anInvocation selector]));
	[super forwardInvocation:anInvocation];
}
*/
@end
