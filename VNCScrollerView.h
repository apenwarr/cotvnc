//
//  VNCScrollerView.h
//  vnsea
//
//  Created by Chris Reed on 10/16/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventFilter.h"

/*!
 * @brief Subclass of UIScroller that modifies its behaviour.
 */
@interface VNCScrollerView : UIScroller
{
	EventFilter * _eventFilter;		//!< Event generation and queue object.
	bool _inRemoteAction;			//!< Are we controlling the remote mouse?
	NSTimer * _tapTimer;	//!< Timer used to delay first mouse down.
	bool _viewOnly;			//!< Are we only watching the remote computer?
}

- (void)setEventFilter:(EventFilter *)filter;
- (void)setViewOnly:(bool)isViewOnly;

@end
