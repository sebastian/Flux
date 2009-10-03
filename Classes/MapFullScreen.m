//
//  MapFullScreen.m
//  Finance
//
//  Created by Sebastian Probst Eide on 04.08.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import "MapFullScreen.h"
#import "Transaction.h"
#import "MapAnnotation.h"

@implementation MapFullScreen

@synthesize annotation, region;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	Private

- (double)latitudeRangeForLocation:(CLLocation *)aLocation
{
	const double M = 6367000.0; // approximate average meridional radius of curvature of earth
	const double metersToLatitude = 1.0 / ((M_PI / 180.0) * M);
	const double accuracyToWindowScale = 2.0;
	
	return aLocation.horizontalAccuracy * metersToLatitude * accuracyToWindowScale;
}

- (double)longitudeRangeForLocation:(CLLocation *)aLocation
{
	double latitudeRange =
	[self latitudeRangeForLocation:aLocation];
	
	return latitudeRange * cos(aLocation.coordinate.latitude * M_PI / 180.0);
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	NSObject

- (id) initWithTransaction:(Transaction*)trs {
	if (self = [self initWithNibName:@"MapFullScreen" bundle:[NSBundle mainBundle]]) {
		
		// Create the annotation
		CLLocationCoordinate2D location ;
		location = trs.location.coordinate;
			
		self.annotation = [[MapAnnotation alloc] initWithTransaction:trs];
			
		MKCoordinateSpan span;
//		span.latitudeDelta = 0.0015;
		span.latitudeDelta = [self latitudeRangeForLocation:trs.location];
		span.longitudeDelta = [self longitudeRangeForLocation:trs.location];
			
		MKCoordinateRegion theRegion;
		theRegion.center = location;
		theRegion.span = span;
		self.region = theRegion;
			
	}
	return self;
}

-(void)viewDidLoad {
	[super viewDidLoad];
	[map addAnnotation:annotation];
	
	/*
	 Zoom out a bit so that we can get a better view
	 */
	MKCoordinateSpan span = region.span;
	span.latitudeDelta = span.latitudeDelta * 1.8;
	region.span = span;
	
	[map setRegion:region];
}

- (void)didReceiveMemoryWarning {
	TTLOG(@"didReceiveMemoryWarning: %@", self);
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [super dealloc];
}


@end
