//
//  QueuedEvent.h
//  keysymtest
//
//  Created by Bob Newhart on 7/1/05.
//  Copyright 2005 Geekspiff. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <GraphicsServices/GraphicsServices.h>

// copied from OS X headers
enum {
	NSAlphaShiftKeyMask =		1 << 16,
	NSShiftKeyMask =		1 << 17,
	NSControlKeyMask =		1 << 18,
	NSAlternateKeyMask =		1 << 19,
	NSCommandKeyMask =		1 << 20,
	NSNumericPadKeyMask =		1 << 21,
	NSHelpKeyMask =			1 << 22,
	NSFunctionKeyMask =		1 << 23,
	NSDeviceIndependentModifierFlagsMask = 0xffff0000U
};



typedef enum {
	kQueuedMouse1DownEvent, 
	kQueuedMouse1UpEvent, 
	kQueuedMouse2DownEvent, 
	kQueuedMouse2UpEvent, 
	kQueuedMouse3DownEvent, 
	kQueuedMouse3UpEvent, 
	kQueuedKeyDownEvent, 
	kQueuedKeyUpEvent, 
	kQueuedModifierDownEvent, 
	kQueuedModifierUpEvent, 
} QueuedEventType;


@interface QueuedEvent : NSObject {
	QueuedEventType _eventType;
	CGPoint _location;
	NSTimeInterval _timestamp;
	unichar _character;
	unichar _characterIgnoringModifiers;
	unsigned int _modifier;
}

// Creation
+ (QueuedEvent *)mouseDownEventForButton: (int)buttonNumber
								location: (CGPoint)location
							   timestamp: (NSTimeInterval)timestamp;
+ (QueuedEvent *)mouseUpEventForButton: (int)buttonNumber
							  location: (CGPoint)location
							 timestamp: (NSTimeInterval)timestamp;
+ (QueuedEvent *)keyDownEventWithCharacter: (unichar)character
				characterIgnoringModifiers: (unichar)unmodCharacter
								 timestamp: (NSTimeInterval)timestamp;
+ (QueuedEvent *)keyUpEventWithCharacter: (unichar)character
			  characterIgnoringModifiers: (unichar)unmodCharacter
							   timestamp: (NSTimeInterval)timestamp;
+ (QueuedEvent *)modifierDownEventWithCharacter: (unsigned int)modifier
								 timestamp: (NSTimeInterval)timestamp;
+ (QueuedEvent *)modifierUpEventWithCharacter: (unsigned int)modifier
							   timestamp: (NSTimeInterval)timestamp;

// Event Attributes
- (QueuedEventType)type;
- (CGPoint)locationInWindow;
- (NSTimeInterval)timestamp;
- (unichar)character;
- (unichar)characterIgnoringModifiers;
- (unsigned int)modifier;

@end
