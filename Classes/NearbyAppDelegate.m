//
//  NearbyAppDelegate.m
//  Nearby
//
//  Created by Scott Marnik on 7/24/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "NearbyAppDelegate.h"
#import "NearbyViewController.h"




@implementation NearbyAppDelegate

@synthesize window;
@synthesize viewController;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.
	
    // Add the view controller's view to the window and display.
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
	
	[self setupByPreferences];
	
    return YES;
}


- (void)setupByPreferences
{
    NSString *testValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"textPrefix"];
	if (testValue == nil)
	{
		// no default values have been set, create them here based on what's in our Settings bundle info
		//
		NSString *pathStr = [[NSBundle mainBundle] bundlePath];
		NSString *settingsBundlePath = [pathStr stringByAppendingPathComponent:@"Settings.bundle"];
		NSString *finalPath = [settingsBundlePath stringByAppendingPathComponent:@"Root.plist"];
        
		NSDictionary *settingsDict = [NSDictionary dictionaryWithContentsOfFile:finalPath];
		NSArray *prefSpecifierArray = [settingsDict objectForKey:@"PreferenceSpecifiers"];
        
		NSString *textMessage = nil;
		NSString *emailMessage = nil;
		NSString *emailSubject = nil;
		NSString *twitterMessage = nil;
		NSNumber *hashtag;
		
		
		NSDictionary *prefItem;
		for (prefItem in prefSpecifierArray)
		{
			NSString *keyValueStr = [prefItem objectForKey:@"Key"];
			id defaultValue = [prefItem objectForKey:@"DefaultValue"];
			
			if ([keyValueStr isEqualToString:@"textPrefix"])
			{
				textMessage = defaultValue;
			}
			else if ([keyValueStr isEqualToString:@"emailPrefix"])
			{
				emailMessage = defaultValue;
			}
			else if ([keyValueStr isEqualToString:@"emailSubject"])
			{
				emailSubject = defaultValue;
			}
			else if ([keyValueStr isEqualToString:@"twitterPrefix"])
			{
				twitterMessage = defaultValue;
			}
			else if ([keyValueStr isEqualToString:@"includeHashtag"]);
			{
				hashtag = defaultValue;
			}
		}
        
		NSLog(@"%@", textMessage);
		
		
		// since no default values have been set (i.e. no preferences file created), create it here		
		
		
		
		NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
                                     textMessage, @"textPrefix",
                                     emailMessage, @"emailPrefix",
                                     emailSubject, @"emailSubject",
                                     twitterMessage, @"twitterPrefix",
									 hashtag, @"includeHashtag",
                                     nil];
        
		
		
		[[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}


- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    if (!url) {  return NO; }
	
    NSString *URLString = [url absoluteString];
	viewController.phoneNumber = URLString;
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
