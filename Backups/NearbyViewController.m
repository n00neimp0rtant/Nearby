//
//  NearbyViewController.m
//  Nearby
//
//  Created by Scott Marnik on 7/24/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "NearbyViewController.h"

@implementation NearbyViewController

@synthesize pleaseSupportText;
@synthesize shortenURLText;
@synthesize shareButtoniPod;
@synthesize textButton;
@synthesize shareButton;
@synthesize shortenURLInfo;
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

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	url = [[NSString alloc] init];
	
	// turn on GPS
	handler = [[LocationHandler alloc] init];
	[handler turnOnGPS];
	
	// initialize map
	mapView.delegate = self;
	firstLoad = YES;
	
	banner.requiredContentSizeIdentifiers = [NSSet setWithObjects:ADBannerContentSizeIdentifier320x50, nil];
	banner.currentContentSizeIdentifier = ADBannerContentSizeIdentifier320x50;

	banner.alpha = 0;
	pleaseSupportText.alpha = 0;
	
	// set urlFunctionCase
	// these only apply to shortened URLs, long ones handle themselves
	// if 0, no action happening
	// if 1, sending SMS
	// if 2, copying to clipboard
	urlFunctionCase = 0;
	
	// if device cannot send text, don't show Text button
    Class messageClass = (NSClassFromString(@"MFMessageComposeViewController"));
	if([messageClass canSendText])
	{
		[textButton setHidden:NO];
		[shareButton setHidden:NO];
		[shareButtoniPod setHidden:YES];
	}
	else {
		[textButton setHidden:YES];
		[shareButton setHidden:YES];
		[shareButtoniPod setHidden:NO];
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
	url = @"http://maps.google.com/maps?q=";
	url = [url stringByAppendingString:[handler getLatitude]];
	url = [url stringByAppendingString:@","];
	url = [url stringByAppendingString:[handler getLongitude]];
	if (shortenURL.on) {
		urlFunctionCase = 1;
		shortenURL.enabled = NO;
		shortenURLText.text = @"Shortening...";
		[spinner startAnimating];
		[shortenURLInfo setHidden:YES];
		URLShortener* shortener = [[URLShortener alloc] init];
		if (shortener != nil)
		{
			shortener.delegate = self;
			shortener.login = @"n00neimp0rtant";
			shortener.key = @"R_59b3a910826d83d5f2e4df498d25ac50";
			shortener.url = [NSURL URLWithString: url];
			[shortener execute];
			
			// see delegate methods below
		}
	}
	else {
		[self openSMSPanel: url];
	}
}

- (IBAction) fadeOutButton: (UIButton*)sender
{
	[UIView beginAnimations:@"buttonFade" context:NULL];
	sender.alpha = 0;
	[UIView commitAnimations];
}

- (IBAction) reappearButton: (UIButton*)sender
{
	sender.alpha = 1;
}

- (IBAction) share: (id)sender
{
	url = @"http://maps.google.com/maps?q=";
	url = [url stringByAppendingString:[handler getLatitude]];
	url = [url stringByAppendingString:@","];
	url = [url stringByAppendingString:[handler getLongitude]];
	if (shortenURL.on) {
		urlFunctionCase = 2;
		shortenURL.enabled = NO;
		shortenURLText.text = @"Shortening...";
		[spinner startAnimating];
		[shortenURLInfo setHidden:YES];
		URLShortener* shortener = [[URLShortener alloc] init];
		if (shortener != nil)
		{
			shortener.delegate = self;
			shortener.login = @"n00neimp0rtant";
			shortener.key = @"R_59b3a910826d83d5f2e4df498d25ac50";
			shortener.url = [NSURL URLWithString: url];
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











#pragma mark Common Functions

// actually opens up the send SMS panel
- (void) openSMSPanel: (NSString*)urlString
{
	MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
	NSString* smsBody = @"I am here: ";
	smsBody = [smsBody stringByAppendingString:urlString];
	picker.messageComposeDelegate = self;
	picker.body = smsBody;
	[self presentModalViewController:picker animated:YES];
	[picker release];
}

- (void) displayShareOptions
{
	UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:@"How do you want to share your location?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Copy to Clipboard", @"Send in Email", @"Post with Twitter", nil];
	popupQuery.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	[popupQuery showInView:self.view];
	[popupQuery release];
}

// copies the given URL to the global pasteboard
- (void) copyToPasteboard: (NSString*)urlString
{
	UIPasteboard *appPasteBoard = [UIPasteboard generalPasteboard];
	appPasteBoard.persistent = YES;
	[appPasteBoard setString: urlString];
	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Location Copied" message:@"You can now paste your location link anywhere." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
	[alert show];
}

- (void) sendEmail:(NSString *)urlString
{
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	[picker setSubject:@"My Current Location"];
	NSString* emailBody = @"I am here: ";
	emailBody = [emailBody stringByAppendingString:urlString];
	[picker setMessageBody:emailBody isHTML:NO];
	[self presentModalViewController:picker animated:YES];
	[picker release];
}

- (void) sendTweet:(NSString *)urlString
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"twitter://post?message=I%%20am%%20here:%%20%@", urlString]]];
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
	pleaseSupportText.alpha = 1;
	[UIView commitAnimations];
}

- (void)bannerFadeOut
{
	[UIView beginAnimations:@"BannerFadeOut" context:NULL];
	banner.alpha = 0;
	pleaseSupportText.alpha = 0;
	[UIView commitAnimations];
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
	self.url = shortenedURL.absoluteString;
	switch (urlFunctionCase) {
		case 0:
		{
			UIAlertView *uhoh = [[[UIAlertView alloc] initWithTitle:@"Something went wrong." message:@"I'm not sure what, but this, literally, should NEVER happen. Like, it's supposed to be impossible to happen. Tweet me @n00neimp0rtant so I can fix it." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
			[uhoh show];
			break;
		}
		case 1:
			[self openSMSPanel: shortenedURL.absoluteString];
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
	shortenURLText.text = @"Create Shortened Link";
}

- (void) shortener: (URLShortener*) shortener didFailWithStatusCode: (int) statusCode;
{
	[spinner stopAnimating];
	[shortenURLInfo setHidden:NO];
	shortenURL.enabled = YES;
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
		[self copyToPasteboard:url];
	}
	else if (buttonIndex == 1) {
		[self sendEmail:url];
	}
	else if (buttonIndex == 2) {
		[self sendTweet:url];
	}
}

#pragma mark iAd Delegate Methods

- (void)bannerViewDidLoadAd:(ADBannerView*)banner
{
	NSLog(@"Ad loaded");
	[self bannerFadeIn];
}

- (void)bannerView:(ADBannerView*)banner didFailToReceiveAdWithError:(NSError *)error
{	
	NSLog(@"Ad failed to load");
	[self bannerFadeOut];
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
	[pleaseSupportText release];
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