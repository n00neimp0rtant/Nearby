//
//  LocationHandler.h
//  Nearby-v0.2
//
//  Created by Scott Marnik on 7/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


@interface LocationHandler : NSObject {
	
	CLLocationManager *manager;
	NSString *latitudeString;
	NSString *longitudeString;

}

@property(nonatomic, retain) CLLocationManager *manager;
@property(nonatomic, copy) NSString *latitudeString;
@property(nonatomic, copy) NSString *longitudeString;

-(NSString*) getLatitude;
-(NSString*) getLongitude;
-(NSString*) getAccuracy;
-(CLLocationCoordinate2D) getCoordinate;
-(void) turnOnGPS;
-(void) turnOffGPS;

@end
