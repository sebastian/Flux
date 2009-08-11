//
//  MapFullScreen.m
//  Finance
//
//  Created by Sebastian Probst Eide on 04.08.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import "MapFullScreen.h"


@implementation MapFullScreen

@synthesize annotation, region;

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
	NSLog(@"didReceiveMemoryWarning: %@", self);
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [super dealloc];
}


@end
