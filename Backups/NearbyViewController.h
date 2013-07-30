//
//  NearbyViewController.h
//  Nearby
//
//  Created by Scott Marnik on 7/24/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <iAd/iAd.h>
#import "LocationHandler.h"
#import "URLShortener.h"

@interface NearbyViewController : UIViewController <URLShortenerDelegate, MKMapViewDelegate, MFMessageComposeViewControllerDelegate, ADBannerViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate>{
	LocationHandler* handler;
	NSString* url;
	NSString* phoneNumber;
	int urlFunctionCase;
	BOOL firstLoad;
}

@property(nonatomic, retain) IBOutlet UILabel* pleaseSupportText;
@property(nonatomic, retain) IBOutlet UILabel* shortenURLText;
@property(nonatomic, retain) IBOutlet UIButton* shareButtoniPod;
@property(nonatomic, retain) IBOutlet UIButton* textButton;
@property(nonatomic, retain) IBOutlet UIButton* shareButton;
@property(nonatomic, retain) IBOutlet UIButton* shortenURLInfo;
@property(nonatomic, retain) IBOutlet UISegmentedControl* segmentedControl;
@property(nonatomic, retain) IBOutlet UISwitch* shortenURL;
@property(nonatomic, retain) IBOutlet UIActivityIndicatorView* spinner;
@property(nonatomic, retain) IBOutlet UINavigationBar* titleBar;
@property(nonatomic, retain) IBOutlet MKMapView* mapView;
@property(nonatomic, retain) IBOutlet ADBannerView* banner;

@property(nonatomic, retain) LocationHandler* handler;
@property(nonatomic, retain) NSString* url;
@property(nonatomic, retain) NSString* phoneNumber;
@property int urlFunctionCase;
@property BOOL firstLoad;

- (IBAction) mapTypeChanged: (id)sender;
- (IBAction) sendSMS: (id)sender;
- (IBAction) fadeOutButton: (id)sender;
- (IBAction) reappearButton: (id)sender;
- (IBAction) share: (id)sender;
- (IBAction) showLocation: (id)sender;
- (IBAction) urlAlertView: (id)sender;
- (void) openSMSPanel: (NSString*)smsBody;
- (void) displayShareOptions;
- (void) copyToPasteboard: (NSString*)urlString;
- (void) sendEmail: (NSString*)urlString;
- (void) sendTweet: (NSString*)urlString;
- (void) zoomAndCenter;
- (void) bannerFadeIn;
- (void) bannerFadeOut;

@end