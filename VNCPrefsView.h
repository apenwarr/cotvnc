//
//  VNCPrefsView.h
//  vnsea
//
//  Created by Glenn Kreisel on 11/3/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIPreferencesTable.h>
#import <UIKit/UISwitchControl.h>
#import <UIKit/UIPreferencesDeleteTableCell.h>
#import <UIKit/UISegmentedControl.h>

#import "VNCScrollerView.h"

//! @brief Array indices for the preferences table cells.
enum _prefs_cell_indices
{
	kMouseDownUpTracksIndex,
};

#define MOUSE_TRACKS @"MouseTracks"


/*!
 * @brief View were user can enter info about a server.
 */
@interface VNCPrefsView : UIView
{
	UINavigationBar * _navBar;
	UIPreferencesTable * _table;
	NSMutableDictionary * _prefsInfo;
	id _delegate;
	NSArray * _cells;
	UISwitchControl * _mouseTracksSwitch;
}

- (id)initWithFrame:(CGRect)frame ;

- (void)setDelegate:(id)newDelegate;
- (id)delegate;

- (void)setPrefsInfo:(NSDictionary *)info;

- (void)setKeyboardVisible:(BOOL)visible;
- (void)displayAbout;
- (BOOL)showMouseTracks;

@end

@interface VNCPrefsView (DelegateMethods)

//! Pass nil for serverInfo to cancel editing.
- (void)finishedPrefs:(NSDictionary *)serverInfo;


@end
