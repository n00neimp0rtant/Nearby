//
//  NearbyAppDelegate.h
//  Nearby
//
//  Created by Scott Marnik on 7/24/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NearbyViewController;

@interface NearbyAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    NearbyViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet NearbyViewController *viewController;

@end



