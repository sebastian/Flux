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
