//
//  VNCPreferences.h
//  vnsea
//
//  Created by Chris Reed on 11/17/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

//! Key for the mouse tracks preference.
extern NSString * kShowMouseTracksPrefKey;

//! Key for the disconnect on suspend preference.
extern NSString * kDisconnectOnSuspendPrefKey;

//! Key for the chording interval preference.
extern NSString * kChordingIntervalPrefKey;

/*!
 * @brief Shared preferences class.
 */
@interface VNCPreferences : NSObject
{
}

//! @brief Returns the single shared instance of the VNCPreferences class.
+ (VNCPreferences *)sharedPreferences;

//! @name Getters
//@{
- (BOOL)showMouseTracks;
- (BOOL)disconnectOnSuspend;
//@}

//! @name Setters
//@{
- (void)setShowMouseTracks:(BOOL)showTracks;
- (void)setDisconnectOnSuspend:(BOOL)disconnect;
//@}

@end

