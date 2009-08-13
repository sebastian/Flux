//
//  TestController.m
//  Finance
//
//  Created by Sebastian Probst Eide on 13.08.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import "TestController.h"


@implementation TestController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = @"Testing grounds";
	
	[[KleioSearchBar searchBar] setDelegate:self];
}

- (void)dealloc {
    [super dealloc];
}


@end
