//
//  NearbyViewController.m
//  Nearby
//
//  Created by Scott Marnik on 7/24/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "NearbyViewController.h"

@implementation NearbyViewController

@synthesize accuracyPane;
@synthesize shortenURLText;
@synthesize accuracyDetail;
@synthesize accuracy;
@synthesize greenOrb;
@synthesize yellowOrb;
@synthesize redOrb;
@synthesize shareButtoniPod;
@synthesize textButton;
@synthesize shareButton;
@synthesize shortenURLInfo;
@synthesize closeButton;
@synthesize segmentedControl;
@synthesize shortenURL;
@synthesize spinner;
@synthesize titleBar;
@synthesize mapView;
@synthesize banner;

@synthesize handler;
@synthesize url;
@synthesize phoneNumber;
@synthesize urlFunctionCase;
@synthesize firstLoad;
@synthesize playSound;
@synthesize canSendText;




// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	

	
	textButton.enabled = NO;
	shareButton.enabled = NO;
	shareButtoniPod.enabled = NO;
	
	// turn on GPS
	handler = [[LocationHandler alloc] init];
	[handler turnOnGPS];
	
	// initialize map
	mapView.delegate = self;
	firstLoad = YES;
	playSound = YES;
	
	// set up ad view
	banner.requiredContentSizeIdentifiers = [NSSet setWithObjects:ADBannerContentSizeIdentifier320x50, nil];
	banner.currentContentSizeIdentifier = ADBannerContentSizeIdentifier320x50;
	
	[self moveBannerViewOffscreenAnimated:NO];
	
	// set up accuracy pane
	accuracyPane.backgroundColor = [UIColor blackColor];
	accuracyDetail.text = @"Please wait...";
	greenOrb.hidden = YES;
	yellowOrb.hidden = YES;
	redOrb.hidden = YES;
	
	// initialize url string
	self.url = [[NSMutableString alloc] init];
	
	// initialize sound file
	NSBundle *mainBundle = [NSBundle mainBundle];
	beta = [[SoundEffect alloc] initWithContentsOfFile: [mainBundle pathForResource:@"beta" ofType:@"caf"]];
	
	// set urlFunctionCase
	// these only apply to shortened URLs, long ones handle themselves
	// if 0, no action happening
	// if 1, sending SMS
	// if 2, share panel
	urlFunctionCase = 0;
	
	// check if device can send texts; if not, disable text button
	Class messageClass = (NSClassFromString(@"MFMessageComposeViewController"));
    if (messageClass == nil || ![messageClass canSendText])
	{
		canSendText = NO;
		textButton.hidden = YES;
		shareButton.hidden = YES;
		shareButtoniPod.hidden = NO;
	}
	else
	{
		canSendText = YES;
		textButton.hidden = NO;
		shareButton.hidden = NO;
		shareButtoniPod.hidden = YES;
	}
}











#pragma mark Interface Builder Actions

- (IBAction) mapTypeChanged: (id)sender
{
	[self zoomAndCenter];
	if (segmentedControl.selectedSegmentIndex == 0)
		mapView.mapType = MKMapTypeStandard;
	if (segmentedControl.selectedSegmentIndex == 1)
		mapView.mapType = MKMapTypeSatellite;
	if (segmentedControl.selectedSegmentIndex == 2)
		mapView.mapType = MKMapTypeHybrid;
}

- (IBAction) sendSMS: (id)sender
{
	Class messageClass = (NSClassFromString(@"MFMessageComposeViewController"));
	if (messageClass == nil || ![messageClass canSendText])
	{
		UIAlertView* alert = [[UIAlertView alloc] init];
		[alert setTitle:@"Cannot Send Texts"];
		[alert setMessage:@"This device cannot send text messages. You can use another sharing method instead."];
		[alert setDelegate:self];
		[alert addButtonWithTitle:@"OK"];
		[alert show];
		[alert release];
	}
	else
	{
		[url setString:@"http://maps.google.com/maps?q="];
		[[self url] appendString:[handler getLatitude]];
		[[self url] appendString:@","];
		[[self url] appendString:[handler getLongitude]];
		if (shortenURL.on) {
			urlFunctionCase = 1;
			shortenURL.enabled = NO;
			shareButtoniPod.enabled = NO;
			shareButton.enabled = NO;
			textButton.enabled = NO;
			shortenURLText.text = @"Shortening...";
			[spinner startAnimating];
			[shortenURLInfo setHidden:YES];
			URLShortener* shortener = [[URLShortener alloc] init];
			if (shortener != nil)
			{
				shortener.delegate = self;
				shortener.login = @"n00neimp0rtant";
				shortener.key = @"R_59b3a910826d83d5f2e4df498d25ac50";
				shortener.url = [NSURL URLWithString: self.url];
				[shortener execute];
				
				// see delegate methods below
			}
		}
		else {
			[self openSMSPanel];
		}
	}
}

- (IBAction) share: (id)sender
{
	[url setString:@"http://maps.google.com/maps?q="];
	[[self url] appendString:[handler getLatitude]];
	[[self url] appendString:@","];
	[[self url] appendString:[handler getLongitude]];
	if (shortenURL.on) {
		
		urlFunctionCase = 2;
		shortenURL.enabled = NO;
		shareButtoniPod.enabled = NO;
		shareButton.enabled = NO;
		textButton.enabled = NO;
		shortenURLText.text = @"Shortening...";
		[spinner startAnimating];
		[shortenURLInfo setHidden:YES];
		URLShortener* shortener = [[URLShortener alloc] init];
		if (shortener != nil)
		{
			shortener.delegate = self;
			shortener.login = @"n00neimp0rtant";
			shortener.key = @"R_59b3a910826d83d5f2e4df498d25ac50";
			shortener.url = [NSURL URLWithString: self.url];
			[shortener execute];
			
			// see delegate methods below
		}
	}
	else {
		[self displayShareOptions];
	}
}

- (IBAction) showLocation: (id)sender
{
	[self zoomAndCenter];
}

- (IBAction) urlAlertView: (id)sender
{
	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Link Shortening" message:@"Shortened links will look nicer and use fewer letters, but take a bit longer to make and load." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
	[alert show];
}

- (IBAction) tweetSupport: (id)sender
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"twitter://post?message=@NearbyApp "]];
}


-(IBAction) closeAd: (id)sender
{
	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Nearby Ad-Free" message:@"For only $0.99, you can buy an ad-free version of Nearby. You'll even get a larger preview map!" delegate:self cancelButtonTitle:@"No Thanks" otherButtonTitles:@"Buy", nil] autorelease];
	[alert show];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if ([[alertView title] isEqualToString:@"Hmmm..."]) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"cydia://package/com.iadkiller"]];
	}
	else if ([[alertView title] isEqualToString:@"Nearby Ad-Free"])
	{
		if(buttonIndex == 1)
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://google.com"]];
		else if(buttonIndex == 0)
		{
			[UIView beginAnimations:@"FadeCloseButton" context:NULL];
			self.closeButton.alpha = 0.0;
			[UIView commitAnimations];
			self.closeButton.enabled = NO;
		}
	}
}






#pragma mark Common Functions

// actually opens up the send SMS panel
- (void) openSMSPanel
{
	MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
	picker.messageComposeDelegate = self;
	picker.body = [NSString stringWithFormat:@"I am here: %@", url];
	[self presentModalViewController:picker animated:YES];
	[picker release];
}

- (void) displayShareOptions
{
	UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:@"How do you want to share your location?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Copy to Clipboard", @"Send in Email", @"Post with Twitter App", nil];
	popupQuery.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	[popupQuery showInView:self.view];
	[popupQuery release];
}

// copies the given URL to the global pasteboard
- (void) copyToPasteboard
{
	UIPasteboard *appPasteBoard = [UIPasteboard generalPasteboard];
	appPasteBoard.persistent = YES;
	[appPasteBoard setString: url];
	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Location Copied" message:@"You can now paste your location link anywhere." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
	[alert show];
}

- (void) sendEmail
{
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	[picker setSubject:@"My Current Location"];
	NSString* settingValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"email_message"];
	[picker setMessageBody:[NSString stringWithFormat:@"%@ %@", settingValue, url] isHTML:NO];
	[self presentModalViewController:picker animated:YES];
	[picker release];
}

- (void) sendTweet
{
	if(shortenURL.on)
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"twitter://post?message=%@%%20%%23nearby", url]]];
	else
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"twitter://post?message=http://maps.google.com/maps?q%%3D%@,%@%%20%%23nearby", [handler getLatitude], [handler getLongitude]]]];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/us/app/twitter/id333903271?mt=8"]];

}
	
// zoom and center
- (void)zoomAndCenter
{
	MKCoordinateRegion region;
	MKCoordinateSpan span;
	span.latitudeDelta = 0.005;
	span.longitudeDelta = 0.005;
	region.span = span;
	CLLocationCoordinate2D location;
	location = mapView.userLocation.location.coordinate;
	region.center = location;
	[mapView setRegion:region animated:YES];
	[mapView regionThatFits:region];
}










#pragma mark Animations

- (void)bannerFadeIn
{
	[UIView beginAnimations:@"BannerFadeIn" context:NULL];
	banner.alpha = 1;
	[UIView commitAnimations];
}

- (void)bannerFadeOut
{
	[UIView beginAnimations:@"BannerFadeOut" context:NULL];
	banner.alpha = 0;
	[UIView commitAnimations];
}

- (void)moveBannerViewOffscreenAnimated: (BOOL) animate
{
	CGRect newBannerFrame = self.banner.frame;
	newBannerFrame.origin.y = self.view.frame.size.height;
	
	CGRect newShortenURLTextFrame = self.shortenURLText.frame;
	newShortenURLTextFrame.origin.y = (newBannerFrame.origin.y - 27);
	
	CGRect newSpinnerFrame = self.spinner.frame;
	newSpinnerFrame.origin.y = (newBannerFrame.origin.y - 30);
	
	CGRect newShortenURLInfoFrame = self.shortenURLInfo.frame;
	newShortenURLInfoFrame.origin.y = (newBannerFrame.origin.y - 31);
	
	CGRect newShortenURLFrame = self.shortenURL.frame;
	newShortenURLFrame.origin.y = (newBannerFrame.origin.y - 35);
	
	CGRect newTextButtonFrame = self.textButton.frame;
	newTextButtonFrame.origin.y = (newBannerFrame.origin.y - 89);
	
	CGRect newShareButtonFrame = self.shareButton.frame;
	newShareButtonFrame.origin.y = (newBannerFrame.origin.y - 89);
	
	CGRect newShareButtoniPodFrame = self.shareButtoniPod.frame;
	newShareButtoniPodFrame.origin.y = (newBannerFrame.origin.y - 89);
	
	CGRect newCloseButtonFrame = self.closeButton.frame;
	newCloseButtonFrame.origin.y = (newBannerFrame.origin.y - 12);
	
	CGRect newMapViewFrame = self.mapView.frame;
	newMapViewFrame.size.height = 280;
	
	if (animate) {
		[UIView beginAnimations:@"BannerViewDisappear" context:NULL];
		self.banner.frame = newBannerFrame;
		self.shortenURLText.frame = newShortenURLTextFrame;
		self.spinner.frame = newSpinnerFrame;
		self.shortenURLInfo.frame = newShortenURLInfoFrame;
		self.shortenURL.frame = newShortenURLFrame;
		self.textButton.frame = newTextButtonFrame;
		self.shareButton.frame = newShareButtonFrame;
		self.shareButtoniPod.frame = newShareButtoniPodFrame;
		self.closeButton.frame = newCloseButtonFrame;
		self.closeButton.alpha = 0;
		self.mapView.frame = newMapViewFrame;
		[UIView commitAnimations];
	}
	
	else {
		self.banner.frame = newBannerFrame;
		self.shortenURLText.frame = newShortenURLTextFrame;
		self.spinner.frame = newSpinnerFrame;
		self.shortenURLInfo.frame = newShortenURLInfoFrame;
		self.shortenURL.frame = newShortenURLFrame;
		self.textButton.frame = newTextButtonFrame;
		self.shareButton.frame = newShareButtonFrame;
		self.shareButtoniPod.frame = newShareButtoniPodFrame;
		self.closeButton.frame = newCloseButtonFrame;
		self.closeButton.alpha = 0;
		self.mapView.frame = newMapViewFrame;
	}
	self.closeButton.enabled = NO;
}

- (void)moveBannerViewOnscreen
{
	CGRect newBannerFrame = self.banner.frame;
	newBannerFrame.origin.y = (self.view.frame.size.height - newBannerFrame.size.height);
	
	CGRect newShortenURLTextFrame = self.shortenURLText.frame;
	newShortenURLTextFrame.origin.y = (newBannerFrame.origin.y - 27);
	
	CGRect newSpinnerFrame = self.spinner.frame;
	newSpinnerFrame.origin.y = (newBannerFrame.origin.y - 30);
	
	CGRect newShortenURLInfoFrame = self.shortenURLInfo.frame;
	newShortenURLInfoFrame.origin.y = (newBannerFrame.origin.y - 31);
	
	CGRect newShortenURLFrame = self.shortenURL.frame;
	newShortenURLFrame.origin.y = (newBannerFrame.origin.y - 35);
	
	CGRect newTextButtonFrame = self.textButton.frame;
	newTextButtonFrame.origin.y = (newBannerFrame.origin.y - 89);
	
	CGRect newShareButtonFrame = self.shareButton.frame;
	newShareButtonFrame.origin.y = (newBannerFrame.origin.y - 89);
	
	CGRect newShareButtoniPodFrame = self.shareButtoniPod.frame;
	newShareButtoniPodFrame.origin.y = (newBannerFrame.origin.y - 89);
	
	CGRect newCloseButtonFrame = self.closeButton.frame;
	newCloseButtonFrame.origin.y = (newBannerFrame.origin.y - 12);
	
	CGRect newMapViewFrame = self.mapView.frame;
	newMapViewFrame.size.height = 230;
	
	[UIView beginAnimations:@"BannerViewAppear" context:NULL];
	self.banner.frame = newBannerFrame;
	self.shortenURLText.frame = newShortenURLTextFrame;
	self.spinner.frame = newSpinnerFrame;
	self.shortenURLInfo.frame = newShortenURLInfoFrame;
	self.shortenURL.frame = newShortenURLFrame;
	self.textButton.frame = newTextButtonFrame;
	self.shareButton.frame = newShareButtonFrame;
	self.shareButtoniPod.frame = newShareButtoniPodFrame;
	self.closeButton.frame = newCloseButtonFrame;
	self.closeButton.alpha = 1.0;
	self.mapView.frame = newMapViewFrame;
	[UIView commitAnimations];
	
	self.closeButton.enabled = YES;
}












#pragma mark Map View Delegate Methodss

// center map on current location when it's updated
- (void)mapView: (MKMapView*)mapView didUpdateUserLocation: (MKUserLocation*)userLocation
{
	if (firstLoad == YES) {
		[self zoomAndCenter];
		firstLoad = NO;
	}
	else {
		CLLocationCoordinate2D location;
		location = userLocation.location.coordinate;
		[mapView setCenterCoordinate:location animated:YES];
	}
	
	if(userLocation.location.horizontalAccuracy == 0)
	{
		playSound = YES;
		accuracyPane.backgroundColor = [UIColor blackColor];
		accuracyDetail.text = @"Locating...";
		greenOrb.hidden = YES;
		yellowOrb.hidden = YES;
		redOrb.hidden = NO;
	}
	else if(userLocation.location.horizontalAccuracy <= 200)
	{
		if (playSound) {
			[beta play];
			playSound = NO;
		}
		greenOrb.hidden = NO;
		yellowOrb.hidden = YES;
		redOrb.hidden = YES;
		
		
		if (canSendText) {
			accuracyDetail.text = @"Locked-on. Ready to text or share.";
		}
		else {
			accuracyDetail.text = @"Locked-on. Ready to share.";
		}

	}
	else
	{
		playSound = YES;
		greenOrb.hidden = YES;
		yellowOrb.hidden = NO;
		redOrb.hidden = YES;
		accuracyDetail.text = @"Please wait for better accuracy...";
	}
}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Unable to locate" message:@"Sorry, couldn't find you. You may be out of GPS range and/or do not have an Internet connection. Try again later." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
	[alert show];
}












#pragma mark URL Shortener Delegate Methods

// if URL is successfully shortened
- (void) shortener: (URLShortener*) shortener didSucceedWithShortenedURL: (NSURL*) shortenedURL
{
	[[self url] setString: shortenedURL.absoluteString];
	switch (urlFunctionCase) {
		case 0:
		{
			UIAlertView *uhoh = [[[UIAlertView alloc] initWithTitle:@"Don't do that." message:@"Do you LIKE it when your apps crash? You probably thought you were SOOOOO clever. Don't do that, mm-kay?" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
			[uhoh show];
			break;
		}
		case 1:
			[self openSMSPanel];
			break;
		case 2:
			[self displayShareOptions];
			break;
		default:
			break;
	}
	urlFunctionCase = 0;
	[spinner stopAnimating];
	[shortenURLInfo setHidden:NO];
	shortenURL.enabled = YES;
	shareButtoniPod.enabled = YES;
	shareButton.enabled = YES;
	textButton.enabled = YES;
	shortenURLText.text = @"Create Shortened Link";
}

- (void) shortener: (URLShortener*) shortener didFailWithStatusCode: (int) statusCode;
{
	[spinner stopAnimating];
	[shortenURLInfo setHidden:NO];
	shortenURL.enabled = YES;
	shareButtoniPod.enabled = YES;
	shareButton.enabled = YES;
	textButton.enabled = YES;
	shortenURLText.text = @"Create Shortened Link";
	UIAlertView *alert = [[UIAlertView alloc] init];
	[alert setTitle:@"Could not shorten link"];
	[alert setMessage:@"There was an error shortening the link. Try without shortening the link."];
	[alert setDelegate:self];
	[alert addButtonWithTitle:@"OK"];
	[alert show];
	[alert release];
}

- (void) shortener: (URLShortener*) shortener didFailWithError: (NSError*) error;
{
	[spinner stopAnimating];
	[shortenURLInfo setHidden:NO];
	shortenURL.enabled = YES;
	shareButtoniPod.enabled = YES;
	shareButton.enabled = YES;
	textButton.enabled = YES;
	shortenURLText.text = @"Create Shortened Link";
	UIAlertView *alert = [[UIAlertView alloc] init];
	[alert setTitle:@"No Internet connection"];
	[alert setMessage:@"It looks like you don't have an Internet connection, so the link could not be shortened. Try without shortening the link."];
	[alert setDelegate:self];
	[alert addButtonWithTitle:@"OK"];
	[alert show];
	[alert release];
}










#pragma mark Message/Mail Sending Delegate Methods

// close panel when you tap Cancel
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
	[self dismissModalViewControllerAnimated:YES];
}
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	[self dismissModalViewControllerAnimated:YES];
}










#pragma mark Sharing Delegate Methods and stuff

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0) {
		[self copyToPasteboard];
	}
	else if (buttonIndex == 1) {
		[self sendEmail];
	}
	else if (buttonIndex == 2) {
		[self sendTweet];
	}
}







#pragma mark iAd Delegate Methods

- (void)bannerViewDidLoadAd:(ADBannerView*)banner
{
	NSLog(@"Ad loaded");
	textButton.enabled = YES;
	shareButton.enabled = YES;
	shareButtoniPod.enabled = YES;
	[self moveBannerViewOnscreen];
}
- (void)bannerView:(ADBannerView*)banner didFailToReceiveAdWithError:(NSError *)error
{	
	NSLog(@"Ad failed to load");
	textButton.enabled = YES;
	shareButton.enabled = YES;
	shareButtoniPod.enabled = YES;
	[self moveBannerViewOffscreenAnimated:YES];
}
- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
	[handler turnOffGPS];
	mapView.showsUserLocation=NO;
	return YES;
}
- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
	[handler turnOnGPS];
	mapView.showsUserLocation=YES;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation
{
	if (UIInterfaceOrientationIsPortrait(orientation))
		return YES;
	else
		return NO;
}










#pragma mark Other Stuff

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)dealloc {
	banner.delegate = nil;
	[shortenURLText release];
	[shareButtoniPod release];
	[textButton release];
	[shareButton release];
	[shortenURLInfo release];
	[segmentedControl release];
	[shortenURL release];
	[spinner release];
	[titleBar release];
	[mapView release];
	[banner release];
	[handler release];
	[url release];
	[phoneNumber release];
    [super dealloc];
}

@end