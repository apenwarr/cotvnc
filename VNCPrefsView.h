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
	kMouseDownUpTracksIndex
};

/*!
 * @brief This view class allows users to edit global preferences.
 */
@interface VNCPrefsView : UIView
{
	UINavigationBar * _navBar;
	UIPreferencesTable * _table;
	id _delegate;
	NSArray * _cells;
	UISwitchControl * _mouseTracksSwitch;
	UISwitchControl * _disconnectSwitch;
}

- (id)initWithFrame:(CGRect)frame;

- (void)setDelegate:(id)newDelegate;
- (id)delegate;

//! @brief Tells the receiver to update view controls based on current preference settings.
- (void)updateViewFromPreferences;

- (void)setKeyboardVisible:(BOOL)visible;

@end

@interface VNCPrefsView (DelegateMethods)

//! @brief Sent to the delegate when editing of preferences is finished.
- (void)finishedEditingPreferences;

@end
