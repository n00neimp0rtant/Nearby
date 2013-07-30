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
#import "SoundEffect.h"

@interface NearbyViewController : UIViewController <URLShortenerDelegate, MKMapViewDelegate, MFMessageComposeViewControllerDelegate, ADBannerViewDelegate, UIActionSheetDelegate, UIAlertViewDelegate, MFMailComposeViewControllerDelegate>{
	LocationHandler* handler;
	NSMutableString* url;
	NSString* phoneNumber;
	int urlFunctionCase;
	BOOL firstLoad, playSound, canSendText;
	SoundEffect* beta;
}

@property(nonatomic, retain) IBOutlet UIView* accuracyPane;
@property(nonatomic, retain) IBOutlet UILabel* shortenURLText;
@property(nonatomic, retain) IBOutlet UILabel* accuracyDetail;
@property(nonatomic, retain) IBOutlet UILabel* accuracy;
@property(nonatomic, retain) IBOutlet UIImageView* greenOrb;
@property(nonatomic, retain) IBOutlet UIImageView* yellowOrb;
@property(nonatomic, retain) IBOutlet UIImageView* redOrb;
@property(nonatomic, retain) IBOutlet UIButton* shareButtoniPod;
@property(nonatomic, retain) IBOutlet UIButton* textButton;
@property(nonatomic, retain) IBOutlet UIButton* shareButton;
@property(nonatomic, retain) IBOutlet UIButton* shortenURLInfo;
@property(nonatomic, retain) IBOutlet UIButton* closeButton;
@property(nonatomic, retain) IBOutlet UISegmentedControl* segmentedControl;
@property(nonatomic, retain) IBOutlet UISwitch* shortenURL;
@property(nonatomic, retain) IBOutlet UIActivityIndicatorView* spinner;
@property(nonatomic, retain) IBOutlet UINavigationBar* titleBar;
@property(nonatomic, retain) IBOutlet MKMapView* mapView;
@property(nonatomic, retain) IBOutlet ADBannerView* banner;

@property(nonatomic, retain) LocationHandler* handler;
@property(nonatomic, readwrite, retain) NSMutableString* url;
@property(nonatomic, retain) NSString* phoneNumber;
@property int urlFunctionCase;
@property BOOL firstLoad, playSound, canSendText, accuse;

- (IBAction) mapTypeChanged: (id)sender;
- (IBAction) sendSMS: (id)sender;
- (IBAction) share: (id)sender;
- (IBAction) showLocation: (id)sender;
- (IBAction) urlAlertView: (id)sender;
- (IBAction) tweetSupport: (id)sender;
- (IBAction) closeAd: (id)sender;
- (void) openSMSPanel;
- (void) displayShareOptions;
- (void) copyToPasteboard;
- (void) sendEmail;
- (void) sendTweet;
- (void) zoomAndCenter;
- (void) bannerFadeIn;
- (void) bannerFadeOut;

@end