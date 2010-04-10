//
//  viewtestViewController.h
//  viewtest
//
//  Created by Avery Pennarun on 2010-03-28.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VNCContentView.h"

@interface viewtestViewController : UIViewController<UIScrollViewDelegate> {
    VNCContentView *vncView;
}

@property (nonatomic, retain) IBOutlet VNCContentView *vncView;

@end

