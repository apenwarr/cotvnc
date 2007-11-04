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

#define MOUSE_VISIBLE @"MOUSE_VISIBLE"

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
 * @brief View were user can enter info about a server.
 */
@interface VNCServerInfoView : UIView
{
	UINavigationBar * _navBar;
	UIPreferencesTable * _table;
	NSMutableDictionary * _serverInfo;
	id _delegate;
	NSArray * _cells;
	UISwitchControl * _sharedSwitch;
	UISwitchControl * _viewOnlySwitch, *_keepRemoteMouseVisibleSwitch;
	UISegmentedControl * _pixelDepthControl;
	UIPreferencesDeleteTableCell * _deleteCell;
}

- (id)initWithFrame:(CGRect)frame;

- (void)setDelegate:(id)newDelegate;
- (id)delegate;

- (void)setServerInfo:(NSDictionary *)info;

- (void)setKeyboardVisible:(BOOL)visible;

- (void)deleteButtonPressed:(id)sender;

- (NSString *)decryptPassword:(NSString *)pns;

NSString *vncDecryptPasswd(NSString *pnsEncrypted);

@end

@interface VNCServerInfoView (DelegateMethods)

//! Pass nil for serverInfo to cancel editing.
- (void)finishedEditingServer:(NSDictionary *)serverInfo;

- (void)deleteServer;

@end
