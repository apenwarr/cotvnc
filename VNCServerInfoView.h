//
//  VNCServerInfoView.h
//  vnsea
//
//  Created by Chris Reed on 9/6/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIPreferencesTable.h>
#import <UIKit/UISwitchControl.h>
#import <UIKit/UIPreferencesDeleteTableCell.h>
#import <UIKit/UISegmentedControl.h>

//! @brief Array indices for the preferences table cells.
enum _server_info_cell_indices
{
	kServerNameCellIndex,
	kServerAddressCellIndex,
	kServerPasswordCellIndex,
	kServerDisplayCellIndex,
	kServerSharedCellIndex,
	kServerViewOnlyCellIndex,
	kServerPixelDepthCellIndex
};

/*!
 * @brief View where user can enter info about a server.
 */
@interface VNCServerInfoView : UIView
{
	UINavigationBar * _navBar;
	UIPreferencesTable * _table;
	NSMutableDictionary * _serverInfo;
	id _delegate;
	NSArray * _cells;
	UISwitchControl * _sharedSwitch;
	UISwitchControl * _viewOnlySwitch;
	UISwitchControl * _keepRemoteMouseVisibleSwitch;
	UISegmentedControl * _pixelDepthControl;
	UIPreferencesDeleteTableCell * _deleteCell;
	int _nGroups;
}

- (id)initWithFrame:(CGRect)frame;
- (void) scrollTableToTop;

- (void)setDelegate:(id)newDelegate;
- (id)delegate;

- (void)setServerInfo:(NSDictionary *)info;

- (void)setKeyboardVisible:(BOOL)visible;

- (void)deleteButtonPressed:(id)sender;

@end

@interface VNCServerInfoView (DelegateMethods)

//! Pass nil for serverInfo to cancel editing.
- (void)finishedEditingServer:(NSDictionary *)serverInfo;

- (void)deleteServer;

@end
