//
//  VNCView.m
//  vnsea
//
//  Created by Chris Reed on 9/5/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
// Modified by: Glenn Kreisel

#import "VNCView.h"
#import "VNCPopupView.h"
#import "VnseaApp.h"
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>
#import <UIKit/UITextView.h>
#import <UIKit/UITouchDiagnosticsLayer.h>
#import <UIKit/UINavBarButton.h>
#import <UIKit/UIView-Gestures.h>
#import <UIKit/UIKeyboardImpl.h>
#import <UIKit/UITextView.h>
#import <UIKit/UITextTraits.h>
#import <GraphicsServices/GraphicsServices.h>
#import "RectangleList.h"
#import "QueuedEvent.h"

//! Height of the controls bar view.
#define kControlsBarHeight (48.0f)

//! Height of buttons in the controls bar.
#define kControlsBarButtonHeight (32.0f)

#define kKeyboardButtonWidth (40.0f)
#define kExitButtonWidth (22.0f)
#define kRightMouseButtonWidth (22.0f)
#define kModifierKeyButtonWidth (32.0f)

#define kModifierKeyImageWidth (21.0f)
#define kModifierKeyImageHeight (21.0f)

// There's got to be a better way to do this, but for now this is just fine.
// Thanks to the MobileTerminal team for this trick.
@implementation UIKeyboardImpl (DisableFeatures)

- (BOOL)autoCapitalizationPreference
{
	return NO;
}

- (BOOL)autoCorrectionPreference
{
	return NO;
}

@end

@implementation VNCView

- (void)mouseUp:(struct __GSEvent *)fp8
{
	NSLog(@"Got mouse Up");
}

// I can never remember this relationship for some reason:
// The frame rectangle defines the view's location and size in the superview using the superview’s coordinate system. The bounds rectangle defines the interior coordinate system that is used when drawing the contents of the view, including the origin and scaling.
- (id)initWithFrame:(CGRect)frame
{
	if ([super initWithFrame:frame])
	{
		CGRect subframe = frame;
		subframe.origin = CGPointMake(0, 0);
		
		_scaleState = kScaleFitNone;
		
		_ipodScreenSize = CGSizeMake(frame.size.width, frame.size.height);
		// Create scroller view.
		_scroller = [[VNCScrollerView alloc] initWithFrame:subframe];

		NSLog(@"SubFrame = %f %f", subframe.size.width, subframe.size.height);
		
		[_scroller setVNCView: self];
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
		
		// Create screen view.
		_screenView = [[VNCContentView alloc] initWithFrame:subframe];
		[_screenView setDelegate: [self delegate]];
		
		// Create control bar.
		subframe = CGRectMake(0, frame.size.height /*- kControlsBarHeight*/, frame.size.width, kControlsBarHeight);
		_controlsView = [[UIGradientBar alloc] initWithFrame:subframe];
		
		const float kBlackComponents[] = { 0, 0, 0, 0 };
		const float kRedComponents[] = { 1, 0, 0, 0 };
		CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
		CGColorRef black = CGColorCreate(rgb, kBlackComponents);
		CGColorRef red = CGColorCreate(rgb, kRedComponents);
		
		// Create keyboard button.
		subframe = CGRectMake(10, (kControlsBarHeight - kControlsBarButtonHeight) / 2.0f + 1.0f, kKeyboardButtonWidth, kControlsBarButtonHeight);
		_keyboardButton = [[UINavBarButton alloc] initWithImage:[UIImage imageNamed:@"keyboard.png"]];// Title:@"Keyboard" autosizesToFit:NO];
		[_keyboardButton setFrame:subframe];
		[_keyboardButton setNavBarButtonStyle:0];
		[_keyboardButton addTarget:self action:@selector(toggleKeyboard:) forEvents:kUIControlEventMouseUpInside];
		
		// Modifier key buttons.
		subframe = CGRectMake(CGRectGetMaxX(subframe) + 6, (kControlsBarHeight - kControlsBarButtonHeight) / 2.0f + 1.0f, kModifierKeyButtonWidth, kControlsBarButtonHeight);
		_shiftButton = [[UINavBarButton alloc] initWithImage:[UIImage imageNamed:@"shift_key.png"]];
		[_shiftButton setFrame:subframe];
		[_shiftButton setNavBarButtonStyle:0];
		[_shiftButton addTarget:self action:@selector(toggleModifierKey:) forEvents:kUIControlEventMouseUpInside];
		
		subframe.origin.x = CGRectGetMaxX(subframe) + 6.0f;
		_commandButton = [[UINavBarButton alloc] initWithImage:[UIImage imageNamed:@"cmd_key.png"]];
		[_commandButton setFrame:subframe];
		[_commandButton setNavBarButtonStyle:0];
		[_commandButton addTarget:self action:@selector(toggleModifierKey:) forEvents:kUIControlEventMouseUpInside];
		
		subframe.origin.x = CGRectGetMaxX(subframe) + 6.0f;
		_optionButton = [[UINavBarButton alloc] initWithImage:[UIImage imageNamed:@"opt_key.png"]];
		[_optionButton setFrame:subframe];
		[_optionButton setNavBarButtonStyle:0];
		[_optionButton addTarget:self action:@selector(toggleModifierKey:) forEvents:kUIControlEventMouseUpInside];
		
		subframe.origin.x = CGRectGetMaxX(subframe) + 6.0f;
		_controlButton = [[UINavBarButton alloc] initWithImage:[UIImage imageNamed:@"ctrl_key.png"]];
		[_controlButton setFrame:subframe];
		[_controlButton setNavBarButtonStyle:0];
		[_controlButton addTarget:self action:@selector(toggleModifierKey:) forEvents:kUIControlEventMouseUpInside];
		
		// Start of FitToWidth/FitToHeight/FitScreen
		subframe = CGRectMake(subframe.origin.x+kModifierKeyButtonWidth+5 , (kControlsBarHeight - kControlsBarButtonHeight) / 2.0f + 1.0f, 24, kControlsBarButtonHeight);

		_fitWidthButton = [[UINavBarButton alloc] initWithImage:[UIImage imageNamed:@"FitWidth.png"]];
		[_fitWidthButton setFrame:subframe];
		[_fitWidthButton setShowPressFeedback:YES];
		[_fitWidthButton setDrawsShadow:NO];
		[_fitWidthButton setNavBarButtonStyle:0];
		[_fitWidthButton addTarget:self action:@selector(toggleFitWidthHeight:) forEvents:kUIControlEventMouseUpInside];

		subframe = CGRectMake(subframe.origin.x+28, (kControlsBarHeight - kControlsBarButtonHeight) / 2.0f + 1.0f, 24, kControlsBarButtonHeight);
		_fitHeightButton = [[UINavBarButton alloc] initWithImage:[UIImage imageNamed:@"FitHeight.png"]];
		[_fitHeightButton setFrame:subframe];
		[_fitHeightButton setDrawsShadow:NO];
		[_fitHeightButton setShowPressFeedback:YES];
		[_fitHeightButton setNavBarButtonStyle:0];
		[_fitHeightButton addTarget:self action:@selector(toggleFitWidthHeight:) forEvents:kUIControlEventMouseUpInside];

		// Right mouse button.
		subframe = CGRectMake(frame.size.width - kExitButtonWidth - 5 - kRightMouseButtonWidth - 6, (kControlsBarHeight - kControlsBarButtonHeight) / 2.0f + 1.0f, kRightMouseButtonWidth, kControlsBarButtonHeight);
		_rightMouseButton = [[UINavBarButton alloc] initWithTitle:@"R" autosizesToFit:NO];
		[_rightMouseButton setFrame:subframe];
		[_rightMouseButton setNavBarButtonStyle:0];
		[_rightMouseButton addTarget:self action:@selector(toggleRightMouse:) forEvents:kUIControlEventMouseUpInside];
		
		// Terminate connection button.
		subframe = CGRectMake(frame.size.width - kExitButtonWidth - 5, (kControlsBarHeight - kControlsBarButtonHeight) / 2.0f + 1.0f, kExitButtonWidth, kControlsBarButtonHeight);
		_exitButton = [[UINavBarButton alloc] initWithTitle:@"X" autosizesToFit:NO];
		[_exitButton setFrame:subframe];
		[_exitButton setNavBarButtonStyle:0];
		[_exitButton addTarget:self action:@selector(closeConnection:) forEvents:kUIControlEventMouseUpInside];
		
		// Create keyboard.
		CGSize defaultKeyboardSize = [UIKeyboard defaultSize];
		subframe.origin = CGPointMake(0, frame.size.height - kControlsBarHeight - defaultKeyboardSize.height);
		subframe.size = defaultKeyboardSize;
		_keyboardView = [[UIKeyboard alloc] initWithFrame:subframe];
		[_keyboardView setPreferredKeyboardType:kUIKeyboardLayoutAlphabetTransparent];
		
		// Build view hierarchy.
		[_controlsView addSubview:_keyboardButton];
		[_controlsView addSubview:_exitButton];
		[_controlsView addSubview:_shiftButton];
		[_controlsView addSubview:_commandButton];
		[_controlsView addSubview:_optionButton];
		[_controlsView addSubview:_controlButton];
		[_controlsView addSubview:_fitWidthButton];
		[_controlsView addSubview:_fitHeightButton];
		[_controlsView addSubview:_rightMouseButton];
		[self addSubview:_controlsView];

		[_scroller addSubview:_screenView];
		[self addSubview:_scroller];
		
		_areControlsVisible = NO;
		_isKeyboardVisible = NO;
	}
	
	return self;
}

- (void)dealloc
{
    [super dealloc];
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
		
		[UIView beginAnimations:nil];
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
		[UIView endAnimations];
		
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


-(CGPoint)topLeftVisiblePt
{
	return [_scroller bounds].origin;
}

- (void)pinnedPTViewChange:(CGPoint)ptPinned fScale:(float)fScale wOrientationState:(UIHardwareOrientation)wOrientationState bForce:(BOOL)bForce
{
	[_scroller pinnedPTViewChange: ptPinned fScale:fScale wOrientationState:wOrientationState bForce:bForce];
}

-(void)setStartupTopLeftPt:(CGPoint)pt
{
	_ptStartupTopLeft = pt;
}

- (void)toggleFitWidthHeight:(id)sender
{
	UIPushButton *pButton = (UIPushButton *)sender;	
	CGRect rc = [pButton frame];
	scaleSpecialTypes wScaleState = [self getScaleState], 
		wScaleThisButton = pButton == _fitWidthButton ? kScaleFitWidth : kScaleFitHeight;
	id sImage = pButton == _fitWidthButton ? @"FitWidth.png" : @"FitHeight.png";
	id sImageOn = pButton == _fitWidthButton ? @"FitWidthOn.png" : @"FitHeightOn.png";

	if (wScaleState & wScaleThisButton)
	{
		[self setScaleState: wScaleState  & (0xff ^ wScaleThisButton)];
		[pButton setImage: [UIImage imageNamed:sImage] forState:0];
	}
	else
	{
		[self setScaleState: wScaleState  | (wScaleThisButton)];
		[pButton setImage: [UIImage imageNamed:sImageOn] forState:0];
	}
	[self setOrientation: [self getOrientationState] bForce:true];
	[pButton setFrame: rc];
	NSLog(@"Got Event or Scale Change");
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
		[self addSubview:_keyboardView];
		[_keyboardView activate];
		
		// Set the delegate now that we have an active keyboard.
		[[UIKeyboardImpl activeInstance] setDelegate:self];
	}
	
	_isKeyboardVisible = !_isKeyboardVisible;
}

- (BOOL)showMouseTracks
{
	if (_delegate && [_delegate respondsToSelector:@selector(showMouseTracks)])
	{
		[_delegate showMouseTracks];
	}
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
	bool useRight = ![_scroller useRightMouse];
	[_rightMouseButton setNavBarButtonStyle:useRight ? 3 : 0];
	[_scroller setUseRightMouse:useRight];
}

//! Handle one of the modifier key buttons being pressed.
//!
- (void)toggleModifierKey:(id)sender
{
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
		return;
	}
	
	// Determine the new modifier mask.
	//! @todo This logic should be in EventFilter, not here.
	unsigned int currentModifiers = [_filter pressedModifiers];
	unsigned int newModifiers = currentModifiers ^ modifier;
	bool isPressed = newModifiers & modifier;
	
	// Change the button color.
	[sender setNavBarButtonStyle:isPressed ? 3 : 0];
	
	// Queue the modifier changed event.
	[_filter flagsChanged:newModifiers];
}

- (bool) bFirstDisplay
{
	return _bFirstDisplay;
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
		_bFirstDisplay = false;
		NSLog(@"Statusbar Transparent");

		_filter = [_connection eventFilter];
		[_filter setView:_scroller];
		[_scroller setEventFilter:_filter];
		[_scroller setViewOnly:[_connection viewOnly]];
		[_scroller scrollPointVisibleAtTopLeft:CGPointMake(0, 0)];
		[_screenView setNeedsDisplay];
	}
	else
	{		
		_filter = nil;
		[_scroller setEventFilter:nil];
		[_scroller cleanUpMouseTracks];
		[_screenView setFrameBuffer:nil];
		[_screenView setOrientationState:0];
		// Get the screen view to redraw itself in black.
		[_screenView setNeedsDisplay];
		
	}
}

- (UIHardwareOrientation)getOrientationState;
{
	return [_screenView getOrientationState];
}


- (scaleSpecialTypes)getScaleState
{
	return _scaleState;
}

- (void)setScaleState:(scaleSpecialTypes)wScaleState
{
	_scaleState = wScaleState;
}

- (void)setScalePercent:(float)wScale
{
	if (_scaleState != kScaleFitNone)
		{
		float dx,dy, wScaleX, wScaleY;

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
        switch (_scaleState)
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

- (void)setOrientation:(UIHardwareOrientation)wOrientation bForce:(int)bForce
{
	CGSize vncScreenSize = _vncScreenSize;
	CGSize newRemoteSize;

//	NSLog(@"VNC Screen Size  = %f %f", vncScreenSize.width, vncScreenSize.height);
	if (bForce || ((wOrientation == kOrientationVertical || wOrientation == kOrientationVerticalUpsideDown 
		|| wOrientation == kOrientationHorizontalLeft || wOrientation == kOrientationHorizontalRight)
	 	&& _connection && wOrientation != [_screenView getOrientationState]))
	{
//		NSLog(@"Orientation Change %d", wOrientation);

		[_screenView setOrientationState:wOrientation];
	
		if (wOrientation == kOrientationVertical || wOrientation == kOrientationVerticalUpsideDown)
		{
			newRemoteSize = vncScreenSize;
//			[self showControls:1];
		}
		else
		{
			newRemoteSize.width = vncScreenSize.height;
			newRemoteSize.height = vncScreenSize.width;
//			[self showControls:0];
		}

		if ([self getScaleState] != kScaleFitNone)
		{
			[self setScalePercent: 0];
		}
		float fUnscale = [_screenView getScalePercent];
		
		CGRect bounds = CGRectMake(0,0,vncScreenSize.width, vncScreenSize.height);
		[_screenView setBounds: bounds];

		CGAffineTransform matrix = CGAffineTransformRotate(CGAffineTransformMakeScale(0-fUnscale, fUnscale), 
			([_screenView getOrientationDeg])  * M_PI / 180.0f);
		[_filter setBackToVNCTransform: CGAffineTransformInvert(matrix)];
		[_filter setOrientation: wOrientation];

		newRemoteSize.width = newRemoteSize.width * [_screenView getScalePercent];
		newRemoteSize.height = newRemoteSize.height  * [_screenView getScalePercent];

//		NSLog(@"New Screen View = %f %f", newRemoteSize.width, newRemoteSize.height);
		[_screenView setRemoteDisplaySize:newRemoteSize animate:!bForce];
	
		// Reset our scroller's content size.
		[_scroller setContentSize:newRemoteSize];
	}
}

- (void)setRemoteDisplaySize:(CGSize)remoteSize
{
//	NSLog(@"Setting VNC screen size %f %f", remoteSize.width, remoteSize.height);
	_vncScreenSize = remoteSize;
	[self setScaleState: kScaleFitNone];
	[self setOrientation: kOrientationVertical bForce:false];
}

//! The connection object is telling us that a region of the framebuffer
//! needs to be redrawn.
- (void)displayFromBuffer:(CGRect)aRect
{	
	[_screenView displayFromBuffer:aRect];
	
	// If this is our first display update then Transition to the VNC server screen
	if (!_bFirstDisplay)
		{
		_bFirstDisplay = true;
		[_scroller scrollPointVisibleAtTopLeft:_ptStartupTopLeft];
		[_delegate gotFirstFullScreenTransitionNow];
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

- (struct __GSFont *)fontForCaretSelection
{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
	return [UIPushButton defaultFont];
}

- (struct CGColor *)textColorForCaretSelection
{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
	return [UITextTraits defaultCaretColor];
}

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

- (id)textTraits
{
	UITextTraits * traits = [UITextTraits defaultTraits];
	[traits setAutoCapsType:0];	//?
	[traits setAutoCorrectionType:0];	//?
	[traits setAutoEnablesReturnKey:NO];
	return traits;
}

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


#pragma ** UITextTraitsClient **

//+ (int)defaultAutoCapsType
//{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
//	return 0;
//}
//
//+ (int)defaultAutoCorrectionType
//{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
//	return 0;
//}
//
//+ (BOOL)defaultAutoEnablesReturnKey
//{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
//	return NO;
//}
//
//+ (struct CGColor *)defaultCaretColor
//{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
//	return nil;
//}
//
//+ (unsigned int)defaultCaretWidth
//{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
//	return 1;
//}
//
//+ (id)defaultEditingDelegate
//{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
//	return nil;
//}
//
//+ (int)defaultInitialSelectionBehavior
//{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
//	return 0;
//}
//
//+ (int)defaultPreferredKeyboardType
//{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
//	return 0;
//}
//
//+ (int)defaultReturnKeyType
//{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
//	return 0;
//}
//
//+ (BOOL)defaultSecureTextEntryFlag
//{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
//	return NO;
//}
//
//+ (BOOL)defaultSingleCompletionEntryFlag
//{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
//	return NO;
//}
//
//+ (int)defaultTextDomain
//{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
//	return 0;
//}
//
//+ (int)defaultTextLoupeVisibility
//{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
//	return 0;
//}
//
//+ (id)defaultTextSuggestionDelegate
//{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
//	return nil;
//}
//
//+ (struct __CFCharacterSet *)defaultTextTrimmingSet
//{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
//	return nil;
//}
//
//+ (id)defaultTraits
//{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
//	return nil;
//}
//
//- (int)autoCapsType
//{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
//	return 0;
//}
//
//- (int)autoCorrectionType
//{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
//	return 0;
//}
//
//- (BOOL)autoEnablesReturnKey
//{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
//	return NO;
//}
//
//- (struct CGColor *)caretColor
//{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
//	return nil;
//}
//
//- (unsigned int)caretWidth
//{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
//	return 1;
//}
//
////- (void)dealloc
////{
////	NSLog(@"%s", __PRETTY_FUNCTION__);
////}
//
//- (id)editingDelegate
//{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
//	return nil;
//}
//
////- (id)init
////{
////	NSLog(@"%s", __PRETTY_FUNCTION__);
////}
//
//- (int)initialSelectionBehavior
//{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
//	return 0;
//}
//
//- (int)preferredKeyboardType
//{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
//	return 0;
//}
//
//- (int)returnKeyType
//{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
//	return 0;
//}
//
//- (BOOL)secureTextEntry
//{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
//	return NO;
//}
//
//- (void)setAutoCapsType:(int)fp8
//{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
//}
//
//- (void)setAutoCorrectionType:(int)fp8
//{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
//}
//
//- (void)setAutoEnablesReturnKey:(BOOL)fp8
//{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
//}
//
//- (void)setCaretColor:(struct CGColor *)fp8
//{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
//}
//
//- (void)setCaretWidth:(unsigned int)fp8
//{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
//}
//
//- (void)setEditingDelegate:(id)fp8
//{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
//}
//
//- (void)setInitialSelectionBehavior:(int)fp8
//{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
//}
//
//- (void)setPreferredKeyboardType:(int)fp8
//{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
//}
//
//- (void)setReturnKeyType:(int)fp8
//{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
//}
//
//- (void)setSecureTextEntry:(BOOL)fp8
//{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
//}
//
//- (void)setSingleCompletionEntry:(BOOL)fp8
//{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
//}
//
//- (void)setTextDomain:(int)fp8
//{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
//}
//
//- (void)setTextLoupeVisibility:(int)fp8
//{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
//}
//
//- (void)setTextSuggestionDelegate:(id)fp8
//{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
//}
//
//- (void)setTextTrimmingSet:(struct __CFCharacterSet *)fp8
//{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
//}
//
//- (void)setToDefaultValues
//{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
//}
//
//- (void)setToSecureValues
//{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
//}
//
//- (BOOL)singleCompletionEntry
//{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
//	return NO;
//}
//
//- (void)takeTraitsFrom:(id)fp8
//{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
//}
//
//- (int)textDomain
//{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
//	return 0;
//}
//
//- (int)textLoupeVisibility
//{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
//	return 0;
//}
//
//- (id)textSuggestionDelegate
//{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
//	return nil;
//}
//
//- (struct __CFCharacterSet *)textTrimmingSet
//{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
//	return nil;
//}
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
