//
//  ProfileDataManager.h
//  Chicken of the VNC
//
//  Created by Jared McIntyre on 8/12/04.
//  Copyright 2004 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ProfileDataManager : NSObject {

@private
	NSMutableDictionary*		profiles;
}

/**
 *  Accessor method to fetch the singleton instance for this class. Use this method
 *  instead of creating an instance of your own.
 *  @return Shared singleton instance of the ProfileDataManager class. */
+ (ProfileDataManager*) sharedInstance;

- (NSMutableDictionary*)profileForKey:(id) key;
- (void)setProfile:(NSMutableDictionary*) profile forKey:(id) key;
- (void)removeProfileForKey:(id) key;
- (int)count;
- (void)save;
- (NSArray*)sortedKeyArray;
@end
