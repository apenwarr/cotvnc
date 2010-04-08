//
//  viewtestAppDelegate.h
//  viewtest
//
//  Created by Avery Pennarun on 2010-03-28.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class viewtestViewController;

@interface viewtestAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    viewtestViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet viewtestViewController *viewController;

@end

