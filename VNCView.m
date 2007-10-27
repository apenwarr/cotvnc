//
//  VNCView.m
//  vnsea
//
//  Created by Chris Reed on 9/5/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "VNCView.h"
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

//! Height of the controls bar view.
#define kControlsBarHeight (48.0f)

//! Height of buttons in the controls bar.
#define kControlsBarButtonHeight (32.0f)

#define kKeyboardButtonWidth (80.0f)

#define kExitButtonWidth (30.0f)

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

// I can never remember this relationship for some reason:
// The frame rectangle defines the view's location and size in the superview using the superview’s coordinate system. The bounds rectangle defines the interior coordinate system that is used when drawing the contents of the view, including the origin and scaling.
- (id)initWithFrame:(CGRect)frame
{
	if ([super initWithFrame:frame])
	{
		CGRect subframe = frame;
		subframe.origin = CGPointMake(0, 0);
		
		// Create scroller view.
		_scroller = [[VNCScrollerView alloc] initWithFrame:subframe];
		[_scroller setScrollingEnabled:YES];
		[_scroller setShowScrollerIndicators:YES];
		[_scroller setAdjustForContentSizeChange:YES];
		[_scroller setAllowsRubberBanding:NO];
		[_scroller setAllowsFourWayRubberBanding:NO];
		[_scroller setDelegate:self];
		
		// Create screen view.
		_screenView = [[VNCContentView alloc] initWithFrame:subframe];
		
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
		_keyboardButton = [[UINavBarButton alloc] initWithTitle:@"Keyboard" autosizesToFit:NO];
		[_keyboardButton setFrame:subframe];
		[_keyboardButton setNavBarButtonStyle:0];
		[_keyboardButton addTarget:self action:@selector(toggleKeyboard:) forEvents:kUIControlEventMouseUpInside];
		
		// Terminate connection button.
		subframe = CGRectMake(frame.size.width - kExitButtonWidth - 10, (kControlsBarHeight - kControlsBarButtonHeight) / 2.0f + 1.0f, kExitButtonWidth, kControlsBarButtonHeight);
		_exitButton = [[UINavBarButton alloc] initWithTitle:@"X" autosizesToFit:NO];
		[_exitButton setFrame:subframe];
		[_exitButton setNavBarButtonStyle:0];
		[_exitButton addTarget:self action:@selector(closeConnection:) forEvents:kUIControlEventMouseUpInside];
		
		subframe = CGRectMake(100, (kControlsBarHeight - kModifierKeyImageHeight) / 2.0f, kModifierKeyImageWidth, kModifierKeyImageHeight);
		_shiftButton = [[UIPushButton alloc] initWithImage:[UIImage imageNamed:@"shift_key.png"]];
		[_shiftButton setFrame:subframe];
		[_shiftButton setDrawsShadow:YES];
//		[_shiftButton setShadowOffset:3.0f];
//		[_shiftButton setShadowColor:black forState:0];
//		[_shiftButton setShadowColor:red forState:1];
//		[_shiftButton setReverseShadowDirectionWhenHighlighted:YES];
		[_shiftButton setShowPressFeedback:YES];
		
		subframe.origin.x += kModifierKeyImageWidth + 6.0f;
		_commandButton = [[UIPushButton alloc] initWithImage:[UIImage imageNamed:@"cmd_key.png"]];
		[_commandButton setFrame:subframe];
		[_commandButton setShowPressFeedback:YES];
		
		subframe.origin.x += kModifierKeyImageWidth + 6.0f;
		_optionButton = [[UIPushButton alloc] initWithImage:[UIImage imageNamed:@"opt_key.png"]];
		[_optionButton setFrame:subframe];
		[_optionButton setShowPressFeedback:YES];
		[_optionButton setSelected:YES];
		
		subframe.origin.x += kModifierKeyImageWidth + 6.0f;
		_controlButton = [[UIPushButton alloc] initWithImage:[UIImage imageNamed:@"ctrl_key.png"]];
		[_controlButton setFrame:subframe];
		[_controlButton setShowPressFeedback:YES];
		
		// Create keyboard.
		CGSize defaultKeyboardSize = [UIKeyboard defaultSize]; //CGSizeMake(320, 215); //
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
		}
		
		// This will start the animation.
		[UIView endAnimations];
		
		_areControlsVisible = show;
	}
}

- (void)toggleControls
{
	[self showControls:!_areControlsVisible];
}

//! This method assumes the controls bar is visible.
//!
- (void)toggleKeyboard:(id)sender
{
//	NSLog(@"toggling keyboard: old=%d", (int)_isKeyboardVisible);
	
	CGRect frame;
	
	if (_isKeyboardVisible)
	{
		// Remove the keyboard view.
		[_keyboardView removeFromSuperview];
		
		// Adjust scroller frame.
		frame = [self bounds];
		frame.size.height -= kControlsBarHeight;
		[_scroller setFrame:frame];
	}
	else
	{
		// Adjust scroller frame.
		frame = [self bounds];
		frame.size.height -= kControlsBarHeight - [_keyboardView frame].size.height;
		[_scroller setFrame:frame];
		
		// Add in the keyboard view.
		[self addSubview:_keyboardView];
		[_keyboardView activate];
		
		// Set the delegate now that we have an active keyboard.
		[[UIKeyboardImpl activeInstance] setDelegate:self];
	}
	
	_isKeyboardVisible = !_isKeyboardVisible;
}

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
		_filter = [_connection eventFilter];
		[_filter setView:_scroller];
		[_scroller setEventFilter:_filter];
		[_scroller setViewOnly:[_connection viewOnly]];
		[_scroller scrollPointVisibleAtTopLeft:CGPointMake(0, 0)];
	}
	else
	{
		// The connection was closed.
		_filter = nil;
		[_scroller setEventFilter:nil];
		[_screenView setFrameBuffer:nil];
		
		// Get the screen view to redraw itself in black.
		[_screenView setNeedsDisplay];
	}
}

//! The remote display size is being set or has changed, so we need to update
//! the underlying content view and tell the scroller view that its content
//! size has changed.
- (void)setRemoteDisplaySize:(CGSize)remoteSize
{
	[_screenView setRemoteDisplaySize:remoteSize];
	
	// Reset our scroller's content size.
	[_scroller setContentSize:remoteSize];
}

//! The connection object is telling us that a region of the framebuffer
//! needs to be redrawn.
- (void)displayFromBuffer:(CGRect)aRect
{
	[_screenView displayFromBuffer:aRect];
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
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
	[_filter keyTyped:@"\x007f"];
}

- (void)insertText:(id)text
{
	NSLog(@"%s:%@", __PRETTY_FUNCTION__, text);
	
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

@end
