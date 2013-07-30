//
//  LocationHandler.m
//  Nearby-v0.2
//
//  Created by Scott Marnik on 7/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LocationHandler.h"


@implementation LocationHandler

@synthesize latitudeString, longitudeString, manager;

-(void) turnOnGPS
{
	manager = [[CLLocationManager alloc] init];
	[manager setDesiredAccuracy:kCLLocationAccuracyBest];
	[manager startUpdatingLocation];
	
	// it would probably be a good idea to have some kinda boolean value that says if GPS is on or not
	// but i'm the only one using this class so we won't worry about that
}

-(void) turnOffGPS
{
	[manager stopUpdatingLocation];
	[manager release];
}

-(NSString*) getLatitude
{
	CLLocation *loadedLocation = [manager location];
	CLLocationCoordinate2D loadedCoordinate = [loadedLocation coordinate];
	return [[NSNumber numberWithDouble:loadedCoordinate.latitude] stringValue];
}

-(NSString*) getLongitude
{
	CLLocation *loadedLocation = [manager location];
	CLLocationCoordinate2D loadedCoordinate = [loadedLocation coordinate];
	return [[NSNumber numberWithDouble:loadedCoordinate.longitude] stringValue];
}

-(NSString*) getAccuracy
{
	CLLocation *loadedLocation = [manager location];
	CLLocationAccuracy loadedAccuracy = [loadedLocation horizontalAccuracy];
	return [[NSNumber numberWithDouble:loadedAccuracy] stringValue];
}

-(CLLocationCoordinate2D) getCoordinate
{
	CLLocation *loadedLocation = [manager location];
	return [loadedLocation coordinate];
}
@end
